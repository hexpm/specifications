# Incident Response

This document describes incident response procedures for the Hex ecosystem.

## Incident Classification

### Severity Levels

| Level | Description | Examples |
|-------|-------------|----------|
| Critical | Active exploitation, widespread impact | Registry compromise, malicious package spreading |
| High | Significant risk, limited exploitation | Account takeovers, targeted attacks |
| Medium | Potential risk, no active exploitation | Vulnerability discovered, suspicious activity |
| Low | Minor issues, minimal impact | Policy violations, minor misconfigurations |

## Response Procedures

### Detection

- Monitoring alerts
- User reports
- Security researcher reports
- Automated scanning

### Triage

1. Assess severity and scope
2. Identify affected systems/users
3. Determine response urgency
4. Assign incident owner

### Containment

- Revoke compromised credentials
- Disable affected accounts (if necessary)
- Block malicious packages
- Isolate affected systems

### Eradication

- Remove malicious content
- Patch vulnerabilities
- Reset compromised credentials
- Verify no persistence mechanisms

### Recovery

- Restore normal operations
- Monitor for recurrence
- Communicate with affected users

### Post-Incident

- Document incident timeline
- Identify root cause
- Implement preventive measures
- Update procedures as needed

## Communication

### Internal

- Incident channel for coordination
- Regular status updates
- Clear ownership and escalation

### External

- User notification when affected
- Public disclosure when appropriate
- Coordinate with reporters

## Specific Scenarios

### Compromised Maintainer Account

1. Disable account access
2. Revoke all tokens
3. Review recent publishing activity
4. Contact maintainer via verified channel
5. Consider retiring suspicious versions

### Malicious Package

1. Mark package/version as retired
2. Notify users who downloaded recently
3. Investigate publishing account
4. Document for community awareness

### Infrastructure Compromise

1. Isolate affected systems
2. Assess scope of access
3. Rotate all credentials
4. Rebuild from known-good state
5. Full security audit
