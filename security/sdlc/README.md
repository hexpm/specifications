# Secure Development Lifecycle

This documentation describes the secure development practices for Hex registry
infrastructure, organized into three pillars.

## Pillars

### [Secure Build](./build.md)

How we build software securely:

- Artifact provenance and integrity
- Dependency management and constraints
- Toolchain security (CI/CD, compilers, formatters)

### [Secure Process](./process.md)

How we develop software securely:

- Code review requirements
- Quality assurance and testing
- Security scanning
- Vulnerability handling and disclosure

### [Secure Runtime](./runtime.md)

How we run software securely:

- Deployment controls
- Secrets management
- Service ownership
- Monitoring and observability

## Registers

### [Risk Register](./risk-register.md)

Tracked security risks with their severity, status, and mitigations.

### [Exception Register](./exception-register.md)

Approved deviations from security policies with justification and expiry.

## Related Documentation

- [Supply Chain Security](../supply-chain/overview.md) - Package integrity from publish to install
- [Operations](../operations/incident-response.md) - Incident response and access control
