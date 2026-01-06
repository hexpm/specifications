# Secure Build

This document describes secure build practices for Hex registry infrastructure.

## Artifact Provenance

### Docker Images

| Property | Implementation |
|----------|----------------|
| Image digest | SHA256 of image manifest |
| Push by digest | Ensures immutability |
| Multi-platform manifests | Consistent across architectures |
| Git commit linking | Image tagged with short SHA |

### Image Tagging

| Tag Format | Example | Purpose |
|------------|---------|---------|
| Short SHA | `abc1234` | Identifies specific commit |
| Registry | `gcr.io/hexpm-prod/hexpm` | GCP Container Registry |

### Package Releases

| Property | Implementation |
|----------|----------------|
| Checksums | SHA-256 in signed registry |
| Immutability | Cannot modify after grace period |
| Registry signing | RSA-SHA512 signatures |

## Dependencies

### Automated Updates

Most Hex projects use GitHub Dependabot for automated dependency updates:

| Repository | Dependabot | Ecosystems |
|------------|------------|------------|
| hexpm/hexpm | Yes | github-actions, mix |
| hexpm/hex | Yes | github-actions, mix |
| hexpm/hex_core | Yes | github-actions, rebar |
| hexpm/hex_solver | Yes | github-actions, mix |
| hexpm/hexdocs | Yes | github-actions, mix |
| hexpm/preview | Yes | github-actions, mix |
| hexpm/diff | Yes | github-actions, mix |
| hexpm/specifications | Yes | github-actions |
| hexpm/bob | No | - |
| hexpm/hexdocs-search | No | - |

### Dependency Constraints

Some projects have restrictions on external dependencies:

| Project | Constraint | Reason |
|---------|------------|--------|
| hex | No external deps | Bootstrapped before package manager available |
| hex_core | No external deps | Designed to be vendored by clients |

These projects must only use OTP standard library functions or vendor library code.

### Dependency Selection

| Criterion | Consideration |
|-----------|---------------|
| Maintenance status | Active development and releases |
| Security track record | History of vulnerabilities and response |
| Community adoption | Usage and community support |
| License compatibility | Apache 2.0 / MIT preferred |

### Minimization Principles

| Principle | Implementation |
|-----------|----------------|
| Prefer standard library | Use OTP/Elixir stdlib when sufficient |
| Avoid unnecessary deps | Each dependency adds attack surface |
| Evaluate transitives | Consider full dependency tree |

## Toolchain

### CI Pipeline

| Check | Description |
|-------|-------------|
| Formatting | Code formatting enforced in CI |
| Unit tests | Automated tests run on every PR |
| CodeQL | Security scanning for GitHub Actions workflows |
| Zizmor | GitHub Actions security best practices |

### Authentication (CI)

| Stage | Method |
|-------|--------|
| GCP authentication | Workload Identity Federation (OIDC) |
| Container Registry | OAuth2 access token |
| No long-lived secrets | Short-lived tokens from OIDC |

## Related Documentation

- [Secure Process](./process.md) - Code review and quality assurance
- [Secure Runtime](./runtime.md) - Deployment and operations
- [Supply Chain - Signing](../supply-chain/signing.md) - Registry signing
