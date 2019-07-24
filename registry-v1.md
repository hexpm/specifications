# ETS Registry

*NOTE: This registry format is deprecated in favor of the [new version](https://github.com/hexpm/specifications/blob/master/registry-v2.md)*

The registry is an ETS table serialized with [`ets:tab2file/1`][]. Clients
consuming the registry entries should always match on only the front of a list,
as new elements may be added to the tail in the future.

Below is the layout of the table.

  * `{'$$version$$', Version}` - the registry version
    - Version: integer, incremented on breaking changes

  * `{Package, [Versions]}` - all releases of a package
    - Package: binary string
    - Versions: list of [semver][] versions as binary strings

  * `{{Package, Version}, [Deps, InnerChecksum, BuildTools]}` - a package release's dependencies
    - Package: binary string
    - Version: binary string [semver][] version
    - Deps: list of dependencies [Dep1, Dep2, ..., DepN]
      - Dep: [Name, Requirement, Optional, App]
        - Name: binary package name
        - Requirement: binary Elixir [version requirement][]
        - Optional: boolean, true if it's an optional dependency
        - App: binary, OTP application name
    - InnerChecksum: binary hex encoded sha256 checksum of package, see [Package Tarball](https://github.com/hexpm/specifications/blob/master/package_tarball.md)
    - BuildTools: list of build tool names as binary strings

[`ets:tab2file/1`]: http://erlang.org/doc/man/ets.html#tab2file-2
[semver]: https://semver.org/
[version requirement]: https://hexdocs.pm/elixir/Version.html
