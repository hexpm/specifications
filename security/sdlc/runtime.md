# Secure Runtime

This document describes secure runtime practices for Hex registry infrastructure.

## Deployment Controls

Deployments are performed using a Slack bot that can trigger deployments, monitor deployment status, and monitor container image builds.

<!-- TODO: Verify and expand deployment controls (branch protection, required approvals, deployment environments, rollback procedures) -->

## Secrets Management

### In Development

| Practice | Status |
|----------|--------|
| No secrets in source code | Enforced |
| Environment-based configuration | Implemented |
| Separate credentials per environment | Implemented |

### In CI/CD

| Secret | Storage | Access |
|--------|---------|--------|
| GCP service account | GitHub secrets | OIDC workload identity |
| Database credentials | Runtime secrets | Production only |

### Production

<!-- TODO: Verify production secrets management -->

| Aspect | Implementation |
|--------|----------------|
| Secrets storage | GCP Secret Manager |
| Access control | IAM policies |
| Rotation | Defined procedures |

## Service Ownership

### Response Team

Incident response roles:

| Role | Responsibility |
|------|----------------|
| Security lead | Triage and coordination |
| Development | Fix implementation |
| Operations | Deployment and monitoring |

## Monitoring

### Health and Availability

| Activity | Purpose |
|----------|---------|
| Health checks | Verify service availability |
| Uptime monitoring | Track service availability |

### Error Tracking

| Activity | Purpose |
|----------|---------|
| Error monitoring | Sentry integration |
| Alerting | Notification on anomalies |

### Metrics

| Activity | Purpose |
|----------|---------|
| Telemetry | Performance and usage metrics |
| Logging | Audit trail and debugging |

## Related Documentation

- [Secure Build](./build.md) - Build pipeline and dependencies
- [Secure Process](./process.md) - Code review and quality assurance
- [Operations - Incident Response](../operations/incident-response.md) - Incident handling
