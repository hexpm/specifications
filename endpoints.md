# Endpoints

The Hex API has two endpoints: an HTTP API, which is used for all administrative tasks and to browse packages; and a repository, which is read-only and used to deliver the registry and package tarballs.

## HTTP API

See [apiary.apib](https://github.com/hexpm/specifications/blob/master/apiary.apib) file at the root of this repository.

## Repository

### Endpoints

  * `/names` - [Registry v2](https://github.com/hexpm/specifications/blob/master/registry-v2.md)
  * `/versions` - [Registry v2](https://github.com/hexpm/specifications/blob/master/registry-v2.md)
  * `/packages/PACKAGE` - [Registry v2](https://github.com/hexpm/specifications/blob/master/registry-v2.md)
  * `/tarballs/PACKAGE-VERSION.tar` - [Package tarball](https://github.com/hexpm/specifications/blob/master/package_tarball.md)
  * `/docs/PACKAGE-VERSION.tar.gz` - (optional) Gzipped tarball containing documentation files for the package release
  * `/registry.ets.gz` - [Registry v1](https://github.com/hexpm/specifications/blob/master/registry-v1.md) (DEPRECATED!)
  * `/registry.ets.gz.signed` - (optional) (DEPRECATED!)
  * `/public_key` - (optional) Public key of the repository, see "Registry v1 signing" and "Registry v2 signing" sections below

### Registry authentication

The repository can require authentication for some resources. Token authentication with the `Authorization` header as described in the HTTP API should be used. Care needs to be taken by clients to *only* send the token to the actual repository, when untrusted mirrors are used authentication must be disabled.

### Registry v1 signing

A repository can optionally sign its registry. The public key should be provided to clients out-of-band of the registry fetching, for example by shipping the client with a public key or by users manually installing it. The repository signs the SHA-512 digest of the registry and base 16 encodes it with lower case characters. The repository should store the signature on the `/registry.ets.gz.signed` and update it when the registry is updated. For performance reasons the signature can also be provided in either the `x-hex-signature` or the `x-amz-meta-signature` header on the `/registry.ets.gz` endpoint.

### Registry v2 signing

The signing is defined in the registry v2 specification as it is not part of the resource delivery.

### Mirroring

The repository can be mirrored by setting up a caching proxy in front of it. All repository endpoints support standard HTTP caching headers including `ETag` and `Last-Modified` for conditional requests. A mirror should:

  * Proxy all requests to the upstream repository (e.g., `https://repo.hex.pm`)
  * Respect `Cache-Control` headers from the upstream
  * Support conditional requests (`If-None-Match`, `If-Modified-Since`) to minimize bandwidth

Since the registry is signed, mirrors do not need to be trusted, clients can verify the authenticity of registry data using the repository's public key.

Note: Private repository endpoints (`/repos/REPO/*`) require authentication and should not be mirrored on public infrastructure.

## Hex.pm

Hex.pm uses the following root endpoints:

  * HTTP API - https://hex.pm/api
  * Repository - https://repo.hex.pm

### Private repositories

Hex.pm supports private repositories for organizations, they can be accessed at the following endpoints, where `REPO` is the repository name:

  * `/repos/REPO/names`
  * `/repos/REPO/versions`
  * `/repos/REPO/packages/PACKAGE`
  * `/repos/REPO/tarballs/PACKAGE-VERSION.tar`
  * `/repos/REPO/docs/PACKAGE-VERSION.tar.gz` - (optional)

### Private key

Go to https://hex.pm/docs/public_keys to get Hex.pm's public key used to sign the registry.

## Client Implementation Reference

This section documents which endpoints are required to implement common Hex client operations.

### Dependency Resolution

Used by: `mix deps.get`, `mix deps.update`, `rebar3 get-deps`, `gleam add`

| Type | Endpoint | Purpose |
|------|----------|---------|
| Repo | `/names` | List all package names (optional, for full registry sync) |
| Repo | `/versions` | List all package versions with retirement info (optional) |
| Repo | `/packages/PACKAGE` | Get package releases, dependencies, and checksums |
| Repo | `/tarballs/PACKAGE-VERSION.tar` | Download package tarball |

The registry endpoints return signed protobuf data as specified in [Registry v2](registry-v2.md).

### Package Publishing

Used by: `mix hex.publish`, `rebar3 hex publish`, `gleam publish`

| Type | Endpoint | Purpose |
|------|----------|---------|
| API | `POST /publish` | Publish package and docs (combined endpoint) |
| API | `POST /packages/NAME/releases` | Publish a new release |
| API | `POST /packages/NAME/releases/VERSION/docs` | Publish documentation |
| API | `DELETE /packages/NAME/releases/VERSION` | Revert a release |
| API | `DELETE /packages/NAME/releases/VERSION/docs` | Revert documentation |
| API | `GET /packages/NAME` | Check if package exists |
| API | `GET /users/me` | Get current user (for new packages) |
| API | `PUT /packages/NAME/owners/USERNAME` | Add first owner (for new packages) |

### Package Retirement

Used by: `mix hex.retire`, `rebar3 hex retire`, `gleam retire`

| Type | Endpoint | Purpose |
|------|----------|---------|
| API | `POST /packages/NAME/releases/VERSION/retire` | Retire a release |
| API | `DELETE /packages/NAME/releases/VERSION/retire` | Unretire a release |

### Package Ownership

Used by: `mix hex.owner`, `rebar3 hex owner`, `gleam owner`

| Type | Endpoint | Purpose |
|------|----------|---------|
| API | `GET /packages/NAME/owners` | List owners |
| API | `GET /packages/NAME/owners/USERNAME` | Get owner details |
| API | `PUT /packages/NAME/owners/USERNAME` | Add or transfer owner |
| API | `DELETE /packages/NAME/owners/USERNAME` | Remove owner |

### Authentication

**OAuth2 Device Authorization** (used by: `mix hex.user auth`, `gleam authenticate`):

| Type | Endpoint | Purpose |
|------|----------|---------|
| API | `POST /oauth/device_authorization` | Start device authorization flow |
| API | `POST /oauth/token` | Poll for token / refresh token |
| API | `POST /oauth/revoke` | Revoke token |
| API | `POST /oauth/revoke_by_hash` | Revoke token by hash |

**API Key Generation** (used by: `rebar3 hex user auth`):

| Type | Endpoint | Purpose |
|------|----------|---------|
| API | `POST /keys` | Create API key (with Basic Auth) |

### API Key Management

Used by: `mix hex.organization key`, `rebar3 hex user key`, `rebar3 hex organization key`

| Type | Endpoint | Purpose |
|------|----------|---------|
| API | `GET /keys` | List keys |
| API | `GET /keys/NAME` | Get specific key |
| API | `POST /keys` | Create key |
| API | `DELETE /keys/NAME` | Delete key |
| API | `DELETE /keys` | Delete all keys |
| API | `GET /auth` | Test key permissions |

For organization keys, use `/orgs/ORG/keys` instead.

### Package Information

Used by: `mix hex.info`, `mix hex.search`, `rebar3 pkgs`, `rebar3 hex search`

| Type | Endpoint | Purpose |
|------|----------|---------|
| API | `GET /packages/NAME` | Get package metadata |
| API | `GET /packages/NAME/releases/VERSION` | Get release details |
| API | `GET /packages?search=QUERY` | Search packages |

### SBoM Generation

Used by: `mix sbom.cyclonedx`, ORT (OSS Review Toolkit)

| Type | Endpoint | Purpose |
|------|----------|---------|
| API | `GET /packages/NAME` | Get package metadata (licenses, links, description, owners) |
| API | `GET /packages/NAME/releases/VERSION` | Get release checksum for source artifact verification |
| API | `GET /users/NAME` | Get author details (full name, email) from package owners |
| Repo | `/tarballs/PACKAGE-VERSION.tar` | Download source tarball |

### Documentation Download

Used by: `mix hex.docs`

| Type | Endpoint | Purpose |
|------|----------|---------|
| Repo | `/docs/PACKAGE-VERSION.tar.gz` | Download documentation tarball |
| API | `GET /packages/NAME` | Get package info to find latest version |

### User Management

Used by: `rebar3 hex user register`, `rebar3 hex user reset_password`

| Type | Endpoint | Purpose |
|------|----------|---------|
| API | `POST /users` | Create new user account |
| API | `GET /users/NAME` | Get user information |
| API | `GET /users/me` | Get authenticated user |
| API | `POST /users/NAME/reset` | Request password reset |
