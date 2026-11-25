# Registry signing keys

The registry is signed with one RSA key whose public half is compiled into Hex, rebar3 and Gleam. Replacing it requires a release of every client. This design adds a root key that clients trust. The root key signs a list of intermediate keys, an intermediate key signs a list of signing keys, and every registry file carries both lists. Once clients trust the root key, hex.pm replaces a signing key or an intermediate key by publishing a new list. The Fastly edge also signs a short-lived freshness header on every response, so a client can tell that a file is the one hex.pm serves at that time.

The names `SignedKeys`, `IntermediateKeys`, `SigningKeys`, `Freshness`, `x-hex-freshness` and "key list" are proposals, and so is the one-hour validity of the freshness header.

## How it works today

- `Signed` in `registry/signed.proto` has `payload` (1) and `signature` (2). The signature is RSA PKCS#1 v1.5 with SHA-512 over `payload`.
- hexpm signs in `Hexpm.Repository.Storage.sign_and_gzip/1` with `HEXPM_SIGNING_KEY`, for `names`, `versions`, `packages/NAME` and `policies/NAME` of the `hexpm` repository and of every organization repository.
- hex_core verifies in `hex_registry:decode_and_verify_signed/2` with `repo_public_key`, which defaults to the key compiled into `hex_core.erl`. Hex compiles in its own copy in `Hex.Repo`. rebar3 vendors hex_core 0.20.1 with the key. Gleam compiles the key into `compiler-core/src/hex.rs` and verifies in `gleam-lang/hexpm-rust`.
- hexpm's `diff`, `preview` and `hexdocs` services depend on hex_core `~> 0.18.0` and use its default key.
- The Fastly edge decodes `Signed` in `fastly/hex-shared/src/policy.rs` to read a policy's visibility. It doesn't verify the signature.
- No registry payload says when it was built, and nothing ties a file to the current state of the registry. A mirror or proxy can serve an old, validly signed `packages/NAME` that lacks a release, a retirement or an advisory.

## Keys

There are three tiers.

The root key is compiled into clients and signs only the intermediate key list. It's generated once on an offline machine and imported into a PIV slot on each of two YubiKey 5s, and the copy on the machine is destroyed. Losing one YubiKey leaves the other. The YubiKeys are offline except when a list is signed. The format allows several root keys, which a root roll uses.

The intermediate key signs only the signing key list. It's a Cloud KMS HSM key in a Google Cloud project of its own, which no service account of the hexpm projects can access. The root key can replace it without a client release.

Signing keys sign registry files. hexpm holds their private halves. The intermediate key can replace them without a YubiKey.

The freshness key signs the freshness header. The Fastly `repo` service holds it in its secret store. It's listed in the signing key list, so the intermediate key can replace it too.

The intermediate key can't be exported, and neither can the root key once it's on the YubiKeys. Clients learn the intermediate and signing public keys from the two lists.

All new keys are ECDSA P-256 with SHA-256. OTP's `public_key`, ring (which Gleam uses), Cloud KMS and YubiKey PIV support it, and a signature is about 70 bytes where RSA 2048 needs 256. Each key names its algorithm, so a later key can use a different one.

## Protobuf

```proto
syntax = "proto2";

message Signed {
  // Signed contents
  required bytes payload = 1;
  // RSA-SHA512 signature of the payload, for clients configured with a
  // single repository public key
  optional bytes signature = 2;
  // Signatures of the payload by signing keys listed in `signing_keys`
  repeated Signature signatures = 3;
  // Encoded SigningKeys, signed by intermediate keys
  optional SignedKeys signing_keys = 4;
  // Encoded IntermediateKeys, signed by root keys
  optional SignedKeys intermediate_keys = 5;
}

message Signature {
  // SHA-256 of the key's DER-encoded SubjectPublicKeyInfo
  required bytes key_id = 1;
  required bytes signature = 2;
}

message SignedKeys {
  // Encoded SigningKeys or IntermediateKeys message
  required bytes payload = 1;
  repeated Signature signatures = 2;
}

message SigningKeys {
  // Increases with every new list
  required uint64 version = 1;
  // Unix time in seconds after which clients reject the list
  required int64 expires_at = 2;
  repeated Key signing_keys = 3;
  // Keys that sign the freshness header
  repeated Key freshness_keys = 4;
}

message IntermediateKeys {
  // Increases with every new list
  required uint64 version = 1;
  // Unix time in seconds after which clients reject the list
  required int64 expires_at = 2;
  repeated Key intermediate_keys = 3;
  repeated Key root_keys = 4;
}

message Key {
  // Clients skip a key whose algorithm is absent or unknown
  optional KeyAlgorithm algorithm = 1;
  // DER-encoded SubjectPublicKeyInfo
  required bytes public_key = 2;
  // Clients treat an absent or unknown status as KEY_REVOKED
  optional KeyStatus status = 3;
  // Unix time in seconds when a KEY_RETIRING root key stops signing
  // lists. Shown in the client's warning, not enforced by clients.
  optional int64 retires_at = 4;
}

// Value of the x-hex-freshness response header, base64-encoded
message Freshness {
  // Unix time in seconds after which clients reject the response
  required int64 expires_at = 1;
  // SHA-256 of Signed.payload
  required bytes payload_hash = 2;
  // By a freshness key listed in the signing key list
  required Signature signature = 3;
}

enum KeyAlgorithm {
  // Clients skip the key
  KEY_ALGORITHM_UNSPECIFIED = 0;
  KEY_ALGORITHM_ECDSA_P256_SHA256 = 1;
}

enum KeyStatus {
  // Clients treat the key as KEY_REVOKED
  KEY_STATUS_UNSPECIFIED = 0;
  // Signatures by the key are accepted
  KEY_ACTIVE = 1;
  // Root keys only. Signatures by the key are accepted. A client with
  // no KEY_ACTIVE root key tells the user to update.
  KEY_RETIRING = 2;
  // Signatures by the key are rejected
  KEY_REVOKED = 3;
}
```

Each tier signs with its own prefix, so a signature made for one purpose can't verify for another:

- A signing key signs `"hex-registry-payload\n" || payload`.
- An intermediate key signs `"hex-registry-signing-keys\n" || signing_keys.payload`.
- A root key signs `"hex-registry-intermediate-keys\n" || intermediate_keys.payload`.
- A freshness key signs `"hex-registry-freshness\n" || expires_at || payload_hash`, with `expires_at` as 8 bytes big-endian.

A file can carry several signatures, one per signing key hexpm holds. This is how an algorithm change works: hexpm signs with a key of each algorithm and a client verifies the one it implements.

`KEY_RETIRING` on a root key is the flag that tells users a client update is coming. hex.pm publishes an intermediate key list that marks the old root keys as retiring with a `retires_at` date, while an old root key still signs it. A client released before the roll verifies the list with an old root key and finds that none of its compiled-in root keys is `KEY_ACTIVE`. On each registry fetch it prints a warning with the date and the update command. Clients don't enforce `retires_at`. An old client stops working when the old root keys stop signing lists and the last list they signed expires.

The enums are `optional` because protoc-generated proto2 parsers drop an unknown enum value, and a dropped `required` field fails the whole message. Value 0 of each enum is unspecified. A parser that substitutes the default for an absent or unknown value then skips the key or treats it as revoked.

The two lists and the signatures add about 750 to 1,100 bytes to each registry file before gzip. That's an estimate from field sizes: 91-byte public keys, signatures of about 70 bytes, one root key, one or two intermediate keys, one or two signing keys, one freshness key, one root key signature, one intermediate key signature, and one or two file signatures.

## Client verification

A repository is configured with either root keys or a single public key. The built-in `hexpm` repository and hex.pm organization repositories use root keys. Repositories added with `mix hex.repo add --root-key PATH` use the given root key. Repositories added with `mix hex.repo add --public-key` keep the single key and today's check of field 2.

Clients store both lists in their signed form, one pair per set of root keys, so `hexpm` and every `hexpm:ORG` repository share them. Hex stores them in its registry cache under `~/.hex`. hex_core takes the stored lists in its config and returns the lists it selected.

For a repository with root keys:

1. Require `intermediate_keys` and `signing_keys`.
2. Verify that at least one `intermediate_keys.signatures` entry is by a configured root key that the stored intermediate key list doesn't mark `KEY_REVOKED`. Skip entries with an unknown `key_id`. Compare the list with the stored one, select the one with the higher `version` and store it.
3. Verify that at least one `signing_keys.signatures` entry is by an intermediate key that is `KEY_ACTIVE` in the selected intermediate key list. Drop the stored signing key list if it no longer verifies the same way. Compare the list with the stored one, select the one with the higher `version` and store it.
4. Reject a selected list if its `expires_at` has passed or its `version` is below the client's compiled-in minimum for that list.
5. Accept the file if at least one `signatures` entry verifies under a signing key that is `KEY_ACTIVE` in the selected signing key list.
6. For these repositories, don't verify field 2 and don't keep hex.pm's old RSA key in the client. A client that accepted field 2 when the new fields are missing would accept files forged with the old key. Repositories configured with a single public key still verify field 2 with that key.
7. Warn if the client's root keys are all `KEY_RETIRING` in the selected intermediate key list. Their signatures are still accepted, and the warning tells the user to update before they stop.

`HEX_UNSAFE_REGISTRY=1` and `repo_verify => false` skip all of it, as today.

Hex keeps decoded registry entries and their ETags in its cache and reuses them on a `304`. On upgrade, Hex drops the entries that an earlier release verified with the RSA key. When a newly stored list revokes a signing key or an intermediate key, Hex also drops the cached entries and ETags of that source, so it fetches and verifies them again.

Clients check expiry when they verify a fetched file. Hex verified its cached entries when it fetched them, so it keeps using them on a `304` and when the repository is unreachable, even if a stored list has expired since. With an expired stored list Hex sends its requests without ETags, so every response is a full file carrying the lists hex.pm serves at that time.

The stored versions stop a client from accepting an older list in which a revoked key is still active. A client without stored state, such as a CI machine with an empty cache or the `diff`, `preview` and `hexdocs` services, accepts an older list until it expires or until the client is upgraded to a release with a higher compiled-in minimum version. After a signing key or an intermediate key is compromised, the next release of each client raises that minimum.

Both lists are valid for 12 months and get re-signed every 6, the intermediate key list with a YubiKey and the signing key list with the KMS key. Every file carries the lists from its last build, so after each re-sign a hexpm job rebuilds every registry file and policy of every repository and purges the CDN. hexpm exports both expiries as metrics and alerts 90 days before each. An expired list makes every upgraded client fail on hex.pm. A mirror that stopped syncing fails for upgraded clients once a list in its files expires, and so does a client whose clock is ahead of the expiry.

## Freshness

The signatures above prove that hex.pm published a file. The freshness header proves that it's the file hex.pm serves now.

The Fastly `repo` service adds `x-hex-freshness` to every `200` and `304` response for a registry file. Its value is a base64-encoded `Freshness` message: an expiry one hour ahead, the SHA-256 of the file's `Signed.payload`, and a signature by the freshness key. The service computes the payload hash when the file enters its cache and signs when it responds. The response's `Cache-Control: max-age` is no longer than the header's remaining validity, so a caching proxy fetches again before the header expires.

For a repository whose selected signing key list has freshness keys, a client:

1. Requires the header on every `200` and `304`.
2. Verifies the signature under a freshness key that is `KEY_ACTIVE` in the selected signing key list.
3. Rejects the response if `expires_at` has passed.
4. Compares `payload_hash` with the hash of the payload it received, or on a `304` with the hash stored with its cached entry. On a mismatch after a `304` it drops the cached entry and fetches again without an ETag.

A repository whose signing key list has no freshness keys is verified without the header. The list is signed, so only the repository can turn the check off.

The header says that Fastly served that payload at that time. A mirror or proxy can replay a response for at most an hour. A stale copy inside Fastly or in the bucket gets a current header, so the check doesn't cover those. Whoever holds the freshness key can make an old file pass as current for as long as they hold it, and can't change a file's content.

Hex keeps using cached entries when the repository is unreachable, as today. A client whose clock is more than an hour ahead rejects every response. A mirror that copies registry files into its own storage has no header to serve, so upgraded clients reject it for repositories that have freshness keys.

## Replacing keys later

A signing key is replaced with the intermediate key:

1. Generate the new signing key. Sign a signing key list with `version + 1` that has both signing keys active.
2. Deploy hexpm with the new list and the new key. Rebuild every registry file and policy and purge the CDN.
3. Sign a signing key list with `version + 2` that marks the old key `KEY_REVOKED`. Deploy it, rebuild and purge again.

A compromised key goes through the same three steps. A list that revoked the old key before step 2 finished would make every client that had stored it reject the files not yet rebuilt or still cached at the CDN.

The intermediate key is replaced the same way one tier up. The root key signs an intermediate key list with both intermediate keys active, and the new intermediate key signs a signing key list. After the rebuild, the root key signs an intermediate key list that revokes the old intermediate key. Clients then drop every signing key list the old intermediate key signed.

The freshness key is replaced with the same three steps as a signing key. The Fastly service switches to the new key after the rebuild in step 2, when every file carries a list that names it.

Clients with stored state need no release for either. Clients without stored state stop accepting the old key when the previous list expires or when they're upgraded to a release with a raised minimum version.

If both YubiKeys are lost, nothing can sign the next intermediate key list, and every client needs a release with a new root key before the last list expires. A compromised root key also requires a release of every client with a new root key.

## Changes per repository

### specifications

`registry/signed.proto` changes as above and `registry-v2.md` gets the verification steps and the freshness header. In `security/supply-chain/signing.md` the "Key Management" section is rewritten and the chain of trust comes off "Planned Improvements".

### hex_core

`hex_pb_signed` is regenerated. `hex_registry` signs with a list of signing keys plus the two `SignedKeys` binaries, builds and signs both lists, and verifies as above. `hex_core:default_config/0` replaces `repo_public_key` for hex.pm with the root public keys. Custom repositories are configured with root public keys or with `repo_public_key`. `hex_repo` passes the `x-hex-freshness` header to the verification.

### hex

Hex vendors the new hex_core, and `Hex.Repo` replaces `@hexpm_public_key` with the root keys. `Hex.Registry.Server` stores the lists, drops cached entries as described under client verification, and prints the retiring warning. It stores the payload hash of each cached entry for the freshness check on a `304`. It also gets error messages for an expired list, a revoked key and a missing or expired freshness header. `mix hex.repo add` and `mix hex.repo set` get `--root-key PATH`, which configures the repository with a root public key and can be given more than once. `mix hex.registry build` doesn't change.

### hexpm

`Storage.sign_and_gzip/1` signs with the configured signing keys, attaches both lists, and fills field 2 from the old RSA key while one is configured. `HEXPM_SIGNING_KEY` becomes optional in `config/runtime.exs`.

At boot hexpm checks that the intermediate key list verifies against the configured root public keys, that the signing key list verifies against the intermediate key list, and that it lists every configured signing key as active. It refuses to start otherwise. An expired list raises the alert and hexpm keeps running.

A job rebuilds every registry file and policy of every repository and purges the CDN. The public keys page lists the root keys and the revoked RSA key. `diff`, `preview` and `hexdocs` get the new hex_core.

### hexpm-ops

The new signing key gets its own Secret Manager secret, pinned next to `HEXPM_SIGNING_KEY` in `secret-versions.json` and added to `SIGNING_KEYS` in `bin/secret-recovery`. The signed lists aren't secret, so they're plain configuration per environment. Terraform creates the Google Cloud project and the KMS key for the intermediate key. One script signs a signing key list with the KMS key, another signs an intermediate key list with a YubiKey, and both verify the result. An alert fires 90 days before either list expires. The Fastly `repo` service gets the freshness key in its secret store. It computes the payload hash when a registry file enters its cache and adds the header to `200` and `304` responses, with `max-age` capped at the header's remaining validity. Staging gets its own root key, intermediate key, signing key and freshness key, and every step runs there first.

### Outside the hexpm organization

rebar3 vendors the new hex_core. Gleam needs the format and the freshness check in `gleam-lang/hexpm-rust` and the root keys in the compiler. Proxies have to pass the `x-hex-freshness` header through and honor `max-age`. Proxies that verify hex.pm's signature with the old key need the new format before the cutoff. Artifactory and Cloudsmith may be among them; that hasn't been checked. Mirrors that serve current files unchanged need no changes.

## This rotation

1. Generate the root key and import it into both YubiKeys. Generate the intermediate key, the new signing key and the freshness key. Sign intermediate key list version 1 with the root key and signing key list version 1 with the intermediate key.
2. Merge the specification and release hex_core with the root public keys.
3. Deploy hexpm so every file carries fields 3, 4 and 5, with field 2 still signed by the old RSA key. Deploy the Fastly `repo` service so responses carry the freshness header. Run the rebuild job and confirm the CDN serves the new files. Released clients keep working because they read only field 2.
4. Release Hex, rebar3 and Gleam with the root keys, and bump hex_core in `diff`, `preview` and `hexdocs`. These require fields 4 and 5 and the freshness header, so none of them ships before step 3 is confirmed. From their release on, upgraded clients reject files signed only with the old key.
5. Announce a cutoff date in the incident blog post and the user email.
6. At the cutoff, deploy hexpm without the old key and run the rebuild job. After no SecretSync resource, Pod or Job template references `hexpm-signing-key` version 1, destroy that version. Field 2 is then 256 zero bytes, which released clients reject through their ordinary bad-signature path. An absent field 2 would crash released hex_core on a failed map match in `decode_and_verify_signed/2`.

At the cutoff a released client fails on files it has to fetch. Hex prints its existing signature error, which points at https://hex.pm/docs/public_keys. Released Hex with a cached entry for a package prints "Failed to fetch record" and continues on the cached data (`Hex.Registry.Server.write_result/4`), so a project with a lock file and a warm cache keeps building until it needs a package or version it hasn't cached.

Clients that are never upgraded keep accepting signatures from the old key for as long as they run. Users on Elixir versions older than Hex main supports (`~> 1.12`) can only continue with `HEX_UNSAFE_REGISTRY=1`.
