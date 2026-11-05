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
| CI jobs send OIDC tokens only to a trusted Hex API URL | A server at an untrusted URL receives a valid `hexpm` token and can use it at hex.pm before it expires. Clients pin the audience so the server cannot get a token for another service |
| Maintainers protect the GitHub workflows that their workload identities trust | Hex.pm cannot see GitHub branch protection or environment protection rules. Anyone who can run a matching workflow can publish |
| Maintainers review a staged release before they approve it | Approval checks that a person agreed, not that the content is safe |

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
| GitHub issues OIDC tokens only to the workflow runs that the claims describe | A compromised GitHub OIDC issuer can publish every package that has a workload identity |
| TLS provides confidentiality and integrity in transit | No additional transport encryption |
| Cryptographic primitives (RSA, SHA-256, SHA-512) are secure | RSA-PKCS1-SHA512 signatures and SHA-256 checksums depend on this |

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

### Publishing Controls

| Non-Guarantee | Reason |
|---------------|--------|
| Every release was approved by a person | Staged publishing is off by default for existing packages, and does not hold publishes by a person with OAuth and a 2FA code |
| Staged publishing stops a leaked key | A key with `api:write`, `owners`, `package:NAME`, or `members` can add an owner or member, who then publishes without staging |
| Removing an owner stops their workload identities | Package workload identities stay when an owner is removed without a transfer. A removed owner who can still run a trusted workflow can still publish |
| Removing a workload identity stops fetch tokens at once | repo.hex.pm verifies tokens without hex.pm, so a fetch token stays valid for up to 15 minutes |
| Every release from CI has a verified CI identity | Releases published from CI with an API key have no `oidc_claims` |

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
> - A release with `oidc_claims` was published by a GitHub Actions job that matched a workload identity, and the claims are the ones GitHub signed

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
| Malware scanning | Provides some content assurance; still cannot guarantee safety |
| Signed attestations | Provides verifiable claims about build process |
| WebAuthn/Passkeys | Reduces account compromise risk |

See [Mitigations](mitigations.md) for current status of these features.
