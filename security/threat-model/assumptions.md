# Assumptions

This document describes the security assumptions and boundaries of the Hex ecosystem.

For controls that address threats under these assumptions, see [Mitigations](mitigations.md).

## What We Assume

### About Maintainers

| Assumption | Implication |
|------------|-------------|
| Development environments may be compromised | Build provenance cannot be guaranteed without attestations |
| Maintainers are responsible for their package security | Registry does not audit package contents |
| Maintainers may make mistakes | Leaked credential detection, but cannot prevent all exposures |

### About Users

| Assumption | Implication |
|------------|-------------|
| Users execute packages in trusted environments | Registry cannot protect against local exploits |
| Users are responsible for evaluating trustworthiness | Download counts and metadata provided, but no endorsement |
| Users have secure credential storage | Tokens stored locally; compromise is user's responsibility |

### About Infrastructure

| Assumption | Implication |
|------------|-------------|
| Cloud providers (Google Cloud, AWS, Fastly) operate securely | Infrastructure compromise outside our control |
| TLS provides confidentiality and integrity in transit | No additional transport encryption |
| Cryptographic primitives (RSA, SHA-256) are secure | Signature and checksum schemes depend on this |

### About Clients

| Assumption | Implication |
|------------|-------------|
| Official clients implement verification correctly | Security depends on client-side checks |
| Users use current client versions | Old clients may have vulnerabilities |
| Clients run in trusted local environments | Local cache tampering outside our control |

## What We Do NOT Guarantee

### Package Content

| Non-Guarantee | Reason |
|---------------|--------|
| Packages are safe to use | We do not audit source code |
| Packages do what they claim | No functional verification |
| No malicious packages exist | Detection is imperfect; controls reduce but don't eliminate risk |

### Maintainer Identity

| Non-Guarantee | Reason |
|---------------|--------|
| Real-world identity of maintainers | Account verification is email-based only |
| Organization membership implies employment | No employment verification |

### Availability

| Non-Guarantee | Reason |
|---------------|--------|
| 100% uptime | Maintenance windows and incidents may occur |
| Protection against all DDoS | Attacks may cause temporary unavailability |

### Historical Packages

| Non-Guarantee | Reason |
|---------------|--------|
| All historical versions are safe | Vulnerabilities may exist in old versions |
| Retired packages are removed | Kept available for reproducibility |

## Security Boundaries

### Registry Responsibility

**We are responsible for:**
- Protecting registry infrastructure
- Ensuring integrity of distributed artifacts
- Authenticating publishing operations
- Providing audit capabilities

**We are NOT responsible for:**
- Security of maintainer environments
- Security of package contents
- Security of user environments
- Vulnerabilities in packages

### Trust Model

> [!TIP]
> **What users CAN trust:**
> - Artifact matches what maintainer published (integrity)
> - Registry metadata is authentic (signatures)
> - Publishing required authentication

> [!CAUTION]
> **What users CANNOT assume:**
> - Package is safe to execute
> - Maintainer is trustworthy
> - Package has no vulnerabilities
> - Dependencies are safe

## Future Improvements

Planned features that will change (but not eliminate) these assumptions:

| Feature | Impact on Assumptions |
|---------|----------------------|
| Trusted Publishing (OIDC) | Provides build provenance; reduces "maintainer environment" assumption |
| Malware scanning | Provides some content assurance; still cannot guarantee safety |
| Signed attestations | Provides verifiable claims about build process |
| WebAuthn/Passkeys | Reduces account compromise risk |

See [Mitigations](mitigations.md) for current status of these features.
