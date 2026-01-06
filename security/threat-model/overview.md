# Threat Model Overview

This document describes the threat modelling approach for the Hex package ecosystem.

## Scope

This threat model covers:

- **hex.pm** - The package registry API and web interface
- **hexdocs.pm** - Documentation hosting
- **repo.hex.pm** - Package artifact and registry storage
- **Hex clients** - Mix, Rebar3, and Gleam build tool integrations

## Methodology

This threat model uses a hybrid approach:

1. **Asset-based analysis** - Identify what we protect
2. **Actor-based analysis** - Identify who interacts with the system
3. **Trust boundary analysis** - Identify where trust changes
4. **Threat enumeration** - Identify what can go wrong

## Framework Alignment

This threat model draws from established supply chain security frameworks:

| Framework | Focus | Reference |
|-----------|-------|-----------|
| ENISA | Package manager security risks | [Technical Advisory for Package Managers](https://www.enisa.europa.eu/) |
| OpenSSF | Repository security principles | [Principles for Package Repository Security](https://repos.openssf.org/) |
| OWASP | Application security risks | [Top 10:2025 A03 - Software Supply Chain Failures](https://owasp.org/Top10/) |
| NIST SSDF | Secure development practices | [SP 800-218](https://csrc.nist.gov/publications/detail/sp/800-218/final) |
| SLSA | Supply chain integrity levels | [SLSA Specification](https://slsa.dev/) |

## Threat Summary

| ID | Threat | Likelihood | Impact | Risk |
|----|--------|------------|--------|------|
| T1 | Malicious publication | Medium | Critical | High |
| T2 | Typosquatting | Medium | High | Medium |
| T3 | Package tampering | Low | Critical | Medium |
| T4 | Account takeover | Medium | High | High |
| T5 | Documentation attacks | Low | Medium | Low |
| T6 | Registry compromise | Low | Critical | Medium |
| T7 | Denial of service | Medium | Medium | Medium |
| T8 | Vulnerable dependencies | High | Variable | High |
| T9 | Unmaintained packages | High | Medium | Medium |
| T10 | Build pipeline compromise | Low | Critical | Medium |

See [Threats](./threats.md) for detailed descriptions.

## Document Structure

| Document | Purpose |
|----------|---------|
| [Architecture](./architecture.md) | System overview and trust boundaries |
| [Assets](./assets.md) | What we protect |
| [Actors](./actors.md) | Legitimate users and adversaries |
| [Threats](./threats.md) | Key threats to the ecosystem |
| [Mitigations](./mitigations.md) | How threats are addressed |
| [Assumptions](./assumptions.md) | What we assume and don't guarantee |

## Hex-Specific Considerations

### Registry Role

Hex.pm is the distribution point, not the build system. This means:

- **Limited control over T10**: Build happens on maintainer machines
- **Strong control over T3**: Registry signing and checksums provide tamper evidence
- **Shared responsibility for T1/T4**: Authentication controls, but maintainers control their credentials

### Elixir/Erlang Ecosystem Factors

- **BEAM immutability**: Less attack surface than native code execution
- **Smaller ecosystem**: Fewer packages means potentially less noise for detection
- **Active community**: Strong review culture in Elixir community

## Maintenance

This threat model is a living document. It should be reviewed:

- When significant features are added
- When new threat vectors are identified
- Periodically (at least annually)
