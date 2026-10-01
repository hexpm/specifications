# Package tarball

The package tarball contains the following files:

  * VERSION

    The tarball version as a single ASCII integer. The current tarball version is 3.

  * metadata.config

    Erlang term file, see [Package metadata](https://github.com/hexpm/specifications/blob/master/package_metadata.md).

  * contents.tar.gz

    Gzipped tarball with package contents.

  * CHECKSUM

    SHA-256 hex-encoded checksum of the included tarball. The checksum is calculated by taking the contents of all files (except CHECKSUM), concatenating them, running `sha256` over the concatenated data, and finally uppercase hex (`base16`) encoding it.

        contents = read_file("VERSION") + read_file("metadata.config") + read_file("content.tar.gz")
        checksum = sha256(contents)
        final_result = hex_encode(checksum)

    This checksum is called the "inner checksum" and is deprecated in favor of the "outer checksum" which is the SHA-256 checksum of the entirety of the tarball file.

    When fetching packages the checksums should be verified against checksums stored in the registry. See `Release.inner_checksum` and `Release.outer_checksum` in the [protobuf definitions](registry/package.proto).

## Reproducible tarballs

The following is recommended for tools that create package tarballs, so that creating a tarball from the same files with the same tool versions gives the same bytes. None of it is required, and different tools aren't expected to produce the same bytes as each other.

  * Write the entries of contents.tar.gz sorted by name, and the outer tarball's files in the order VERSION, CHECKSUM, metadata.config, contents.tar.gz.
  * Write file names in Unicode Normalization Form C (NFC).
  * Set the modification, access and change times of every entry to 2000-01-01T00:00:00Z, and the user and group IDs to 0.
  * Write regular files with mode 0644, or 0755 when the file is executable, directories with mode 0755 and symbolic links with mode 0777. Only write directory entries for empty directories.
  * Write the gzip header of contents.tar.gz without a file name and with MTIME and OS set to 0.
  * Write the keys of metadata.config, and the file names in its `files` field, in sorted order.
  * Record the names and versions of the tools in the `build_env` field of the [package metadata](package_metadata.md).
