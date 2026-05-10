# Access Control

This document describes access control for Hex infrastructure.

## Application Access Levels

### Public Access

- Package downloads (public packages)
- Registry metadata
- Documentation viewing

### Authenticated User Access

- Publishing packages (own packages)
- Managing account settings
- Viewing private packages (with permission)

### Organization Admin Access

- Managing organization members
- Configuring private repositories
- Billing management

### Operator Access

- Infrastructure administration
- Incident response
- Policy enforcement

## Infrastructure Access

### Production Systems

A small number of operators have access to production infrastructure.
Access is logged via GCP Cloud Logging and GKE audit logs.

### Cloud Provider Access

- Application repository CI/CD uses OIDC workload identity federation (no long-lived service account keys)
- Infrastructure repository CI/CD uses a long-lived GCP service account key stored as a GitHub Actions secret, scoped per environment
- Kubernetes access controlled via RBAC
- Infrastructure changes applied via CI pipeline

### Database Access

- Direct production database access restricted to operators
- Application accesses database via dedicated service credentials

## Audit

### Logging

- GKE and infrastructure events logged to GCP Cloud Logging
- Application-level audit log for security-relevant actions (publish, ownership changes, etc.)
