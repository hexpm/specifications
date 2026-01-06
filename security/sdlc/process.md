# Secure Process

This document describes secure development process practices for Hex registry infrastructure.

## Code Review

### Requirements

Code review requirements are enforced through GitHub rulesets. See the repository rulesets for the authoritative configuration.

| Repository | Status |
|------------|--------|
| hexpm/hexpm | Active |
| hexpm/hex | Active |
| hexpm/hex_core | Active |
| hexpm/hex_solver | Active |
| hexpm/hexdocs | Active |
| hexpm/preview | Active |
| hexpm/diff | Active |
| hexpm/specifications | Active |
| hexpm/bob | None |
| hexpm/hexdocs-search | None |

### Ruleset Configuration (hexpm)

| Rule | Configuration |
|------|---------------|
| CodeQL | All security alerts, all general alerts |
| Zizmor | All security alerts, all general alerts |
| Code quality | All severity levels enforced |
| Bypass | No bypass permissions configured |

### Security Considerations

Reviewers evaluate:

- Authentication and authorization boundaries
- Input validation at trust boundaries
- Output encoding to prevent injection
- Cryptographic usage
- Secrets handling

## Quality Assurance

### Testing

| Test Type | Coverage | Notes |
|-----------|----------|-------|
| Unit tests | All projects | Required for changes |
| Integration tests | Hex client against hexpm | Matrix across Hex versions |
| Property-based tests | hex_core | `proper` framework |

### Compatibility Testing

Projects are tested against:

- All [supported OTP versions](https://github.com/erlang/otp/security#supported-versions)
- All [supported Elixir versions](https://hexdocs.pm/elixir/compatibility-and-deprecations.html)
- Erlang/OTP master and Elixir main to catch bugs early

### Hex Client Integration

The Hex client is integration tested against the hexpm registry.

### CI Gates

| Check | Enforcement |
|-------|-------------|
| All CI checks pass | Required |
| CodeQL security scan | Required |
| Zizmor workflow scan | Required |
| Code review | Required |

## Security Scanning

### Automated Scanners

| Scanner | Trigger | Scope |
|---------|---------|-------|
| CodeQL | Push/PR to main, weekly | GitHub Actions |
| Zizmor | Push/PR to main | Workflow security |

### Vulnerability Sources

We collaborate with the [Erlang Ecosystem Foundation CNA](https://cna.erlef.org/) for BEAM ecosystem CVEs.

### Vulnerability Response

| Severity | Response |
|----------|----------|
| Critical / High | Out-of-band release |
| Medium / Low | Normal update cycle |

## Vulnerability Handling

- [Hex.pm security policy](https://github.com/hexpm/hexpm/security/policy)
- [EEF CNA security policy](https://cna.erlef.org/security-policy)

## Secure Coding Practices

### Input Validation

| Boundary | Validation |
|----------|------------|
| API endpoints | Parameter validation |
| Package uploads | Format and size validation |
| User input | Sanitization before storage |

### Database Security

| Practice | Implementation |
|----------|----------------|
| Parameterized queries | Ecto (no raw SQL) |
| Connection pooling | Postgrex with TLS |
| Schema validation | Ecto changesets |

### Authentication

| Feature | Implementation |
|---------|----------------|
| Password hashing | bcrypt |
| TOTP 2FA | `pot` library |
| OAuth2 | `ueberauth` + GitHub |
| Session management | Phoenix sessions |

## Related Documentation

- [Secure Build](./build.md) - Build pipeline and dependencies
- [Secure Runtime](./runtime.md) - Deployment and operations
- [EEF CNA Security Policy](https://cna.erlef.org/security-policy.html) - Full disclosure policy
- [Operations - Incident Response](../operations/incident-response.md) - Incident handling
