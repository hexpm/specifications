# Registry v2

The first version of the registry format used a single resource for the entire registry. While this was efficient in the number of HTTP requests needed to resolve dependencies, the size of the registry would grow out of control as the repository grows.

The new version of the registry format is split into multiple resources to make it scale as the repository grows with more packages.

For every package in the repository there is a package registry resource under `/packages/NAME` in the repository, it contains all the releases of that package and all dependencies of the releases. There are also two index resources `/names` and `/versions` that contains all package names and all package names+versions respectively.

## Formats

The resources are serialized with [Protocol Buffers](https://developers.google.com/protocol-buffers/).

If you are on an Erlang system it is recommended to use the already generated files in [registry](https://github.com/hexpm/specifications/blob/master/registry). The files were generated with `gpb` 3.23.0 with the options below:

```elixir
[verify: :always,
 strings_as_binaries: true,
 maps: true,
 maps_unset_optional: :omitted,
 report_warnings: true,
 target_erlang_version: 18]
```

### names.proto

For the `/names` resource.

```protobuf
message Names {
  // All packages in the repository
  repeated Package packages = 1;
}

message Package {
  // Package name
  required string name = 1;
  // If set, the package namespace
  optional string namespace = 2;
}
```

### versions.proto

For the `/versions` resource.

```protobuf
message Versions {
  // All packages in the repository
  repeated Package packages = 1;
}

message Package {
  // Package name
  required string name = 1;
  // All released versions of the package
  repeated string versions = 2;
  // Zero-based indexes of retired versions in the versions field, see package.proto
  repeated int32 retired = 3 [packed=true];
  // If set, the package namespace
  optional string namespace = 4;
}
```

### package.proto

For the `/packages/NAME` resources.

```protobuf
message Package {
  // All releases of the package
  repeated Release releases = 1;
}

message Release {
  // Release version
  required string version = 1;
  // sha256 checksum of package tarball
  required bytes checksum = 2;
  // All dependencies of the release
  repeated Dependency dependencies = 3;
  // If set the release is retired, a retired release should only be
  // resolved if it has already been locked in a project
  optional RetirementStatus retired = 4;
}

message RetirementStatus {
  required RetirementReason reason = 1;
  optional string message = 2;
}

enum RetirementReason {
  RETIRED_OTHER = 0;
  RETIRED_INVALID = 1;
  RETIRED_SECURITY = 2;
  RETIRED_DEPRECATED = 3;
  RETIRED_RENAMED = 4;
}

message Dependency {
  // Package name of dependency
  required string package = 1;
  // Version requirement of dependency
  required string requirement = 2;
  // If set and true the package is optional (see dependency resolution)
  optional bool optional = 3;
  // If set is the OTP application name of the dependency, if not set the
  // application name is the same as the package name
  optional string app = 4;
  // If set, the namespace where the dependency is located
  optional string namespace = 5;
}
```

### signed.proto

For signing, see below.

```protobuf
message Signed {
  // Signed contents
  required bytes payload = 1;
  // The signature
  optional bytes signature = 2;
}
```

### Additional notes

Depending on the repository configuration, the index resources `/names` and `/versions` may not include all packages. If the repository supports private package (such as hex.pm) they will not be included in the index resources, i.e. only public packages will be included in the index resources.

Due to some packages requiring authentication to be visible different users may have different views of some resources, because of this care needs to be taken when caching the resources. If the registry is served via HTTP the repository must set appropriate cache headers for public and private resources. On hex.pm the resources `/names`, `/versions` and all non-namespaced packages under `/packages/NAME` are public and can be cached. The namespaced resources may be private so the HTTP headers must be checked to know if the responses can be cached [1] [2].

## Signing

All resources will be signed by the repository's private key. A signed resource is wrapped in a `Signed` message. The data under the `payload`
field is signed by the `signature` field.

The signature is an (unencoded) RSA signature of the (unencoded) SHA-512 digest of the payload.

Repositories are required to sign all registry resources.

## Namespaces

Repositories may optionally support namespaces. A namespace can be seen as a sub-repository to the main repository. A namespace resource is prefixed `@` and the namespace name as a path segment, it should expose the following endpoints:

 * `/@NAMESPACE/names`
 * `/@NAMESPACE/versions`
 * `/@NAMESPACE/packages/NAME`

## Retiring Releases

Individual releases can be retired. A retired release can still be used like any normal release, the only difference is that the particular release will be marked in the UI for the repository and a notice can be displayed to client users that are using that version.

A release is retired if the `retired` field is set on `Release`. A `RetirementStatus` has a `RetirementReason` enum with the reason for retiring the release, clients need to support future additions to this enum, in the protobuf library that generates the files under `registry/` unknown enum values are decoded as their integer value. A, user set, message can be attached to the `RetirementStatus` clarifying the reason for retirement.

It is important that clients still allow users to use retired releases to avoid breaking repeatable builds.

## Links

[1] https://tools.ietf.org/html/rfc7234#section-5.2  
[2] https://tools.ietf.org/html/rfc7234#section-3.2  
