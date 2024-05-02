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

Individual releases can be retired. A retired release can still be used like any normal release, the only difference is that the particular release will be marked in the UI for the repository and a notice can be displayed to client users that are using that version.

A release is retired if the `retired` field is set on `Release`. A `RetirementStatus` has a `RetirementReason` enum with the reason for retiring the release, clients need to support future additions to this enum, in the protobuf library that generates the files under `registry/` unknown enum values are decoded as their integer value. A, user set, message can be attached to the `RetirementStatus` clarifying the reason for retirement.

It is important that clients still allow users to use retired releases to avoid breaking repeatable builds.

## Links

[1] https://tools.ietf.org/html/rfc7234#section-5.2
[2] https://tools.ietf.org/html/rfc7234#section-3.2
