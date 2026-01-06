# Actors

This document identifies the actors that interact with the Hex ecosystem.

For how these actors interact with the system, see [Architecture](architecture.md).

## Legitimate Actors

### Package Consumer

Developers and CI/CD systems that install and use packages.

| Attribute | Description |
|-----------|-------------|
| Access | Unauthenticated read access to public packages; API key for private |
| Trust level | Untrusted (no write access) |
| Capabilities | Download packages, read registry metadata, view documentation |

### Package Maintainer

Developers who publish and manage packages. There are two ownership levels:

- **Maintainer** — publish, retire/unretire releases, upload documentation
- **Owner** — all maintainer capabilities, plus manage package ownership

| Attribute | Description |
|-----------|-------------|
| Access | Authenticated API access, publishing permissions |
| Trust level | Trusted for their own packages |

### Organization Administrator

Manages private repositories and teams within an organization.

| Attribute | Description |
|-----------|-------------|
| Access | Elevated permissions within organization scope |
| Trust level | Trusted for organization resources |
| Capabilities | Manage members, configure billing, access private packages |

### Hex.pm Operator

Maintains and operates the registry infrastructure.

| Attribute | Description |
|-----------|-------------|
| Access | Infrastructure and administrative access |
| Trust level | Highly trusted |
| Capabilities | System administration, incident response, policy enforcement |

## Adversarial Actors

### External Attacker

| Attribute | Description |
|-----------|-------------|
| Goal | Compromise downstream systems via supply chain |
| Access | No legitimate access |
| Capabilities | Network attacks (MITM without TLS), social engineering, exploiting vulnerabilities |

### Malicious Maintainer

| Attribute | Description |
|-----------|-------------|
| Goal | Inject malicious code into packages |
| Access | Legitimate publishing access to their own packages |
| Capabilities | Publish malicious updates, typosquatting, dependency confusion attacks |

### Compromised Maintainer

| Attribute | Description |
|-----------|-------------|
| Goal | Attacker leverages stolen legitimate access |
| Access | Stolen credentials or hijacked session |
| Capabilities | All maintainer capabilities, potentially elevated privileges |

### Supply Chain Attacker

| Attribute | Description |
|-----------|-------------|
| Goal | Compromise build/release pipeline |
| Access | Indirect via dependencies or tooling |
| Capabilities | Compromise CI systems, tamper with build artifacts, inject backdoors via dependencies |

### Insider Threat

| Attribute | Description |
|-----------|-------------|
| Goal | Data theft, sabotage, or other malicious intent |
| Access | Legitimate internal access (operator, employee) |
| Capabilities | Depends on role; may bypass external controls |
