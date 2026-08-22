# Registry v2

The first version of the registry format used a single resource for the entire registry. While this was efficient in the number of HTTP requests needed to resolve dependencies, the size of the registry would grow out of control as the repository grows.

The new version of the registry format is split into multiple resources to make it scale as the repository grows with more packages.

## Registry files

The following files hold information about the packages in the repository.

* `/names`
  * An index file that contains the names of all packages in the repository.
  * Encoded using protobuf schema [`Names`](/registry/names.proto).
* `/versions`
  * An index file that contains the names and versions of all packages in the repository.
  * Encoded using protobuf schema [`Versions`](/registry/versions.proto).
* `/packages/NAME`
  * This file exists for every package in the repository, it contains all the releases of that package and all dependencies of the releases.
  * Encoded using protobuf schema [`Package`](/registry/package.proto).
* `/repos/REPO/policies/NAME`
  * This file may exist for any organization repository, it contains a signed dependency policy that opted-in clients honor at resolution time. See [Dependency policies](#dependency-policies).
  * Encoded using protobuf schema [`Policy`](/registry/policy.proto).

All registry files are compressed using `gzip`.

## Formats

The resources are serialized with [Protocol Buffers](https://developers.google.com/protocol-buffers/).

The sources can be found in the [registry](/registry) directory.

If you are on an Erlang system it is recommended to use the already generated files in [hex_core](https://github.com/hexpm/hex_core/blob/main/src), they start with `hex_core_pb`.

### Additional notes

Depending on the repository configuration, the index resources `/names` and `/versions` may not include all packages. If the repository supports private package (such as hex.pm) they will not be included in the index resources, i.e. only public packages will be included in the index resources.

Due to some packages requiring authentication to be visible different users may have different views of some resources, because of this care needs to be taken when caching the resources. If the registry is served via HTTP the repository must set appropriate cache headers for public and private resources. On hex.pm the resources `/names`, `/versions` and all packages under `/packages/NAME` on the global "hexpm" repository are public and can be cached. Resources on other repositories may be private so the HTTP headers must be checked to know if the responses can be cached [1] [2].

## Signing

All resources will be signed by the repository's private key. A signed resource is wrapped in a `Signed` message. The data under the `payload` field is signed by the `signature` field.

The signature is an (unencoded) RSA signature of the (unencoded) SHA-512 digest of the payload.

Repositories are required to sign all registry resources.

## Decoding registry files

As described above all registry files are compressed, signed and encoded as protobuf. Below is pseudo code on how to deserialize the files:

```
# Fetch file
compressed_file = http_fetch("https://repo.hex.pm/packages/my_package")

# Decompress file
decompressed_file = gzip_decompress(compressed_file)

# Decode to protobuf schema Signed
# See registry/signed.proto
signed_message = protobuf_decode(decompressed_file, Signed)

# Verify signature for authenticity
verify_signature_rsa_sha512(signed_message.payload, signed_message.signature, hexpm_repo_public_key)

# Decode to protobuf schema Package
# See registry/package.proto
package_message = protobuf_decode(signed_message.payload, Package)

# Verify that package_message.repository matches the given repository name to ensure authenticity
package_message.repository == "hexpm"
```

A reference implementation of this pseudo code can be found in [hex_core](https://github.com/hexpm/hex_core/blob/main/src/hex_registry.erl).

## Cross-repository dependencies

Dependencies can be located in another repository than where the parent package is fetched from. If the `repository` field is not set on the `Dependency` message the dependency is located in the same repository as the package. The `repository` field just holds the name of the repository, it is up to clients to map these names to other repository locations, for example an HTTP URL.

The name for the official Hex.pm repository is "hexpm", it should not be used by any other repository and should always map to to the repository endpoint specified in [endpoints](/endpoints.md).

## Retiring Releases

Individual releases can be retired. Retirement is advisory metadata and does not remove the release from the registry.

A release is retired if the `retired` field is set on `Release`. A `RetirementStatus` has a `RetirementReason` enum and may include a message that clarifies the reason. Clients MUST accept future additions to `RetirementReason`; the protobuf library that generates the files under `registry/` decodes unknown enum values as their integer value.

Without an active dependency policy that rejects its current retirement reason, clients MUST NOT reject a release solely because it is retired. This preserves repeatable builds that already depend on the release.

## Dependency policies

A `Policy` is a signed resource published by an organization that opted-in clients honor at resolution time to filter the candidate set of package releases. Policies are optional and opt-in client-side; the registry server distributes them but does not enforce them.

The resource lives at `/repos/REPO/policies/NAME`, served by the same backend as `/packages/NAME`. `NAME` matches `^[a-z0-9][a-z0-9_\-\.]*[a-z0-9]$`, length 3..64, and is unique within the repository. The payload is the [`Policy`](/registry/policy.proto) protobuf message, signed and gzipped like every other registry resource (see [Signing](#signing)).

### Visibility

The `visibility` field controls who can fetch the resource:

* `VISIBILITY_PRIVATE` is served only to authenticated callers who can access the repository, using the same authentication rules as `/packages/NAME` on a private repository.
* `VISIBILITY_PUBLIC` is served to any caller, authenticated or not.

The auth decision is made per-object by inspecting the payload's `visibility` field; the path and signing model are identical in both cases. If the payload cannot be decoded because of a signature mismatch, unknown enum value, or missing required field, the edge MUST fail closed and require authentication.

### Repository policies

A policy carries a list of [`RepositoryPolicy`](/registry/policy.proto) entries, one per repository it constrains. Each candidate release is matched to the entry whose `repository` equals the release's repository. A release from a repository with no matching entry is unconstrained by the policy.

A matched entry has two parts, evaluated in this order for each candidate release `{repository, package, version}`:

1. **Overrides** (`overrides`) are package-scoped decisions and exceptions. A matching `OVERRIDE_ACTION_ALLOW` permits the release and bypasses every policy restriction; `OVERRIDE_ACTION_DENY` blocks it. When several ALLOW or DENY overrides match, the one with the most specific `requirement` wins (a `requirement`-bearing entry is more specific than a bare-package entry). If several matching overrides have equal specificity, the first one in `overrides` wins. If no final override decides the release, matching ADVISORY, RETIREMENT, and COOLDOWN overrides remove only their selected restriction.
2. **Restriction** (`restriction`) applies to every release that was not permitted or blocked by a final override. A release is blocked if any remaining limit fires.

A `PackageRef` matches a release when its `package` equals the release's package and, if `requirement` is set, the release's version satisfies that requirement using Hex version-requirement semantics.

Each `Override` action has a fail-closed field contract:

* `OVERRIDE_ACTION_ALLOW` and `OVERRIDE_ACTION_DENY` MUST set neither selector. ALLOW bypasses all policy restrictions, while DENY blocks the release.
* `OVERRIDE_ACTION_ADVISORY` MUST set `advisory_id` and MUST NOT set `retirement_reason`. The identifier matches the advisory's primary ID or any alias, case-insensitively. It removes only that advisory, so another advisory affecting the same release is still evaluated.
* `OVERRIDE_ACTION_RETIREMENT` MUST set `retirement_reason` and MUST NOT set `advisory_id`. It accepts the release only while its current retirement reason equals that value. If the retirement reason changes, the override no longer matches. The retirement message does not affect matching.
* `OVERRIDE_ACTION_COOLDOWN` MUST set neither selector. It bypasses only the cooldown declared by this policy.

Every override may carry an optional comment. Comments MUST contain at most 500 Unicode code points and MUST be valid UTF-8 without Unicode control, format, line separator, or paragraph separator characters. Comments on a `VISIBILITY_PUBLIC` policy are public.

Clients MUST ignore an override if it is malformed, has an unknown action or retirement reason, has an invalid package requirement, or sets selector fields that its action does not permit. An ignored override MUST NOT remove a restriction or otherwise accept the affected release.

#### Restriction limits

* `advisory_min_severity` is set and the release's maximum advisory severity is greater than or equal to it. It is an `AdvisorySeverity` (imported from [`package.proto`](/registry/package.proto), `SEVERITY_NONE` … `SEVERITY_CRITICAL`). `SEVERITY_NONE` blocks any release that has any advisory at all.
* `retirement_reasons` is non-empty and the release's `retired.reason` is one of the listed values. Each is a `RetirementReason` (imported from [`package.proto`](/registry/package.proto), `RETIRED_OTHER` … `RETIRED_RENAMED`).
* `cooldown` is set and non-zero and the release's `published_at` is more recent than `now - cooldown_duration`. The grammar is `"Nd"`, `"Nw"`, `"Nmo"`, or `"0"`; `"0"` (or unset) imposes no minimum age. A release without `published_at` does not trigger the cooldown.

## Links

[1] https://tools.ietf.org/html/rfc7234#section-5.2
[2] https://tools.ietf.org/html/rfc7234#section-3.2
