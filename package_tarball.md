# Package tarball

The package tarball contains the following files:

  * VERSION

    The tarball version as a single ASCII integer.

  * metadata.config

    Erlang term file, see [Package metadata](https://github.com/hexpm/specifications/blob/master/package_metadata.md).

  * contents.tar.gz

    Gzipped tarball with package contents.

  * CHECKSUM

    SHA-256 hex-encoded checksum of the included tarball. The checksum is calculated by taking the contents of all files (except CHECKSUM), concatenating them, running `sha256` over the concatenated data, and finally hex (`base16`) encoding it.

        contents = read_file("VERSION") + read_file("metadata.config") + read_file("content.tar.gz")
        checksum = sha256(contents)
        final_result = hex_encode(checksum)

    This checksum is called the "inner checksum" and is deprecated in favor of the "outer checksum" which is the SHA-256 checksum of the entirety of the tarball file.

    When fetching packages the checksums should be verified against checksums stored in the registry. See `Release.inner_checksum` and `Release.outer_checksum` in the [protobuf definitions](registry/package.proto).
