# Private packages

*NOTE! This is not implemented yet.*

Hex.pm supports private packages. A private package can only exist under a namespace but namespaces can also contain public packages.

Public packages can not depend on private packages. Private packages on the other hand can depend on other private packages if they exist in the same namespace.

Unlike public packages, a private package can be re-published or completely removed from the repository. It's still recommended to follow the immutability rules of public packages though.
