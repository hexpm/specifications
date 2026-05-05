# Access Control

This document describes access control principles for Hex infrastructure.

## Principles

### Least Privilege

- Access granted only as needed for role
- Elevated access requires justification
- Regular access reviews

### Separation of Duties

- Production access separated from development
- Administrative actions require multiple approvals where practical
- Audit capabilities separated from operational roles

### Defense in Depth

- Multiple layers of access control
- Network segmentation where possible
- Application-level authorization enforcement

## Access Levels

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

- Access requires business justification
- MFA required for all access
- Access logged and auditable
- Time-limited access where possible

### Database Access

- Direct access restricted
- Query logging enabled
- Sensitive data access tracked

### Cloud Provider Access

- IAM roles with minimal permissions
- Service accounts for automation
- Human access for break-glass only

## Audit

### Logging

- Authentication events logged
- Authorization decisions logged
- Administrative actions logged

### Review

- Regular review of access grants
- Removal of unused access
- Investigation of anomalies
