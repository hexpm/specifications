# Risk Register

This document tracks accepted security risks and their mitigations for Hex registry infrastructure.

## Active Risks

| ID | Risk | Severity | Status | Mitigation | Reference |
|----|------|----------|--------|------------|-----------|
| R-001 | Basic Authentication maintained for backward compatibility | Medium | Mitigating | OAuth2 migration planned; rate limiting in place | Security Audit 2026 |
| R-002 | Documentation hosted as full websites (HTML/JS) | Low | Accepted | Malicious content removed upon report | Security Audit 2026 |
| R-003 | User enumeration via API | Low | Accepted | Users are public for package publication; profile info is user-provided | Security Audit 2026 |
| R-004 | No WAF | Low | Accepted | SQL injection prevented by Ecto; XSS prevented by CSP; little added value expected | Security Audit 2026 |

## Risk Assessment Criteria

### Severity Levels

| Level | Description |
|-------|-------------|
| Critical | Immediate threat to core infrastructure or user data |
| High | Significant security impact requiring prioritized remediation |
| Medium | Moderate security impact with acceptable short-term risk |
| Low | Minor security consideration with minimal impact |

### Status Definitions

| Status | Description |
|--------|-------------|
| Accepted | Risk acknowledged and accepted with mitigations |
| Mitigating | Active work to reduce risk |
| Resolved | Risk eliminated or reduced to acceptable level |

## Review Process

- Risks are reviewed quarterly or when significant changes occur
- New risks identified during security audits are added to this register
- Resolved risks are moved to the archive section below

## Archived Risks

| ID | Risk | Resolution Date | Resolution |
|----|------|-----------------|------------|
| - | - | - | - |
