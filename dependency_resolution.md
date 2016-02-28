# Dependency resolution

All Hex clients should resolve dependencies in the same way to minimize user confusion when switching between clients and to ensure they are compatible.

The registry has all information needed to resolve dependencies. For a dependency to resolve correctly a version has to be chosen that satisfies all [version requirements][] other dependencies has set on it.

Clients should try to create an optimal set of dependencies from the resolution. An optimal solution is one where the highest possible version of all dependencies are chose given the version requirements. If multiple optimal solutions exist any can be chosen.

Hex does not allow publishing packages with overriding dependencies, an overriding dependency is one where the version requirement of a dependency at a higher level overrides all other version requirements on that dependency. Note that clients are allowed to override dependencies at the top-level because that is outside the control of Hex.

A package can define *optional* dependencies, an optional dependency should only resolve if the top-level project also depends on it.

[version requirements]: http://elixir-lang.org/docs/stable/elixir/Version.html
