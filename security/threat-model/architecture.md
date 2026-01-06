# Architecture

This document describes the system architecture from a security perspective. For detailed client interaction flows including authentication, verification, and caching, see [Client Flows](client-flows.md).

## Ecosystem Inventory

### Services

| Name | Description | Production | Staging | Repository |
|------|-------------|------------|---------|------------|
| Hex Registry | Main registry, web UI & API | hex.pm | staging.hex.pm | [hexpm/hexpm](https://github.com/hexpm/hexpm) |
| Hex Operations | Terraform, Config, Fastly Compute | - | - | [hexpm/hexpm-ops](https://github.com/hexpm/hexpm-ops) (private) |
| Hex Docs | Documentation hosting | hexdocs.pm | staging.hexdocs.pm | [hexpm/hexdocs](https://github.com/hexpm/hexdocs), [hexpm/hexdocs-search](https://github.com/hexpm/hexdocs-search) |
| Hex Preview | Package preview | preview.hex.pm | preview.staging.hex.pm | [hexpm/preview](https://github.com/hexpm/preview) |
| Hex Diff | Package diff viewer | diff.hex.pm | diff.staging.hex.pm | [hexpm/diff](https://github.com/hexpm/diff) |

> **Out of scope:** billing.hex.pm is excluded from this security documentation.

### Client Libraries

| Name | Description | Repository |
|------|-------------|------------|
| Hex | Elixir Hex client | [hexpm/hex](https://github.com/hexpm/hex) |
| Hex Core | Core library for Elixir/Erlang clients | [hexpm/hex_core](https://github.com/hexpm/hex_core) |
| Hex Solver | Version constraint resolver | [hexpm/hex_solver](https://github.com/hexpm/hex_solver) |
| hexpm-rust | Rust Hex client (used by Gleam) | [gleam-lang/hexpm-rust](https://github.com/gleam-lang/hexpm-rust) |

### Build Tools

| Name | Description | Repository |
|------|-------------|------------|
| Mix | Elixir build tool | [elixir-lang/elixir](https://github.com/elixir-lang/elixir) (lib/mix) |
| Rebar3 | Erlang build tool | [erlang/rebar3](https://github.com/erlang/rebar3) |
| erlang.mk | Erlang build tool | [ninenines/erlang.mk](https://github.com/ninenines/erlang.mk) |
| Gleam | Gleam language & build tool | [gleam-lang/gleam](https://github.com/gleam-lang/gleam) |

## System Context

Shows the Hex ecosystem and its relationships with users and external systems.

```mermaid
C4Context
    title System Context Diagram for Hex Package Manager

    Person(consumer, "Package Consumer", "Developers and CI/CD systems using mix, rebar3, or gleam")
    Person(maintainer, "Package Maintainer", "Publishes and manages packages")
    Person(operator, "Hex.pm Operator", "Maintains registry infrastructure")

    System(hex, "Hex.pm", "Package registry API and web UI")
    System_Ext(fastly, "Fastly CDN", "Global content delivery and edge compute")
    System_Ext(storage, "Cloud Storage", "Package artifacts and registry files")

    System_Ext(github, "GitHub", "OAuth authentication and source code hosting")
    System_Ext(email, "Email Service", "Sends notifications and password resets")

    Rel(consumer, hex, "API requests", "HTTPS")
    Rel(consumer, fastly, "Repository requests", "HTTPS")
    Rel(maintainer, hex, "Publishes packages", "HTTPS + API Key")
    Rel(operator, hex, "Administers", "Internal")

    Rel(fastly, storage, "Serves registry + tarballs", "HTTPS cached")

    Rel(hex, github, "OAuth authentication")
    Rel(hex, email, "Sends notifications")
    Rel(hex, storage, "Stores packages")

    UpdateLayoutConfig($c4ShapeInRow="3", $c4BoundaryInRow="1")
```

**Actors** (see [Actors](actors.md) for details):
- **Package Consumers** - Developers and CI/CD systems that fetch packages
- **Package Maintainers** - Publish and manage packages via the web UI or CLI
- **Organization Administrators** - Manage private repositories and teams
- **Hex.pm Operators** - Maintain and operate the registry infrastructure

**External Systems:**
- **GitHub** provides OAuth authentication and hosts package source code
- **Email Service** sends password resets, ownership notifications, etc.
- **Fastly CDN** caches and delivers registry files and package tarballs globally

## Container Diagram

Shows the internal services and data stores within the Hex ecosystem.

```mermaid
C4Container
    title Container Diagram for Hex Package Manager

    Person(consumer, "Package Consumer", "Uses mix, rebar3, or gleam")
    Person(maintainer, "Package Maintainer", "Publishes packages")

    System_Boundary(hex, "Hex Ecosystem") {
        Container(fastly, "Fastly CDN", "Compute@Edge", "Caches content, routes requests, runs edge logic")

        Container(hexpm_web, "hex.pm", "Phoenix/Elixir", "Web UI, HTTP API, package management")
        Container(hexdocs, "hexdocs.pm", "Phoenix/Elixir", "Documentation hosting and search")
        Container(preview, "preview.hex.pm", "Phoenix/Elixir", "Package preview before publishing")
        Container(diff, "diff.hex.pm", "Phoenix/Elixir", "Visual diff between package versions")

        ContainerDb(postgres, "PostgreSQL", "Database", "Users, packages, releases, API keys, organizations")
        ContainerDb(s3, "Object Storage", "S3", "Tarballs, registry files, documentation")

        Container(registry_worker, "Registry Builder", "Elixir Worker", "Rebuilds registry after publishes")
        Container(notification_worker, "Notification Worker", "Elixir Worker", "Sends emails and webhooks")
    }

    System_Ext(email, "Email Service", "Sends notifications")

    Rel(consumer, fastly, "Fetches packages", "HTTPS")
    Rel(maintainer, fastly, "Publishes packages", "HTTPS")

    Rel(fastly, s3, "Registry files", "/names, /versions, /packages/*")
    Rel(fastly, s3, "Tarballs", "/tarballs/*")
    Rel(fastly, hexpm_web, "API requests", "/api/*")
    Rel(fastly, hexdocs, "Documentation", "HTTPS")

    Rel(hexpm_web, postgres, "Reads/writes", "PostgreSQL")
    Rel(hexpm_web, s3, "Stores packages", "S3 API")
    Rel(hexpm_web, registry_worker, "Triggers rebuild")
    Rel(hexpm_web, notification_worker, "Queues notifications")

    Rel(hexdocs, s3, "Reads docs", "S3 API")
    Rel(preview, hexpm_web, "Fetches package data", "Internal API")
    Rel(diff, hexpm_web, "Fetches package versions", "Internal API")

    Rel(registry_worker, s3, "Writes registry", "S3 API")
    Rel(notification_worker, email, "Sends email", "SMTP")

    UpdateLayoutConfig($c4ShapeInRow="4", $c4BoundaryInRow="1")
```

## Deployment Diagram

Shows the production infrastructure deployment topology.

```mermaid
C4Deployment
    title Deployment Diagram for Hex Package Manager

    Deployment_Node(internet, "Internet", "") {
        Deployment_Node(client_node, "Client Machine", "") {
            Container(client, "Build Tool", "mix/rebar3/gleam", "Fetches packages and registry")
        }
        Deployment_Node(browser_node, "Browser", "") {
            Container(browser, "Web Browser", "", "Access web UI")
        }
    }

    Deployment_Node(fastly_edge, "Fastly Edge", "Global POPs") {
        Container(edge, "Edge Cache + Compute@Edge", "Fastly", "Caches registry and tarballs, routes requests")
    }

    Deployment_Node(production, "Production Environment", "") {
        Deployment_Node(web_tier, "Web Tier", "") {
            Container(hex_prod, "hex.pm", "Phoenix/Elixir", "Main application")
            Container(hexdocs_prod, "hexdocs.pm", "Phoenix/Elixir", "Documentation")
            Container(preview_prod, "preview.hex.pm", "Phoenix/Elixir", "Preview")
            Container(diff_prod, "diff.hex.pm", "Phoenix/Elixir", "Diff viewer")
        }
        Deployment_Node(data_tier, "Data Tier", "") {
            ContainerDb(pg_prod, "PostgreSQL", "Primary + Replica", "Application data")
            ContainerDb(s3_prod, "S3 Bucket", "Object Storage", "Tarballs, registry, docs")
        }
    }

    Deployment_Node(mirrors, "Mirror Infrastructure", "") {
        Container(trusted_mirror, "Trusted Mirror", "Org-controlled", "Full authentication support")
        Container(untrusted_mirror, "Untrusted Mirror", "Community", "Public packages only - NO credentials")
    }

    Rel(client, edge, "HTTPS")
    Rel(browser, edge, "HTTPS")

    Rel(edge, hex_prod, "Cache MISS", "/api/*")
    Rel(edge, s3_prod, "Cache MISS", "Registry + tarballs")

    Rel(hex_prod, pg_prod, "PostgreSQL")
    Rel(hex_prod, s3_prod, "S3 API")

    Rel(hexdocs_prod, s3_prod, "S3 API")
    Rel(diff_prod, edge, "Fetch packages", "repo.hex.pm")
    Rel(preview_prod, s3_prod, "S3 events", "Tarball notifications")

    Rel(client, trusted_mirror, "Alternative path", "With auth")
    Rel(client, untrusted_mirror, "Alternative path", "NO auth - public only")

    Rel(trusted_mirror, edge, "Proxies via CDN")
    Rel(untrusted_mirror, edge, "Public packages only")
```

### Deployment Security Notes

- **CDN Strategy**: All traffic flows through Fastly; registry files and tarballs are heavily cached
- **Mirror Trust**: Trusted mirrors can proxy authenticated requests; untrusted mirrors only serve public packages
- **High Availability**: S3 provides artifact durability; Fastly provides global redundancy

## Key Components

| Component | Description | Security Role |
|-----------|-------------|---------------|
| hex.pm API | Package registry API | Authentication, authorization, publishing |
| hex.pm Web | Web interface | User management, 2FA, session handling |
| Fastly CDN + S3 | Content delivery and storage | Artifact integrity, signed registry |
| hexdocs.pm | Documentation hosting | Content isolation, XSS prevention |
| Hex clients | Build tool integrations (mix, rebar3, gleam) | Signature verification, checksum validation |
| Registry Builder | Background worker | Signs registry files after publish |
| Notification Worker | Background worker | Sends security-relevant notifications |

## Trust Boundaries

```mermaid
C4Context
    title Trust Boundary Diagram for Hex Package Manager

    Boundary(trusted, "Trusted Zone") {
        System(hexpm, "hex.pm", "Main application")
        System(fastly, "Fastly CDN", "Edge delivery")
        SystemDb(s3, "S3 Storage", "Package artifacts")
        SystemDb(pg, "PostgreSQL", "Application data")
    }

    Boundary(semi_trusted, "Semi-Trusted Zone") {
        System(trusted_mirror, "Trusted Mirrors", "Organization-controlled mirrors")
    }

    Boundary(untrusted, "Untrusted Zone") {
        Person(client, "Client", "Build tools: mix, rebar3, gleam")
        System(untrusted_mirror, "Untrusted Mirrors", "Community mirrors")
    }

    Rel(client, hexpm, "API requests", "HTTPS + API Key")
    Rel(client, fastly, "Repository requests", "HTTPS + API Key")
    Rel(client, trusted_mirror, "Credentials OK", "HTTPS + API Key")
    Rel(client, untrusted_mirror, "NO CREDENTIALS", "HTTPS only")

    Rel(fastly, hexpm, "Internal")
    Rel(trusted_mirror, fastly, "Proxies requests")
    Rel(untrusted_mirror, fastly, "Public packages only")

    UpdateLayoutConfig($c4ShapeInRow="4", $c4BoundaryInRow="3")
```

### Boundary 1: Client to Registry API

- **Crosses**: User credentials, API tokens, OAuth tokens
- **Controls**: TLS, token scoping, 2FA for write operations

### Boundary 2: Client to Repository (CDN)

- **Crosses**: Package artifacts, registry data, API tokens, OAuth tokens (private packages)
- **Controls**: Signed registry, checksums, signature verification
- **Critical**: Clients must NEVER send credentials to untrusted mirrors

### Boundary 3: Internal Services

- **Crosses**: Database connections, internal APIs
- **Controls**: Network isolation, access control

### Boundary 4: Browser to Documentation

- **Crosses**: User-generated documentation content
- **Controls**: Separate origin, CSP headers

## Communication Protocols

| Path | Protocol | Format | Authentication | Integrity |
|------|----------|--------|----------------|-----------|
| Client → Registry files | HTTPS | Protobuf + gzip | None (public) or API key (private) | RSA-SHA512 signatures |
| Client → Tarballs | HTTPS | tar | None (public) or API key (private) | Checksums |
| Client → API | HTTPS | JSON | API key (Bearer token) or OAuth | TLS |
| Browser → Web | HTTPS | HTML | Session cookie | TLS |
| Browser → Docs | HTTPS | HTML | None | TLS + CSP |
| hex.pm → PostgreSQL | TCP | PostgreSQL protocol | Connection credentials | - |
| hex.pm → S3 | HTTPS | S3 API | IAM credentials | TLS |

## Data Flow Diagrams

### Publishing Flow

```mermaid
sequenceDiagram
    participant Client as Client (mix/rebar3/gleam)
    participant API as hex.pm API
    participant DB as PostgreSQL
    participant S3 as S3 Storage
    participant Worker as Registry Builder
    participant CDN as Fastly CDN

    Client->>API: Publish package (OAuth + 2FA)
    API->>API: Validate authentication & authorization
    API->>DB: Store package metadata
    API->>S3: Upload tarball
    API->>Worker: Trigger registry rebuild
    Worker->>DB: Read package data
    Worker->>Worker: Build & sign registry files
    Worker->>S3: Upload signed registry
    API->>CDN: Cache invalidation
    API-->>Client: Success response
```

### Installation Flow

```mermaid
sequenceDiagram
    participant Client as Client (mix/rebar3/gleam)
    participant CDN as Fastly CDN
    participant S3 as S3 Storage

    Client->>CDN: Fetch registry (/names, /versions)
    CDN->>S3: Cache miss (if needed)
    S3-->>CDN: Registry files
    CDN-->>Client: Signed registry
    Client->>Client: Verify RSA-SHA512 signature
    Client->>CDN: Fetch package tarball
    CDN->>S3: Cache miss (if needed)
    S3-->>CDN: Tarball
    CDN-->>Client: Package tarball
    Client->>Client: Verify checksum
    Client->>Client: Extract contents
```
