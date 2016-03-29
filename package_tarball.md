# Package tarball

The package tarball contains the following files:

  * VERSION

    The tarball version as a single ASCII integer.

  * metadata.config

    Erlang term file, see [Package metadata](https://github.com/hexpm/specifications/blob/master/package_metadata.md).

  * contents.tar.gz

    Gzipped tarball with package contents.

  * CHECKSUM

    sha256 hex-encoded checksum of the included tarball. The checksum is calculated by taking the contents of all files (except CHECKSUM), concatenating them, running sha256 over the concatenated data, and finally hex (base16) encoding it.

        contents = read_file("VERSION") + read_file("metadata.config") + read_file("content.tar.gz")
        checksum = sha256(contents)
        final_result = hex_encode(checksum)


## Deterministic Archives

The idea of "deterministic" or "reproducible" archives is to empower anyone to
verify that no flaws have been introduced during the publishing or download
phase by reproducing byte-for-byte identical Hex packages from a given source
tree.

Archives (both package tarball and contents.tar.gz) should be compressed in a
deterministic way. That means, given a package directory, two independent
packagers can verify that the source directory was the same by comparing
checksums of the archives.

### Motivation

With reproducible archives, users can declare exact checksums of their
dependencies, and be sure on what they are depending on. This allows:

1. If package dependencies are declared with a checksum besides name and
   version, mirrors of hex.pm no longer need to be trusted not to modify the
   packages. Even more, any distribution channel does not need to be trusted.
2. If the original tarball is lost ([precedent in npm in early 2016][1]), it
   can be byte-for-byte reconstructed from the source tree, with assurance it
   is exactly the same as before.
3. If the package contents are modified without bumping the version number, the
   package import will fail.

With reproducible archives, it is possible to declare a checksum of the
dependency besides just name and version. Declaring a dependency thus becomes:

1. Download the sources of the original dependency. This is the trusted copy
   (establishing the trust can happen by, e.g., verifying the GPG signature of
   the signed git tag).
2. Compress the dependency in a "deterministic" way. Write down the checksum.
3. Verify the archive has the same checksum as hex.pm.
4. Declare the dependency to the package by: name, version, checksum. Now, name
   and version are used to locate it, checksum is used to verify it.

Now we know what reproducible archives are for, how do we create them?

### How to create a reproducible archive

To be able to byte-by-byte compare the archives, their metadata must match. We
agreed on the following is the following properties for the tarballs:

* `uid=0`, `gid=0`.
* File modification time is `2001-09-09 01:46:40 UTC` (`1000000000 seconds`
  since unix epoch).
* Files inside the archive are sorted by name.

To achieve the above, we recommend and the following command-line to create the
tarball (requires GNU Tar 1.28+):

    tar --sort=name --mtime=@1000000000 --owner=0 --group=0 \
         --numeric-owner -cf contents.tar PACKAGE_DIR

Gzipping the tarball (requires GNU gzip):

    gzip -n contents.tar

Comparing the two archives:

    $ cmp contents.tar-downloaded contents.tar-compressed
    $ echo $?
    0

If they do not match, `cmp` will report:

    $ cmp contents.tar-downloaded contents.tar-compressed
    contents.tar-downloaded contents.tar-compressed differ: char 137, line 1
    $ echo $?
    1

### Next steps

Transition to reproducible archives will happen in a few phases:

1. Specification is approved and published. Clients that publish to hex.pm can
   start implementing the changes described above.
2. Information about archive reproducibility will be attached to metadata of
   every package (both in index and the website), so package consumers can
   start relying on the reproducible packages.
3. Hex.pm will issue a warning during the upload phase when an incompatible
   package is uploaded.
4. After a grace period, hex.pm might reject non-reproducible archives. This is
   still under discussion.

### Appendix: creating a reproducible package.

#### Linux

Use GNU coreutils and run the commands provided above.

#### OSx

Requires GNU Tar and GNU Gzip, which can be downloaded using [homebrew][2].
Working example as of 2016-03-29:

    brew install coreutils
    brew install homebrew/dupes/gzip

    /usr/local/bin/gtar --sort=name --mtime=@1000000000 --owner=0 --group=0 \
         --numeric-owner -cf contents.tar PACKAGE_DIR

    /usr/local/bin/gzip -k -n contents.osx.tar

#### FreeBSD

TODO

#### Windows

TODO

[1]: https://medium.com/@azerbike/i-ve-just-liberated-my-modules-9045c06be67c
[2]: http://brew.sh/
