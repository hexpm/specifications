# Assets

This document identifies the assets protected by the Hex ecosystem.

For where these assets are stored and how they flow through the system, see [Architecture](architecture.md). For threats targeting these assets, see [Threats](threats.md).

## Critical Assets

### Package Artifacts

Package tarballs containing source code distributed to consumers.

| Attribute | Description |
|-----------|-------------|
| Location | S3 storage, served via CDN |
| Impact if compromised | Arbitrary code execution in downstream systems |
| Protection | Checksums, signed registry, immutable versions (after one hour, or 24 hours for newly created packages) |

### Registry Metadata

Signed protobuf files containing package versions, dependencies, and checksums.

| Attribute | Description |
|-----------|-------------|
| Location | S3 storage (protobuf files), served via CDN |
| Impact if compromised | Dependency confusion, version manipulation |
| Protection | RSA-SHA512 signatures, repository field verification |

### Registry Signing Key

Private RSA key used to sign all registry files.

| Attribute | Description |
|-----------|-------------|
| Location | Secrets management |
| Impact if compromised | Attacker could sign malicious registry, bypassing all client verification |
| Protection | Access control, rotation procedures |

### Maintainer Accounts

User credentials and authentication state.

| Attribute | Description |
|-----------|-------------|
| Location | Database (hashed passwords, TOTP secrets) |
| Impact if compromised | Unauthorized package publishing |
| Protection | Strong passwords, 2FA, OAuth tokens |

### API Tokens

Bearer tokens for API access.

| Attribute | Description |
|-----------|-------------|
| Location | Database (hashed), client machines (plaintext/encrypted) |
| Impact if compromised | Unauthorized actions within token scope |
| Protection | Scoping, revocation, short-lived OAuth tokens |

## High Value Assets

### Documentation Content

User-generated HTML documentation.

| Attribute | Description |
|-----------|-------------|
| Location | S3 storage, served via hexdocs.pm |
| Impact if compromised | XSS attacks, phishing |
| Protection | CSP headers, separate origin (planned) |

### Package Ownership

Namespace mappings and collaborator permissions.

| Attribute | Description |
|-----------|-------------|
| Location | Database |
| Impact if compromised | Package takeover, typosquatting enablement |
| Protection | Ownership model, audit logs |

### Organization Data

Private repositories and billing information.

| Attribute | Description |
|-----------|-------------|
| Location | Database |
| Impact if compromised | Data breach, unauthorized access |
| Protection | Access control, authentication requirements |

## Supporting Assets

### Audit Logs

Records of security-relevant actions.

| Attribute | Description |
|-----------|-------------|
| Location | Database, log aggregation |
| Impact if compromised | Loss of forensic capability |
| Protection | Append-only, retention policies |

### Build Metadata

SBOM and provenance information.

| Attribute | Description |
|-----------|-------------|
| Location | Package metadata, external attestations |
| Impact if compromised | False provenance claims |
| Protection | Signed attestations (future) |

### Infrastructure Credentials

Service accounts and deployment keys.

| Attribute | Description |
|-----------|-------------|
| Location | Secrets management |
| Impact if compromised | Full system compromise |
| Protection | Rotation, least privilege, monitoring |

## Asset Classification Matrix

Impact ratings use [CVSS v4.0](https://www.first.org/cvss/v4.0/specification-document) semantics:
- **None** - No impact
- **Low** - Limited impact
- **High** - Serious impact

| Asset | Confidentiality | Integrity | Availability |
|-------|-----------------|-----------|--------------|
| Package Artifacts | None | High | High |
| Registry Metadata | None | High | High |
| Registry Signing Key | High | High | High |
| Maintainer Accounts | High | High | Low |
| API Tokens | High | High | Low |
| Documentation Content | None | Low | Low |
| Package Ownership | Low | High | Low |
| Organization Data | High | High | Low |
| Audit Logs | Low | High | Low |
| Build Metadata | None | High | None |
| Infrastructure Credentials | High | High | High |
