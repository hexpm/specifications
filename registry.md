# Registry

The registry is an ETS table serialized with [`ets:tab2file/1`][]. Clients
consuming the registry entries should always match on only the front of a list,
as new elements may be added to the tail in the future.

Below is the layout of the table.

  * `{'$$version$$', Version}` - the registry version
    - Version: integer, incremented on breaking changes

  * `{Package, [Versions]}` - all releases of a package
    - Package: binary string
    - Versions: list of [semver][] versions as binary strings

  * `{{Package, Version}, [Deps, Checksum, BuildTools]}` - a package release's dependencies
    - Package: binary string
    - Version: binary string [semver][] version
    - Deps: list of dependencies [Dep1, Dep2, ..., DepN]
      - Dep: [Name, Requirement, Optional, App, Source]
        - Name: binary package name
        - Requirement: binary Elixir [version requirement][]
        - Optional: boolean, true if it's an optional dependency
        - App: binary, OTP application name
        - Source: binary, URL to remote repository where package is located. It has two special values `"P"` and `"S"`, which are short for primary and self respectively. Primary means the package is located in the client's primary repository, in most clients that would be hex.pm. Self means the package is located in the same repository as this registry, repositories can use this value to guard against future changes of the repository URL 1)
    - Checksum: binary hex encoded sha256 checksum of package, see [Package Tarball](https://github.com/hexpm/specifications/blob/master/package_tarball.md)
    - BuildTools: list of build tool names as binary strings

1) The hex.pm repository will reject packages where this value is not `"P"`

[`ets:tab2file/1`]: http://www.erlang.org/doc/man/ets.html#tab2file-2
[semver]: http://semver.org/
[version requirement]: http://elixir-lang.org/docs/stable/elixir/Version.html
