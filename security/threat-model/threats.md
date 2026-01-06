# Threats

This document enumerates key threats to the Hex ecosystem. See [Overview](./overview.md) for methodology and framework references.

## T1: Malicious Package Publication

### Description

An attacker publishes a package containing malicious code designed to harm users or exfiltrate data.

### Attack Vectors

| Vector | Description | ENISA Category |
|--------|-------------|----------------|
| Compromised maintainer | Attacker gains access to legitimate maintainer account | Supply chain attacks |
| Malicious maintainer | Insider threat from package owner | Supply chain attacks |
| Compromised CI/CD | Attack on maintainer's build/publish pipeline | Supply chain attacks |
| Social engineering | Convincing maintainer to add malicious contributor | Supply chain attacks |

### Real-World Examples

- **event-stream (npm, 2018)**: Maintainer transferred ownership; new owner added malicious code targeting cryptocurrency wallets
- **ua-parser-js (npm, 2021)**: Compromised maintainer account used to publish crypto-mining malware
- **ctx/phpass (PyPI, 2022)**: Dormant packages hijacked via expired maintainer email domains
- **Shai-Hulud (npm, 2025)**: Self-replicating worm via compromised accounts; exploited post-install scripts to propagate
- **LiteLLM (PyPI, 2026)**: Compromised package delivering multi-stage credential stealer
- **RubyGems credential campaign (2025)**: 60+ malicious gems stealing social media credentials

### Impact

| Dimension | Assessment |
|-----------|------------|
| Severity | Critical |
| Scope | All users who install the package |
| Effect | Arbitrary code execution, data exfiltration, supply chain propagation |

### Framework Alignment

| Framework | Reference |
|-----------|-----------|
| ENISA | Section 3.2 - Supply chain attacks |
| OpenSSF | Account Compromise, Package Manipulation |
| OWASP A03 | Malicious packages |
| SSDF | PS.1 (Protect code), PS.2 (Integrity verification) |

### Related Controls

See [Mitigations](./mitigations.md#identity--access) for controls.

## T2: Typosquatting / Dependency Confusion

### Description

An attacker publishes packages with names designed to be confused with legitimate packages, either through typographical similarity or namespace collision.

### Attack Vectors

| Vector | Description | ENISA Category |
|--------|-------------|----------------|
| Typosquatting | Similar names: `pheonix` vs `phoenix` | Typosquatting |
| Combosquatting | Adding prefixes/suffixes: `phoenix-utils` | Typosquatting |
| Dependency confusion | Internal package name collision with public registry | Namespace confusion |
| Namespace squatting | Claiming names before legitimate projects | Typosquatting |
| Slopsquatting | Registering packages that LLMs hallucinate | AI-assisted attacks |

### Real-World Examples

- **Dependency confusion attacks (2021)**: Researcher Alex Birsan demonstrated attacks on Apple, Microsoft, PayPal using internal package names
- **crossenv (npm, 2017)**: Typosquat of `cross-env` with credential-stealing code
- **python3-dateutil (PyPI, 2019)**: Typosquat of `python-dateutil` with malicious payload
- **huggingface-cli (PyPI, 2024)**: Researcher registered AI-hallucinated package name; received 30,000+ downloads in 3 months

### Impact

| Dimension | Assessment |
|-----------|------------|
| Severity | High |
| Scope | Users who mistype, misconfigure, or trust AI-generated dependencies |
| Effect | Installation of attacker-controlled code |

### AI-Assisted Attack Vector (Slopsquatting)

LLMs used for code generation hallucinate nonexistent package names at significant rates:

| Finding | Source |
|---------|--------|
| 19.7% of 2.23M code samples contained hallucinated packages | [USENIX 2024](https://www.usenix.org/publications/loginonline/we-have-package-you-comprehensive-analysis-package-hallucinations-code) |
| 205,474 unique nonexistent packages identified in testing | USENIX 2024 |
| ~45% of hallucinated packages regenerate consistently | USENIX 2024 |
| Open-source models: ~21% hallucination rate vs commercial ~5% | [arXiv 2501.19012](https://arxiv.org/html/2501.19012v1) |

Attackers can monitor LLM outputs, identify consistently hallucinated package names, and register them with malicious code. The predictability of hallucinations (same prompts produce same fake packages) makes this attack scalable.

### Framework Alignment

| Framework | Reference |
|-----------|-----------|
| ENISA | Section 3.2.3 - Typosquatting, Section 3.2.4 - Namespace confusion |
| OpenSSF | Ecosystem Threats |
| OWASP A03 | Dependency confusion |
| SSDF | PW.4 (Reuse existing well-secured software) |

### Related Controls

See [Mitigations](./mitigations.md#ecosystem-protections) for controls.

## T3: Package Tampering

### Description

An attacker modifies package artifacts after publication, either in transit or at rest.

### Attack Vectors

| Vector | Description | ENISA Category |
|--------|-------------|----------------|
| Storage compromise | Unauthorized access to S3, CDN, or origin servers | Infrastructure attacks |
| Man-in-the-middle | Interception and modification during download | Infrastructure attacks |
| Cache poisoning | Corrupting CDN or proxy caches | Infrastructure attacks |
| Mirror compromise | Attacking unofficial mirrors | Infrastructure attacks |

### Real-World Examples

- **Codecov (2021)**: Bash uploader script modified to exfiltrate CI environment variables
- **PHP Git server (2021)**: Unauthorized commits to PHP source with backdoor
- **Gentoo GitHub (2018)**: Repository compromise with malicious ebuilds

### Impact

| Dimension | Assessment |
|-----------|------------|
| Severity | Critical |
| Scope | All users who download tampered packages |
| Effect | Code different from what maintainer published |

### Framework Alignment

| Framework | Reference |
|-----------|-----------|
| ENISA | Section 3.2.2 - Compromised legitimate packages |
| OpenSSF | Infrastructure Threats |
| OWASP A03 | Insufficient integrity verification |
| SSDF | PS.2 (Integrity verification), PS.3 (Archive releases) |
| SLSA | Build Track L2-L4 (Tamper resistance) |

### Related Controls

See [Mitigations](./mitigations.md#supply-chain-integrity) and [Supply Chain - Verification](../supply-chain/verification.md).

## T4: Account Takeover

### Description

An attacker gains unauthorized access to a maintainer or administrator account.

### Attack Vectors

| Vector | Description | ENISA Category |
|--------|-------------|----------------|
| Credential reuse | Password from other breaches | Supply chain attacks |
| Phishing | Fake login pages, OAuth consent abuse | Supply chain attacks |
| Token leakage | API keys in logs, repos, screenshots | Supply chain attacks |
| Session hijacking | Cookie theft, XSS exploitation | Supply chain attacks |
| Email domain expiry | Takeover of expired maintainer email domains | Supply chain attacks |

### Real-World Examples

- **ua-parser-js (2021)**: npm account compromised via credential stuffing
- **coa/rc (npm, 2021)**: Maintainer account compromised, malicious versions published
- **PyPI ctx (2022)**: Account recovered via expired email domain

### Impact

| Dimension | Assessment |
|-----------|------------|
| Severity | High to Critical (depends on account privileges) |
| Scope | Packages owned by compromised account |
| Effect | Unauthorized publishing, package takeover, ecosystem-wide impact for admins |

### Framework Alignment

| Framework | Reference |
|-----------|-----------|
| ENISA | Section 3.2.2 - Compromised legitimate packages |
| OpenSSF | Account Compromise |
| OWASP A03 | Compromised maintainer accounts |
| SSDF | PO.5 (Secure environments), PS.1 (Protect code) |

### Related Controls

See [Mitigations](./mitigations.md#identity--access) for controls.

## T5: Documentation-Based Attacks

### Description

An attacker exploits documentation hosting to attack users viewing package documentation.

### Attack Vectors

| Vector | Description |
|--------|-------------|
| Cross-site scripting (XSS) | Malicious scripts in documentation HTML |
| JavaScript injection | Exploiting documentation rendering |
| Phishing via docs | Fake login forms or credential harvesting |
| Malicious links | Links to malware or phishing sites |

### Impact

| Dimension | Assessment |
|-----------|------------|
| Severity | Medium |
| Scope | Users viewing malicious documentation |
| Effect | Session theft, credential phishing, malware distribution |

### Framework Alignment

| Framework | Reference |
|-----------|-----------|
| OpenSSF | User Interface Security |
| OWASP | A03 (XSS in documentation systems) |

### Related Controls

See [Mitigations](./mitigations.md#documentation-isolation) for controls.

## T6: Registry Infrastructure Compromise

### Description

An attacker gains access to registry infrastructure, enabling wide-scale attacks.

### Attack Vectors

| Vector | Description | ENISA Category |
|--------|-------------|----------------|
| Application vulnerability | Exploiting bugs in registry software | Infrastructure attacks |
| Insider threat | Malicious or compromised operator | Supply chain attacks |
| Cloud provider compromise | Attack on underlying infrastructure | Infrastructure attacks |
| Supply chain on registry | Attack on registry's dependencies | Supply chain attacks |

### Real-World Examples

- **RubyGems (2013)**: Vulnerability allowed arbitrary gem replacement
- **npm (2018)**: Credential leak affecting old packages
- **PyPI (2022)**: Phishing campaign targeting maintainers

### Impact

| Dimension | Assessment |
|-----------|------------|
| Severity | Critical |
| Scope | Entire ecosystem |
| Effect | Full control over package distribution |

### Framework Alignment

| Framework | Reference |
|-----------|-----------|
| ENISA | Section 3.2.2 - Compromised legitimate packages |
| OpenSSF | Infrastructure Threats |
| OWASP A03 | Build pipeline compromise |
| SSDF | PO.5 (Secure environments), PS.1 (Protect code) |

### Related Controls

See [Mitigations](./mitigations.md#infrastructure-security) and [Operations](../operations/access-control.md).

## T7: Denial of Service

### Description

An attacker degrades or disrupts registry availability.

### Attack Vectors

| Vector | Description |
|--------|-------------|
| Volumetric attacks | DDoS flooding |
| Resource exhaustion | Large uploads, expensive queries |
| Application-layer attacks | Exploiting API rate limits |
| Dependency on registry | CI/CD pipelines blocked during outage |

### Impact

| Dimension | Assessment |
|-----------|------------|
| Severity | Medium to High |
| Scope | All users during outage |
| Effect | Unable to publish or install packages, CI/CD failures |

### Framework Alignment

| Framework | Reference |
|-----------|-----------|
| OpenSSF | Infrastructure availability |
| SSDF | PO.5 (Environment availability) |

### Related Controls

See [Mitigations](./mitigations.md#availability) for controls.

## T8: Vulnerable Dependencies (Transitive)

### Description

Packages contain known vulnerabilities, either directly or through transitive dependencies, that expose users to security risks.

### Attack Vectors

| Vector | Description | ENISA Category |
|--------|-------------|----------------|
| Direct vulnerabilities | Known CVEs in direct dependencies | Inherent vulnerabilities |
| Transitive vulnerabilities | Vulnerabilities in dependencies of dependencies | Inherent vulnerabilities |
| Outdated dependencies | Using versions with known security issues | Inherent vulnerabilities |
| Unpatched vulnerabilities | Maintainer not addressing reported issues | Unmaintained packages |

### Real-World Examples

- **Log4Shell (2021)**: CVE-2021-44228 affected thousands of applications through transitive dependencies
- **left-pad (2016)**: Unpublishing broke thousands of builds (availability, not security)
- **colors.js/faker.js (2022)**: Maintainer sabotage affecting downstream users

### Impact

| Dimension | Assessment |
|-----------|------------|
| Severity | Variable (depends on vulnerability) |
| Scope | All users of affected dependency chain |
| Effect | Inherited vulnerabilities, delayed patching |

### Framework Alignment

| Framework | Reference |
|-----------|-----------|
| ENISA | Section 3.1 - Packages with inherent vulnerabilities |
| OpenSSF | Dependency Security |
| OWASP A03 | Third-party component vulnerabilities |
| SSDF | PW.4 (Verify third-party components), RV.1 (Identify vulnerabilities) |

### Related Controls

See [Mitigations](./mitigations.md#dependency-security) and [SDLC - Secure Build](../sdlc/build.md#dependencies).

## T9: Unmaintained/Abandoned Packages

### Description

Packages that are no longer actively maintained pose increasing security risks over time.

### Attack Vectors

| Vector | Description | ENISA Category |
|--------|-------------|----------------|
| Unpatched vulnerabilities | No security updates for discovered issues | Unmaintained packages |
| Stale dependencies | Outdated transitive dependencies | Unmaintained packages |
| Account recovery attacks | Takeover of abandoned accounts/domains | Supply chain attacks |
| Compatibility issues | Breaking changes in runtime/ecosystem | Unmaintained packages |

### Real-World Examples

- **event-stream (2018)**: Maintenance transferred to malicious actor due to maintainer burnout
- **request (npm)**: Deprecated but still widely used, no security patches
- **PyPI ctx (2022)**: Abandoned package hijacked via expired email domain

### Impact

| Dimension | Assessment |
|-----------|------------|
| Severity | Medium (increasing over time) |
| Scope | Users depending on unmaintained packages |
| Effect | Accumulating technical debt, security exposure |

### Framework Alignment

| Framework | Reference |
|-----------|-----------|
| ENISA | Section 3.1.2 - Unmaintained packages |
| OpenSSF | Ecosystem Health |
| SSDF | PW.4.4 (Verify components throughout lifecycle) |

### Related Controls

See [Mitigations](./mitigations.md#ecosystem-health) for controls.

## T10: Build Pipeline Compromise (Client-Side)

### Description

An attacker compromises the build or CI/CD pipeline of package maintainers, injecting malicious code before it reaches the registry.

### Attack Vectors

| Vector | Description |
|--------|-------------|
| CI/CD credential theft | Stealing publish tokens from CI systems |
| Build system compromise | Modifying build scripts or dependencies |
| Source repository attacks | Compromising GitHub/GitLab accounts |
| IDE/toolchain attacks | Malicious IDE extensions or build tools |
| Build cache poisoning | Injecting malicious artifacts into CI cache layers |

### Real-World Examples

- **SolarWinds (2020)**: Build system compromise injected backdoor into signed software
- **Codecov (2021)**: CI script modified to exfiltrate secrets
- **GitHub Actions supply chain**: Attackers targeting reusable workflows
- **Ultralytics (PyPI, 2024)**: GitHub Actions workflow compromised; build cache poisoned during compilation

### Impact

| Dimension | Assessment |
|-----------|------------|
| Severity | Critical |
| Scope | All users of packages built via compromised pipeline |
| Effect | Malicious code in legitimately-signed packages |

### Framework Alignment

| Framework | Reference |
|-----------|-----------|
| OpenSSF | Build Integrity |
| OWASP A03 | Build pipeline compromise |
| SSDF | PO.3 (Toolchain security), PO.5 (Secure environments) |
| SLSA | Build Track (all levels) |

### Related Controls

See [Supply Chain - Provenance](../supply-chain/provenance.md).

## Framework Cross-Reference

| Threat | ENISA Section | OpenSSF Category | OWASP A03 | SSDF Practices |
|--------|---------------|------------------|-----------|----------------|
| T1 | 3.2 Supply chain | Account Compromise, Package Manipulation | Malicious packages | PS.1, PS.2 |
| T2 | 3.2.3-4 Typosquatting, Namespace confusion | Ecosystem Threats | Dependency confusion | PW.4 |
| T3 | 3.2.2 Compromised packages | Infrastructure Threats | Insufficient integrity | PS.2, PS.3 |
| T4 | 3.2.2 Compromised packages | Account Compromise | Compromised accounts | PO.5, PS.1 |
| T5 | - | User Interface Security | XSS | - |
| T6 | 3.2.2 Compromised packages | Infrastructure Threats | Build pipeline | PO.5, PS.1 |
| T7 | - | Infrastructure Availability | - | PO.5 |
| T8 | 3.1 Inherent vulnerabilities | Dependency Security | Component vulnerabilities | PW.4, RV.1 |
| T9 | 3.1.2 Unmaintained packages | Ecosystem Health | - | PW.4.4 |
| T10 | - | Build Integrity | Build pipeline | PO.3, PO.5, SLSA |

## Future Threats Under Monitoring

| Threat | Description | Status |
|--------|-------------|--------|
| AI-generated malicious code | LLM-generated packages designed to evade detection | Monitoring |
| Quantum cryptography threats | Future impact on registry signing | Long-term |
| EU CRA requirements | Potential regulatory compliance requirements | Monitoring |

