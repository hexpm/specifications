# Security Documentation

This documentation describes the security model, practices, and controls for the Hex package ecosystem.

## Overview

Hex.pm is a package registry for the Erlang and Elixir ecosystem. It enables publishing, discovery, and consumption of packages used in production systems. This documentation covers:

- What we protect and what can go wrong (threat model)
- How we build and release software securely (SDLC)
- How we operate and respond to incidents (operations)
- How we ensure package integrity (supply chain)

## Documentation Structure

### [Threat Model](./threat-model/overview.md)

Analysis of assets, actors, threats, and mitigations.

- [Overview](./threat-model/overview.md) - Scope and methodology
- [Architecture](./threat-model/architecture.md) - System overview and trust boundaries
- [Assets](./threat-model/assets.md) - What we protect
- [Actors](./threat-model/actors.md) - Legitimate users and adversaries
- [Threats](./threat-model/threats.md) - Key threats to the ecosystem
- [Mitigations](./threat-model/mitigations.md) - How threats are addressed
- [Assumptions](./threat-model/assumptions.md) - What we assume and don't guarantee

### [Secure Development Lifecycle](./sdlc/README.md)

How we build and maintain secure software, organized into three pillars.

- [Overview](./sdlc/README.md) - SDLC structure and registers
- [Secure Build](./sdlc/build.md) - Artifact provenance, dependencies, toolchain
- [Secure Process](./sdlc/process.md) - Code review, QA, security scanning, vulnerability handling
- [Secure Runtime](./sdlc/runtime.md) - Deployment, secrets, monitoring
- [Risk Register](./sdlc/risk-register.md) - Accepted risks and mitigations
- [Exception Register](./sdlc/exception-register.md) - Approved policy deviations

### [Operations](./operations/incident-response.md)

How we operate and respond to security events.

- [Incident Response](./operations/incident-response.md) - Triage, response, notification
- [Access Control](./operations/access-control.md) - Internal access principles

### [Supply Chain Security](./supply-chain/overview.md)

How we ensure package integrity from publish to install.

- [Overview](./supply-chain/overview.md) - Supply chain security approach
- [Provenance](./supply-chain/provenance.md) - Build origin and attestations
- [Signing](./supply-chain/signing.md) - Registry signing and checksums
- [Verification](./supply-chain/verification.md) - Client-side verification

## Related Documentation

- [Client Flows](./threat-model/client-flows.md) - Authentication and verification flows
- [Endpoints](../endpoints.md) - API and repository endpoints
