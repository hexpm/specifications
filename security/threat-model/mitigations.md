# Mitigations

This document describes the controls that address identified [threats](threats.md).

**Status Legend:**
- **Implemented** - Control is in place
- **Partial** - Control exists but has known gaps
- **Planned** - On roadmap but not yet implemented

## Identity & Access

Addresses: [T1](threats.md#t1-malicious-package-publication), [T4](threats.md#t4-account-takeover)

### Authentication

| Control | Status | Description |
|---------|--------|-------------|
| Email verification | Implemented | Users must verify email addresses for account recovery |
| Password minimum length | Implemented | Minimum 8 characters, no complexity rules |
| Leaked password detection | Implemented | Checks passwords against HaveIBeenPwned API on login and password change; warns users but allows login |
| Two-factor authentication (TOTP) | Implemented | Optional for login, required for write operations with OAuth |
| Phishing-resistant 2FA (WebAuthn) | Planned | Hardware security keys and passkeys |
| Passwordless authentication | Planned | Passkey-based access methods |
| OAuth2 Device Authorization Grant | Implemented | Secure CLI authentication flow. See [Client Flows](client-flows.md#6-oauth2-device-authorization-grant) |
| Login rate limiting | Implemented | 10 attempts per IP per 15 minutes |
| Mandatory 2FA for maintainers | Planned | Requires rebar3 OAuth migration, then disable basic auth; 2FA already required for OAuth write operations |
| Critical package MFA | Partial | Require MFA for maintainers of high-impact packages |
| Abandoned domain detection | Planned | Detect and disable account recovery via expired email domains |
| Security notifications | Implemented | Alert maintainers about critical account changes via email |
| Account recovery policy | Planned | Documented procedures for account access restoration |

### Token Management

| Control | Status | Description |
|---------|--------|-------------|
| Scoped API tokens | Implemented | Tokens can be scoped by domain (api, repository, package, docs) and resource (read/write, specific repos/packages) |
| Short-lived OAuth access tokens | Implemented | Access tokens expire quickly, refresh tokens for renewal |
| Token revocation | Implemented | Users can revoke tokens at any time |
| API key expiry dates | Implemented | Allow setting expiration on API keys |
| Token prefixing | Planned | Distinctive repository identifiers on all tokens |
| Secret scanning integration | Planned | Tokens compatible with third-party secret detection tools with automated revocation |
| 2FA for write operations | Implemented | OAuth tokens require 2FA for publishing. See [Client Flows](client-flows.md#write-operations-with-2fa) |

### Session Security

| Control | Status | Description |
|---------|--------|-------------|
| Secure session cookies | Implemented | Phoenix default secure cookie configuration |
| Session timeout | Implemented | Automatic session expiration |
| Session invalidation | Implemented | Logout invalidates session server-side |
| Sudo mode | Implemented | Critical operations require re-authentication; shorter lifetime than regular session |

## Publishing Controls

Addresses: [T1](threats.md#t1-malicious-package-publication), [T2](threats.md#t2-typosquatting--dependency-confusion)

### Ownership Model

| Control | Status | Description |
|---------|--------|-------------|
| Package ownership required | Implemented | Only owners can publish to a package |
| Owner levels | Implemented | "full" (can manage owners) vs "maintainer" (can publish only) |
| Transfer confirmation | Implemented | Ownership transfers require confirmation |

### Audit Trail

| Control | Status | Description |
|---------|--------|-------------|
| Comprehensive audit logging | Implemented | Logs: releases (publish/revert/retire), ownership changes, key operations, password changes, email changes, billing, sessions, 2FA changes |
| Audit log metadata | Implemented | Includes user agent, remote IP, key/token used, user data snapshot |
| Package audit logs | Implemented | Viewable per-package in dashboard |
| User audit logs | Implemented | Viewable per-user in dashboard |

### Version Immutability

| Control | Status | Description |
|---------|--------|-------------|
| Immutable versions | Implemented | Published versions cannot be modified after grace period |
| Retirement (not deletion) | Implemented | Packages can be retired but not deleted |

## Supply Chain Integrity

Addresses: [T3](threats.md#t3-package-tampering)

### Registry Signing

| Control | Status | Description |
|---------|--------|-------------|
| RSA-SHA512 signatures | Implemented | All registry files are signed |
| Public key distribution | Implemented | Public key bundled with clients |
| Client signature verification | Implemented | Clients verify before trusting metadata. See [Client Flows](client-flows.md#verification-summary) |

### Checksums

| Control | Status | Description |
|---------|--------|-------------|
| Outer checksum (SHA-256) | Implemented | Tarball integrity verification |
| Checksums in signed registry | Implemented | Checksums protected by registry signature |
| Client verification | Implemented | Clients verify checksums before extraction |

### Build Provenance

| Control | Status | Description |
|---------|--------|-------------|
| Trusted Publishing (OIDC) | Planned | CI provider integration for keyless publishing |
| Build attestations (SLSA) | Planned | Cryptographic proof of build origin |
| Source repository linking | Partial | Links exist but not cryptographically verified |

See [Supply Chain - Provenance](../supply-chain/provenance.md).

## Ecosystem Protections

Addresses: [T2](threats.md#t2-typosquatting--dependency-confusion)

### Namespace Controls

| Control | Status | Description |
|---------|--------|-------------|
| Globally unique names | Implemented | Package names are unique across the registry |
| Reserved names | Implemented | Common names like "hex", "elixir", "erlang", "otp" are reserved |
| Squatting policies | Implemented | Names can be reclaimed if squatted |

### Typosquatting Detection

| Control | Status | Description |
|---------|--------|-------------|
| Levenshtein distance check | Implemented | Daily job checks new packages against existing names; emails moderators when candidates found |
| Automated blocking | Accepted Risk | Detection is alert-only; does not block publishing |

### Malicious Package Detection

| Control | Status | Description |
|---------|--------|-------------|
| Malicious package scanning | Planned | Automated scanning of packages for known malicious patterns and file hashes |
| Malicious package disclosure (OSV) | Planned | Malicious packages disclosed to OSV database |

### Community Reporting

| Control | Status | Description |
|---------|--------|-------------|
| Report mechanism (UI) | Planned | Users can report suspicious packages via web UI |
| Report mechanism (CLI) | Planned | Users can report suspicious packages via CLI |
| Report mechanism (API) | Planned | Users can report suspicious packages via API |
| Review process | Planned | Reports are reviewed by operators |

## Documentation Isolation

Addresses: [T5](threats.md#t5-documentation-based-attacks)

### Origin Separation

| Control | Status | Description |
|---------|--------|-------------|
| Separate origin | Implemented | Documentation served from hexdocs.pm |
| Per-package origin isolation | Planned | Each package's docs served from separate origin to prevent cross-package attacks |
| No shared authentication | Implemented | hexdocs.pm has no access to registry sessions |

### Content Security

| Control | Status | Description |
|---------|--------|-------------|
| Content Security Policy | Implemented | CSP headers with Sentry violation reporting |
| README sandboxing | Implemented | READMEs rendered in isolated iframe with restricted CSP |
| Content sanitization | Implemented | HTML sanitizer for user-provided content |

## Infrastructure Security

Addresses: [T6](threats.md#t6-registry-infrastructure-compromise)

### Access Control

<!-- TODO: Verify least privilege implementation -->

| Control | Status | Description |
|---------|--------|-------------|
| Least privilege | ? | Minimal permissions for each role |
| Role-based access | Implemented | User roles: "basic", "mod" |

See [Operations - Access Control](../operations/access-control.md).

### Security Policy

| Control | Status | Description |
|---------|--------|-------------|
| Vulnerability disclosure policy | Implemented | Published policy allowing security researchers to report issues with legal safe harbor |

### Network Security

| Control | Status | Description |
|---------|--------|-------------|
| Service isolation | Implemented | Services separated where possible |
| TLS everywhere | Implemented | All external communication encrypted |

### Monitoring

| Control | Status | Description |
|---------|--------|-------------|
| Security event monitoring | Implemented | Security-relevant events are monitored |
| CSP violation reporting | Implemented | CSP violations reported to Sentry |
| Event transparency logs | Planned | Published activity records enabling anomaly detection |
| Security infrastructure reviews | Planned | Periodic assessments of repository systems |

## Availability

Addresses: [T7](threats.md#t7-denial-of-service)

### Rate Limiting

| Control | Status | Description |
|---------|--------|-------------|
| API rate limits (authenticated) | Implemented | 500 requests per user per minute |
| API rate limits (unauthenticated) | Implemented | 100 requests per IP per minute |
| Organization rate limits | Implemented | 500 requests per organization per minute |
| Login rate limits | Implemented | 10 attempts per IP per 15 minutes |
| 2FA rate limits | Implemented | 20 attempts per IP per 15 minutes; 5 per session per 10 minutes |
| Sudo mode rate limits | Implemented | 5 password attempts per user per 15 minutes; 5 2FA attempts per user per 15 minutes |
| Device verification limits | Implemented | 10 per user, 30 per IP per 15 minutes |
| IP allow/block lists | Implemented | Configurable address filtering |
| Upload size limits | Implemented | Maximum package size enforced |

### CDN

| Control | Status | Description |
|---------|--------|-------------|
| Fastly CDN | Implemented | Global edge caching for package distribution |
| Edge caching | Implemented | Reduces origin load, improves availability |

### Operational

| Control | Status | Description |
|---------|--------|-------------|
| Monitoring and alerting | Implemented | Availability monitoring in place |
| Incident response | Implemented | Documented procedures. See [Operations - Incident Response](../operations/incident-response.md) |

## Dependency Security

Addresses: [T8](threats.md#t8-vulnerable-dependencies-transitive)

### Vulnerability Tracking

| Control | Status | Description |
|---------|--------|-------------|
| Advisory database integration | Partial | We submit to OSV but don't yet consume it in hex.pm or clients |
| Hex.pm as CNA | Implemented | Can issue CVEs for Elixir/Erlang packages via EEF CNA |

See [SDLC - Secure Process](../sdlc/process.md#vulnerability-handling).

### User Tools

| Control | Status | Description |
|---------|--------|-------------|
| `mix hex.audit` (retirement) | Implemented | CLI tool checks for retired packages |
| `mix hex.audit` (vulnerabilities) | Planned | CLI tool to check for known vulnerabilities |
| Dependency tree visibility | Implemented | Transitive dependencies shown in metadata |
| Security advisories on hex.pm | Planned | Advisories displayed on package pages |
| Hash/version pinning | Implemented | Dependencies can be locked to specific versions and checksums via lock files |
| SBOM generation | Implemented | Software Bill of Materials documentation |
| Automated remediation | Planned | Upgrade dependencies to resolve known vulnerabilities |
| Reachability analysis | Planned | Reduce false positives by determining if vulnerable code paths execute |

## Ecosystem Health

Addresses: [T9](threats.md#t9-unmaintainedabandoned-packages)

### Package Metadata

| Control | Status | Description |
|---------|--------|-------------|
| Last activity indicators | Implemented | Shows when package was last updated |
| Retirement status | Implemented | Packages can be marked as retired. See [Package Metadata](../../package_metadata.md) |

### Community Signals

| Control | Status | Description |
|---------|--------|-------------|
| Download statistics | Implemented | Shows package popularity |
| Maintenance activity | Implemented | Visible update history |

### Succession Planning

| Control | Status | Description |
|---------|--------|-------------|
| Ownership transfer | Implemented | Mechanism to transfer packages |
| Abandoned package adoption | Partial | Process exists but not formalized |

## Mitigation Coverage Matrix

| Threat | Primary Mitigations | Status | Notes |
|--------|---------------------|--------|-------|
| T1: Malicious publication | 2FA, token scoping, audit logs | Implemented | 2FA optional for login |
| T2: Typosquatting | Levenshtein check, community reports | Partial | Detection is alert-only |
| T3: Package tampering | Signatures, checksums | Implemented | Strong coverage |
| T4: Account takeover | 2FA, OAuth, leaked password check, rate limiting | Implemented | 2FA optional for login |
| T5: Documentation attacks | Origin separation, CSP, sandboxing | Implemented | Strong coverage |
| T6: Registry compromise | Access control, monitoring | Implemented | Strong coverage |
| T7: DoS | Rate limiting, CDN | Implemented | Strong coverage |
| T8: Vulnerable dependencies | Advisories, CNA, audit tools | Implemented | Strong coverage |
| T9: Unmaintained packages | Metadata, retirement status | Partial | Succession process informal |
| T10: Build pipeline compromise | (Planned: Trusted Publishing) | Planned | Gap - highest priority |