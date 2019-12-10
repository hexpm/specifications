# purl format for Hex

## Introduction

[purl or Package URL](https://github.com/package-url/purl-spec) is a
specification for identifying and locating software packages. It may be used
to uniquely identify a package or package version in a software
bill-of-materials (SBOM) or vulnerability report, or to locate the package in a
repository, e.g. to check for updates.

In particular, the [CycloneDX](https://cyclonedx.org) SBOM specification
uses purl to identify components.

This document formalizes the purl format for packages hosted on hex.pm or
compatible repositories. Like Hex itself, it applies equally to packages
written in/for Erlang, Elixir or any other BEAM language.

## Definition

* The 'type' is "hex"
* The default repository is https://repo.hex.pm
* The 'namespace' is optional; it may be used to specify the organization for
  private packages on hex.pm; it is not case sensitive and must be lowercased.
* The 'name' is the package name; it is not case sensitive and must be lowercased
* The 'version' is the package version
* Optional qualifiers:
  * 'repository_url' - used to select a non-default repository; it must contain
     the full base URL for the repository, not the short name that's used
     locally to select it; run 'mix help hex.repo' for more information on
     setting repository URLs
  * 'checksum' - as per purl specification

## Examples

The public "jason" package at version 1.1.2 would be identified by the
following purl:

    pkg:hex/jason@1.1.2

Version 2.3.4 of a package named "foo", published under the "acme" organization
on hex.pm would be identified by the following purl:

    pkg:hex/acme/foo@2.3.4

Other examples include:

    pkg:hex/bar@1.2.3?repository_url=https://myrepo.example.com
    pkg:hex/jason@1.1.2?checksum=sha256:fdf843bca858203ae1de16da2ee206f53416bbda5dc8c9e78f43243de4bc3afe
