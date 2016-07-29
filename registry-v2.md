# Registry v2

*NOTE: This registry is not yet deployed on hex.pm*

The first version of the registry format used a single resource for the entire registry. While this was efficient in the number of HTTP requests needed to resolve dependencies, the size of the registry would grow out of control as the repository grows.

The new version of the registry format is split into multiple resources to make it scale as the repository grows with more packages.

For every package in the repository there is a package registry resource under `/packages/[NAME]` in the repository, it contains all the releases of that package and all dependencies of the releases. There are also two index resources `/names` and `/versions` that contains all package names and all package names+versions respectively.

## Formats

The resources are serialized with [Protocol Buffers](https://developers.google.com/protocol-buffers/).

If you are on an Erlang system it is recommended to use the already generated files in [registry](https://github.com/hexpm/specifications/blob/master/registry). The files were generated with `gpb` 3.23.0 with the options below:

```elixir
[verify: :always,
 strings_as_binaries: true,
 maps: true,
 maps_unset_optional: :omitted]
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
  // Zero-based indexes of yanked versions in the versions field, see package.proto
  repeated int32 yanked = 3 [packed=true];
}
```

### package.proto

For the `/packages/[NAME]` resources.

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
  // If set the release is yanked, a yanked release should only be
  // resolved if it has already been locked in a project
  optional YankStatus yanked = 4;
}

message YankStatus {
  required YankReason reason = 1;
  optional string message = 2;
}

enum YankReason {
  YANKED_OTHER = 0;
  YANKED_INVALID = 1;
  YANKED_SECURITY = 2;
  YANKED_DEPRECATED = 3;
  YANKED_RENAMED = 4;
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

## Signing

All resources will be signed by the repository's private key. A signed resource is wrapped in a `Signed` message. The data under the `payload`
field is signed by the `signature` field.

The signature is an (unencoded) RSA signature of the (unencoded) SHA-512 digest of the payload.

Repositories are required to sign all registry resources.

## Release yanking

Individual releases can be yanked. A yanked release can still be used like any normal release, the only difference is that the particular release will be marked in the UI for the repository and a notice can be displayed to client users that are using that version.

A release is yanked if the `yanked` field is set on `Release`. A `YankStatus` has a `YankReason` enum with the reason for the yank, clients need to support future additions to this enum (gpb is getting support for this [1]). A, user set, message can be attached to the `YankStatus` clarifying the yank reason.

It is important that clients still allow users to use yanked releases to avoid breaking repeatable builds.

[1] https://github.com/tomas-abrahamsson/gpb/issues/69
