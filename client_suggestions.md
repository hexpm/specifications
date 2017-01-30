# Client Suggestions

## General

  * Use the dependency resolution algorithm specified in [dependency_resolution.md](https://github.com/hexpm/specifications/blob/master/dependency_resolution.md).

## Security

  * Encrypt the local API key
  * Print package checksum when publishing or building package tarballs. When the user has the package checksum they can verify that it hasn't changed in the repository.
  * There should be an option to locally build a package tarball for users to verify the contents before publishing.
  * Check for checksum changes in existing packages when updating the registry (rogue repository).
  * Warn if the registry failed to update and a cached version is being used instead, also store both the new and the old registry for future reference (denying updates).

## Future

  * Check if the (signed) timestamp in registry is too old or in the future (replay attacks).
