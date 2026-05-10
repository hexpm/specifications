# Secure Runtime

This document describes secure runtime practices for Hex registry infrastructure.

## Deployment Controls

Deployments are triggered via a Slack bot by authorized operators. The bot
initiates a CI pipeline (GitHub Actions) that builds Docker images and applies
Kubernetes manifests. Deployments are only automatically applied from the `main`
branch; other branches are validated but not deployed. The bot monitors rollout
progress (pod readiness) in real time and reports status back to Slack.
Rollbacks are performed manually by redeploying a previous commit via the same
mechanism. Concurrency controls prevent simultaneous deployments to the same
environment.

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
| GCP service account (application repos) | None in repo secrets | OIDC workload identity |
| GCP service account (infrastructure repo) | GitHub secrets (long-lived JSON key) | Direct credential, scoped per environment |
| Database credentials | Runtime secrets | Production only |

### Production

| Aspect | Implementation |
|--------|----------------|
| Secrets storage | Encrypted with GCP KMS, stored in infrastructure config |
| Application repo CI access | OIDC workload identity federation (no long-lived keys) |
| Infrastructure repo CI access | Long-lived service account key in GitHub Actions secrets, scoped per environment |
| Environment isolation | Separate credentials for staging and production |

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
