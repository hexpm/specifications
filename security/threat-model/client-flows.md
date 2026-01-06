# Client Flows

This document describes how package manager clients interact with the Hex ecosystem, including API calls, caching behavior, and verification flows.

## Client Architecture Overview

```mermaid
C4Context
    title Client Library Architecture

    Person(dev, "Developer", "Runs build commands")

    Boundary(elixir_erlang, "Elixir/Erlang Clients") {
        System(mix, "Mix", "Elixir build tool")
        System(rebar3, "Rebar3", "Erlang build tool")
        System(hex_client, "Hex Client", "hexpm/hex - Mix integration")
        System(hex_core, "Hex Core", "hexpm/hex_core - Core library")
        System(hex_solver, "Hex Solver", "hexpm/hex_solver - Version resolver")
    }

    Boundary(gleam_client, "Gleam Client") {
        System(gleam, "Gleam", "Gleam build tool")
        System(hexpm_rust, "hexpm-rust", "gleam-lang/hexpm-rust - Rust Hex client")
    }

    System_Ext(hexpm, "hex.pm", "Package registry")

    Rel(dev, mix, "mix deps.get")
    Rel(dev, rebar3, "rebar3 compile")
    Rel(dev, gleam, "gleam build")

    Rel(mix, hex_client, "Uses")
    Rel(hex_client, hex_core, "Uses")
    Rel(hex_client, hex_solver, "Uses")
    Rel(rebar3, hex_core, "Uses directly")

    Rel(gleam, hexpm_rust, "Uses")

    Rel(hex_core, hexpm, "HTTPS", "Registry + tarballs")
    Rel(hexpm_rust, hexpm, "HTTPS", "Registry + tarballs")

    UpdateLayoutConfig($c4ShapeInRow="3", $c4BoundaryInRow="2")
```

---

## 1. Mix (Elixir) Dependency Installation

Command: `mix deps.get`

### Authentication

Mix/Hex uses OAuth2 Device Authorization Grant ([RFC 8628](https://datatracker.ietf.org/doc/html/rfc8628)) for interactive authentication. OAuth tokens have read-only permissions by default; write operations require 2FA. API keys can still be used directly, especially for CI environments. See [OAuth2 Device Authorization Grant](#6-oauth2-device-authorization-grant) for details.

### Cache Locations

| Cache | Path | Contents |
|-------|------|----------|
| Registry | `~/.hex/cache.ets` | ETS file with package versions, deps, checksums |
| Packages | `~/.hex/packages/hexpm/{package}-{version}.tar` | Downloaded tarballs |
| Config | `~/.hex/hex.config` | OAuth tokens, API keys |
| ETags | Inside `cache.ets` | `{:registry_etag, repo, package}` |

Environment variable `HEX_HOME` overrides the default `~/.hex` location.

### Sequence Diagram

```mermaid
sequenceDiagram
    autonumber
    participant Dev as Developer
    participant Mix as Mix
    participant Hex as Hex Client
    participant HexCore as Hex Core
    participant Solver as Hex Solver
    participant Cache as Local Cache<br/>~/.hex/
    participant CDN as Fastly CDN
    participant S3 as S3 Storage
    participant API as hex.pm API

    Dev->>Mix: mix deps.get
    Mix->>Hex: converge(deps, lock)

    Note over Hex,Cache: Registry Initialization
    Hex->>Cache: Open cache.ets
    Cache-->>Hex: ETS table reference

    Note over Hex,API: Authentication Check (for authenticated operations)
    Hex->>Cache: Read hex.config
    alt Has OAuth Token
        Hex->>Hex: Check token expiry (expires within 5 min?)
        opt Token Expired or Expiring Soon
            Hex->>API: POST /oauth/token<br/>grant_type=refresh_token
            API-->>Hex: New access_token + refresh_token
            Hex->>Cache: Update hex.config
        end
    else Has API Key
        Note over Hex: Use API key directly
    end

    Note over Hex,S3: Registry Prefetch
    Hex->>HexCore: get_package(repo, name, etag)

    loop For each dependency
        HexCore->>Cache: Get cached ETag
        Cache-->>HexCore: ETag or nil

        HexCore->>CDN: GET /packages/{name}<br/>If-None-Match: {etag}

        alt Cache Hit (304 Not Modified)
            CDN-->>HexCore: 304 Not Modified
            HexCore->>Cache: Use cached data
        else Cache Miss (200 OK)
            CDN->>S3: Fetch from origin
            S3-->>CDN: Signed protobuf (gzip)
            CDN-->>HexCore: 200 OK + ETag

            Note over HexCore: Verify RSA-SHA512 signature
            HexCore->>HexCore: gunzip → decode Signed protobuf
            HexCore->>HexCore: verify(payload, signature, public_key)

            alt Signature Invalid
                HexCore-->>Hex: {error, bad_signature}
                Hex-->>Mix: Abort with security error
            end

            HexCore->>Cache: Store package data + ETag
        end
    end

    Note over Hex,Solver: Dependency Resolution
    Hex->>Solver: resolve(requirements)
    Solver->>Cache: Read versions, deps from cache
    Solver->>Solver: Find optimal version set
    Solver-->>Hex: Resolved versions

    Note over Hex,S3: Package Download
    loop For each resolved package
        Hex->>Cache: Check ~/.hex/packages/{repo}/{name}-{version}.tar
        alt Cached & checksum matches
            Cache-->>Hex: Use cached tarball
        else Not cached or checksum mismatch
            Hex->>HexCore: get_tarball(repo, name, version)
            HexCore->>CDN: GET /tarballs/{name}-{version}.tar
            CDN->>S3: Fetch tarball
            S3-->>CDN: Package tarball
            CDN-->>HexCore: Tarball bytes

            Note over HexCore: Verify outer checksum (SHA-256)
            HexCore->>HexCore: SHA256(tarball) == registry.outer_checksum?

            alt Checksum Mismatch
                HexCore-->>Hex: {error, checksum_mismatch}
                Hex-->>Mix: Abort - possible tampering
            end

            HexCore-->>Hex: Tarball bytes
            Hex->>Cache: Save to packages/{repo}/
        end

        Hex->>Hex: Extract tarball to deps/{app}/
    end

    Hex->>Mix: Updated lock
    Mix->>Mix: Write mix.lock
    Mix-->>Dev: Dependencies fetched
```

### Error Handling

```mermaid
sequenceDiagram
    participant Hex as Hex Client
    participant Cache as Local Cache
    participant CDN as Fastly CDN

    Note over Hex,CDN: Registry Update Failure
    Hex->>CDN: GET /packages/{name}
    CDN-->>Hex: Network error / timeout

    Hex->>Cache: Check for cached registry
    alt Cache exists
        Cache-->>Hex: Cached registry data
        Hex->>Hex: ⚠️ Warn user: using cached registry
        Note over Hex: Continue with cached data
    else No cache
        Hex-->>Hex: ❌ Abort: cannot resolve dependencies
    end
```

---

## 2. Rebar3 (Erlang) Dependency Installation

Command: `rebar3 compile` (with hex plugin)

### Authentication

Rebar3 uses basic authentication to generate API keys. Unlike Mix/Hex and Gleam, it does not support OAuth2 Device Authorization Grant.

### Cache Locations

| Cache | Path | Contents |
|-------|------|----------|
| Registry | `~/.cache/rebar3/hex/hexpm/registry/` | Registry protobuf files |
| Packages | `~/.cache/rebar3/hex/hexpm/packages/` | Downloaded tarballs |
| Config | `~/.config/rebar3/hex.config` | API keys |
| Lock | `rebar.lock` | Resolved versions with checksums |

### Sequence Diagram

```mermaid
sequenceDiagram
    autonumber
    participant Dev as Developer
    participant Rebar as Rebar3
    participant HexCore as Hex Core<br/>(hex_core)
    participant Cache as Local Cache<br/>~/.cache/rebar3/hex/
    participant CDN as Fastly CDN
    participant S3 as S3 Storage

    Dev->>Rebar: rebar3 compile
    Rebar->>Rebar: Parse rebar.config

    Note over Rebar,S3: Registry Fetch
    Rebar->>HexCore: hex_repo:get_versions(Config)
    HexCore->>CDN: GET /versions
    CDN->>S3: Fetch (if not cached)
    S3-->>CDN: Signed protobuf (gzip)
    CDN-->>HexCore: Versions data

    Note over HexCore: Verify signature
    HexCore->>HexCore: gunzip → verify RSA-SHA512
    HexCore-->>Rebar: Package versions list

    loop For each dependency
        Rebar->>HexCore: hex_repo:get_package(Config, Name)
        HexCore->>Cache: Check ETag
        HexCore->>CDN: GET /packages/{name}<br/>If-None-Match: {etag}

        alt 304 Not Modified
            CDN-->>HexCore: Use cache
        else 200 OK
            CDN-->>HexCore: Package metadata
            HexCore->>HexCore: Verify signature
            HexCore->>Cache: Store + ETag
        end
        HexCore-->>Rebar: Package releases & deps
    end

    Note over Rebar: Dependency Resolution
    Rebar->>Rebar: Resolve version constraints

    Note over Rebar,S3: Download Packages
    loop For each resolved package
        Rebar->>Cache: Check packages/{name}-{version}.tar
        alt Not cached
            Rebar->>HexCore: hex_repo:get_tarball(Config, Name, Version)
            HexCore->>CDN: GET /tarballs/{name}-{version}.tar
            CDN->>S3: Fetch tarball
            S3-->>CDN: Package tarball
            CDN-->>HexCore: Tarball

            Note over HexCore: Verify SHA-256 checksum
            HexCore->>HexCore: Unpack & verify checksums
            HexCore-->>Rebar: Package contents

            Rebar->>Cache: Cache tarball
        end
        Rebar->>Rebar: Extract to _build/
    end

    Rebar->>Rebar: Write rebar.lock
    Rebar->>Rebar: Compile dependencies
    Rebar-->>Dev: Build complete
```

---

## 3. Gleam Dependency Installation

Command: `gleam build`

### Authentication

Gleam uses OAuth2 Device Authorization Grant ([RFC 8628](https://datatracker.ietf.org/doc/html/rfc8628)) for interactive authentication. OAuth tokens have read-only permissions by default; write operations require 2FA. API keys can be used via the `HEXPM_API_KEY` environment variable for CI environments. See [OAuth2 Device Authorization Grant](#6-oauth2-device-authorization-grant) for details.

### Cache Locations

| Cache | Path | Contents |
|-------|------|----------|
| Packages | `~/.cache/gleam/hex/hexpm/packages/` | Downloaded tarballs |
| Credentials | `~/.cache/gleam/hex/hexpm/credentials` | OAuth refresh token (encrypted with user passphrase) |
| Build | `./build/` | Compiled packages |
| Manifest | `manifest.toml` | Resolved versions with checksums |

### Sequence Diagram

```mermaid
sequenceDiagram
    autonumber
    participant Dev as Developer
    participant Gleam as Gleam
    participant HexRust as hexpm-rust
    participant CDN as Fastly CDN
    participant S3 as S3 Storage

    Dev->>Gleam: gleam build
    Gleam->>Gleam: Parse gleam.toml

    Note over Gleam,S3: Fetch Version Index
    Gleam->>HexRust: get_versions_request()
    HexRust->>CDN: GET /versions
    CDN->>S3: Fetch (if not cached)
    S3-->>CDN: Signed protobuf (gzip)
    CDN-->>HexRust: Compressed response

    Note over HexRust: Verify signature (ring crate)
    HexRust->>HexRust: gunzip → decode Signed protobuf
    HexRust->>HexRust: RSA-PKCS1-SHA512 verify
    HexRust-->>Gleam: All package versions

    loop For each dependency
        Gleam->>HexRust: get_package_request(name)
        HexRust->>CDN: GET /packages/{name}
        CDN-->>HexRust: Package metadata (signed)

        HexRust->>HexRust: Verify signature
        HexRust-->>Gleam: Releases & dependencies
    end

    Note over Gleam: Version Resolution
    Gleam->>Gleam: Resolve constraints (PubGrub algorithm)

    Note over Gleam,S3: Download Packages
    loop For each resolved package
        Gleam->>HexRust: get_tarball_request(name, version)
        HexRust->>CDN: GET /tarballs/{name}-{version}.tar
        CDN->>S3: Fetch tarball
        S3-->>CDN: Package tarball
        CDN-->>HexRust: Tarball bytes

        Note over HexRust: Verify SHA-256 checksum
        HexRust->>HexRust: SHA256(tarball) == expected?

        alt Checksum Mismatch
            HexRust-->>Gleam: IncorrectChecksum error
            Gleam-->>Dev: ❌ Abort - integrity failure
        end

        HexRust-->>Gleam: Verified tarball
        Gleam->>Gleam: Extract to build/packages/
    end

    Gleam->>Gleam: Write manifest.toml
    Gleam->>Gleam: Compile Gleam + Erlang
    Gleam-->>Dev: Build complete
```

---

## 4. Package Publishing

Command: `mix hex.publish`, `rebar3 hex publish`, or `gleam publish`

### Authentication for Publishing

Publishing requires write permissions:

| Client | Authentication Method | 2FA Requirement |
|--------|----------------------|-----------------|
| Mix/Hex | OAuth token or API key | Required for OAuth tokens |
| Gleam | OAuth token or API key | Required for OAuth tokens |
| Rebar3 | API key (via basic auth) | Not supported |

For OAuth tokens, write operations prompt for a 2FA code which is sent via the `x-hex-otp` header.

### Sequence Diagram

```mermaid
sequenceDiagram
    autonumber
    participant Dev as Developer
    participant Client as Hex Client
    participant Local as Local Filesystem
    participant API as hex.pm API
    participant S3 as S3 Storage
    participant Worker as Registry Worker

    Dev->>Client: mix hex.publish / gleam publish

    Note over Client,Local: Build Tarball
    Client->>Local: Read source files
    Client->>Client: Generate metadata.config
    Client->>Client: Create contents.tar.gz
    Client->>Client: Calculate inner checksum (SHA-256)
    Client->>Client: Write CHECKSUM file
    Client->>Client: Create outer tarball

    Note over Client: Tarball structure:<br/>VERSION (3)<br/>metadata.config<br/>contents.tar.gz<br/>CHECKSUM

    Note over Client,API: Authentication
    Client->>Client: Read credentials from config
    alt Has OAuth Token
        Client->>Client: Check token expiry
        opt Token Expired
            Client->>API: POST /oauth/token (refresh_token grant)
            API-->>Client: New access_token + refresh_token
        end
        Client->>Dev: Prompt for 2FA code
        Dev-->>Client: TOTP code
    else Has API Key
        Note over Client: Use API key directly
        opt 2FA Enabled on Account
            Client->>Dev: Prompt for 2FA code
            Dev-->>Client: TOTP code
        end
    else No Credentials
        Note over Client: Initiate OAuth Device Flow
        Client->>API: See OAuth2 Device Authorization Grant section
    end

    Note over Client,S3: Upload Package
    Client->>API: POST /api/publish<br/>Authorization: {token}<br/>x-hex-otp: {2fa_code}<br/>Body: tarball

    API->>API: Validate tarball structure
    API->>API: Verify checksums
    API->>API: Check package ownership
    API->>API: Validate version (semver)

    alt Validation Failed
        API-->>Client: 422 Unprocessable Entity
        Client-->>Dev: ❌ Publish failed: {reason}
    end

    API->>S3: Store tarball at /tarballs/{name}-{version}.tar
    S3-->>API: Stored

    API->>API: Insert release into database
    API->>Worker: Trigger registry rebuild

    Worker->>Worker: Rebuild /names protobuf
    Worker->>Worker: Rebuild /versions protobuf
    Worker->>Worker: Rebuild /packages/{name} protobuf
    Worker->>Worker: Sign all with RSA-SHA512
    Worker->>Worker: Gzip compress
    Worker->>S3: Upload registry files

    API-->>Client: 201 Created
    Client-->>Dev: ✓ Package published

    Note over Dev: Optional: Publish docs
    Dev->>Client: mix hex.docs (automatic)
    Client->>Client: Generate documentation
    Client->>API: POST /api/packages/{name}/releases/{version}/docs<br/>Body: docs.tar.gz
    API->>S3: Store at hexdocs path
    API-->>Client: 201 Created
```

---

## 5. Private Package Flow

For organizations with private packages on hex.pm.

### Endpoints

Private packages use repository-scoped endpoints:

| Endpoint | Description |
|----------|-------------|
| `/repos/{org}/names` | Package names in organization |
| `/repos/{org}/versions` | Package versions in organization |
| `/repos/{org}/packages/{name}` | Package metadata |
| `/repos/{org}/tarballs/{name}-{version}.tar` | Package tarball |

### Sequence Diagram

```mermaid
sequenceDiagram
    autonumber
    participant Dev as Developer
    participant Client as Hex Client
    participant Cache as Local Cache
    participant CDN as Fastly CDN
    participant API as hex.pm

    Note over Dev,API: Private Package Fetch

    Dev->>Client: mix deps.get

    Note over Client: Check repository config
    Client->>Client: Read repo config from mix.exs
    Client->>Client: Identify private repos (org: "mycompany")

    Note over Client,API: Authenticate for private repo
    Client->>Cache: Read auth_key for "mycompany" org
    Cache-->>Client: auth_key

    alt OAuth exchange enabled (default for hex.pm)
        Client->>API: POST /oauth/token<br/>grant_type=client_credentials<br/>Authorization: {auth_key}
        API-->>Client: Short-lived access_token
        Client->>Cache: Store token + expiry for org
    end

    Client->>CDN: GET /repos/mycompany/packages/{name}<br/>Authorization: Bearer {access_token}

    Note over CDN: Private packages NOT cached<br/>(per-user authorization)
    CDN->>API: Forward with auth
    API->>API: Verify API key has repo access
    API-->>CDN: 200 OK + Package data (signed)
    CDN-->>Client: Package metadata

    Client->>Client: Verify signature

    Note over Client,API: Download private tarball
    Client->>CDN: GET /repos/mycompany/tarballs/{name}-{version}.tar<br/>Authorization: {api_key}
    CDN->>API: Forward with auth
    API-->>CDN: Tarball
    CDN-->>Client: Tarball

    Client->>Client: Verify checksum
    Client->>Cache: Store in ~/.hex/packages/mycompany/

    Client-->>Dev: Private dependency fetched
```

### Security: Untrusted Mirrors

```mermaid
sequenceDiagram
    participant Client as Hex Client
    participant Mirror as Untrusted Mirror
    participant Hexpm as hex.pm

    Note over Client,Hexpm: ⚠️ CRITICAL: Never send credentials to untrusted mirrors

    Client->>Client: Check mirror configuration
    Client->>Client: mirror = "https://mirror.example.com"

    alt Public Package
        Client->>Mirror: GET /packages/{name}<br/>(NO Authorization header)
        Mirror-->>Client: Package metadata
        Client->>Client: Verify signature with hex.pm public key
    else Private Package
        Note over Client: Private packages MUST use trusted endpoint
        Client->>Hexpm: GET /repos/{org}/packages/{name}<br/>Authorization: {api_key}
        Hexpm-->>Client: Package metadata
    end
```

---

## 6. OAuth2 Device Authorization Grant

Mix/Hex and Gleam use [RFC 8628 OAuth2 Device Authorization Grant](https://datatracker.ietf.org/doc/html/rfc8628) for interactive authentication. This flow is designed for CLI tools that cannot easily handle browser redirects.

### Supported Clients

| Client | OAuth Support | Fallback |
|--------|--------------|----------|
| Mix/Hex | Yes (default) | API keys via `HEX_API_KEY` |
| Gleam | Yes (default) | API keys via `HEXPM_API_KEY` |
| Rebar3 | No | Basic auth for API key generation |

### OAuth Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/oauth/device_authorization` | POST | Initiate device flow |
| `/oauth/token` | POST | Exchange codes for tokens / refresh tokens |
| `/oauth/revoke` | POST | Revoke tokens |

### Token Properties

| Property | Value |
|----------|-------|
| Access token lifetime | Short-lived (configurable) |
| Refresh token lifetime | Long-lived |
| Default scope | `api` (includes write permissions) |
| Write operations | Require 2FA via `x-hex-otp` header |

### Sequence Diagram

```mermaid
sequenceDiagram
    autonumber
    participant Dev as Developer
    participant Client as CLI Client
    participant Browser as Web Browser
    participant API as hex.pm API

    Dev->>Client: mix hex.user auth / gleam hex authenticate

    Note over Client,API: Step 1: Device Authorization Request
    Client->>API: POST /oauth/device_authorization<br/>client_id={client_id}<br/>name={client_name}
    API-->>Client: device_code, user_code,<br/>verification_uri, expires_in, interval

    Note over Client,Browser: Step 2: User Verification
    Client->>Dev: Display: "Your verification code: XXXXXXXX"
    Client->>Dev: "Press Enter to open browser..."
    Dev->>Client: [Enter]
    Client->>Browser: Open verification_uri

    Note over Dev,API: Step 3: User Authorizes in Browser
    Dev->>Browser: Navigate to verification page
    Browser->>API: GET /oauth/device
    API-->>Browser: Enter code form
    Dev->>Browser: Enter user_code
    Browser->>API: POST /oauth/device
    API-->>Browser: Authorization consent screen
    Dev->>Browser: Approve scopes
    Browser->>API: POST /oauth/device/authorize
    API-->>Browser: Success page

    Note over Client,API: Step 4: Token Polling
    loop Poll until authorized or expired
        Client->>API: POST /oauth/token<br/>grant_type=urn:ietf:params:oauth:grant-type:device_code<br/>device_code={device_code}<br/>client_id={client_id}
        alt Authorization Pending
            API-->>Client: 400 authorization_pending
            Client->>Client: Sleep for interval seconds
        else Slow Down
            API-->>Client: 400 slow_down
            Client->>Client: Increase polling interval
        else Access Denied
            API-->>Client: 400 access_denied
            Client-->>Dev: ❌ Authorization denied
        else Expired
            API-->>Client: 400 expired_token
            Client-->>Dev: ❌ Code expired, please retry
        else Success
            API-->>Client: 200 OK<br/>access_token, refresh_token,<br/>token_type, expires_in
        end
    end

    Note over Client: Step 5: Store Credentials
    Client->>Client: Store tokens in config file
    Client-->>Dev: ✓ Authenticated successfully
```

### Token Refresh Flow

```mermaid
sequenceDiagram
    autonumber
    participant Client as CLI Client
    participant API as hex.pm API

    Client->>Client: Check access_token expiry
    alt Token expires within 5 minutes
        Client->>API: POST /oauth/token<br/>grant_type=refresh_token<br/>refresh_token={refresh_token}<br/>client_id={client_id}
        API-->>Client: New access_token, refresh_token,<br/>token_type, expires_in
        Client->>Client: Update stored tokens
    end
    Client->>API: API request with access_token
```

### Write Operations with 2FA

```mermaid
sequenceDiagram
    autonumber
    participant Dev as Developer
    participant Client as CLI Client
    participant API as hex.pm API

    Dev->>Client: mix hex.publish

    Client->>API: POST /api/publish<br/>Authorization: {access_token}
    API-->>Client: 401 WWW-Authenticate: Bearer realm="hex", error="totp_required"

    Client->>Dev: Enter 2FA code:
    Dev-->>Client: 123456

    Client->>API: POST /api/publish<br/>Authorization: {access_token}<br/>x-hex-otp: 123456
    API-->>Client: 201 Created
```

### Client-Specific Details

#### Mix/Hex

- Client ID: `78ea6566-89fd-481e-a1d6-7d9d78eacca8`
- Token storage: `~/.hex/hex.config`
- Commands: `mix hex.user auth`, `mix hex.user deauth`

#### Gleam

- Client ID: `877731e8-cb88-45e1-9b84-9214de7da421`
- Token storage: `~/.cache/gleam/hex/hexpm/credentials` (refresh token encrypted with user passphrase)
- Command: `gleam hex authenticate`

---

## Verification Summary

All clients perform these verification steps:

### Registry Verification

1. **Decompress** - gunzip the response
2. **Decode** - Parse `Signed` protobuf wrapper
3. **Verify Signature** - RSA-PKCS1-SHA512 of payload using hex.pm public key
4. **Verify Repository** - Ensure `repository` field matches expected repo name
5. **Parse Payload** - Decode inner protobuf (Names, Versions, or Package)

### Tarball Verification

1. **Download** - Fetch tarball from `/tarballs/{name}-{version}.tar`
2. **Outer Checksum** - `SHA256(entire tarball)` must match registry's `outer_checksum`
3. **Extract** - Unpack tar to get VERSION, metadata.config, contents.tar.gz, CHECKSUM
4. **Inner Checksum** - Verify CHECKSUM file matches `SHA256(VERSION + metadata.config + contents.tar.gz)`

### Public Key

The hex.pm public key is:
- Distributed with client libraries (hardcoded)
- Available at `https://hex.pm/docs/public_keys`
- 2048-bit RSA key used for RSA-PKCS1-SHA512 signatures
