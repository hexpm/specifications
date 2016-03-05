# Endpoints

The Hex API has two endpoints: an HTTP API, which is used for all administrative tasks and to browse packages; and a repository, which is read-only and used to deliver the registry and package tarballs.

### HTTP API

See [apiary.apib](https://github.com/hexpm/specifications/blob/master/apiary.apib) file at the root of this repository.

### Repository

  * `/registry.ets.gz` - [Registry](https://github.com/hexpm/specifications/blob/master/registry.md)
  * `/registry.ets.gz.signed` - (optional)
  * `/tarballs/PACKAGE-VERSION.tar` - [Package tarball](https://github.com/hexpm/specifications/blob/master/package_tarball.md)

#### Registry signing

A repository can optionally RSA sign its registry. The RSA public key should be provided to clients out-of-band of the registry fetching, for example by shipping the client with a public key or by users manually installing it. The repository signs the sha512 digest of the registry and base 16 encodes it with lower case characters. The repository should store the signature on the `/registry.ets.gz.signed` and update it when the registry is updated. For performance reasons the signature can also be provided in either the `x-hex-signature` or the `x-amz-meta-signature` header on the `/registry.ets.gz` endpoint.

### Hex.pm endpoints

Hex.pm uses the following root endpoints:

  * HTTP API - https://hex.pm/api
  * Repository - https://s3.amazonaws.com/s3.hex.pm
