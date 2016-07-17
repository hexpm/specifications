# Registry v2

*NOTE: This registry is not yet deployed on hex.pm*

The first version of the registry format used a single file for the entire registry. While this was efficient in the number of HTTP requests needed to resolve dependencies, the size of the registry would grow out of control as the repository grows.

The new version of the registry format is split into multiple files to make it scale as the repository grows with more packages.

For every package in the repository there is a package registry file under `/packages/[NAME]` in the repository, it contains all the releases of that package and all dependencies of the releases. There are also two index files `/names` and `/versions` that contains all package names and all package names+versions respectively.

## File formats

The files are serialized with [Protocol Buffers](https://developers.google.com/protocol-buffers/).

If you are on an Erlang system it is recommended to use the already generated files in [registry](https://github.com/hexpm/specifications/blob/master/registry). The files were generated with `gpb` 3.23.0 with the options below:

```elixir
[verify: :always,
 strings_as_binaries: true,
 maps: true,
 maps_unset_optional: :omitted]
```

### names.proto

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
}
```

### package.proto

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
