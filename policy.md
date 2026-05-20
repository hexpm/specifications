# Hex Organization Dependency Policy

A `Policy` is a signed resource published by an organization that the Hex client honors at resolution time to filter the candidate set of package releases. Policies are optional and opt-in client-side; the registry server distributes them but does not enforce them.

## Resource location

`/repos/<repository>/policies/<name>` on the same backend that serves `/packages/<name>` and the other registry resources.

`<name>` matches `[a-z0-9_\-\.]+`, length 3..64, and is unique within the repository.

## Encoding

The payload is the [`Policy`](/registry/policy.proto) protobuf message, wrapped in a [`Signed`](/registry/signed.proto) envelope (RSA-SHA512 signature against the payload), gzipped, served with `Content-Type: application/octet-stream` and `Content-Encoding: gzip`.

The signing key is the repository's existing signing key — the same key already used to sign `/names`, `/versions`, and `/packages/<name>`. No new key infrastructure.

## Visibility

The `visibility` field controls who can fetch the resource:

- `VISIBILITY_PRIVATE` — the resource is served only to authenticated callers who can already access the repository. Same auth pipeline as `/packages/<name>` on a private repository.
- `VISIBILITY_PUBLIC` — the resource is served to any caller, authenticated or not, so projects that are not members of the repository can opt in to the policy.

The auth decision is made per-object by inspecting the payload's `visibility` field. The path and signing model are identical in both cases.

If the payload cannot be decoded — signature mismatch, unknown enum value, missing required field — the edge MUST fail closed and require authentication.

## Rule semantics

Each policy declares zero or more categorical rules and an optional cooldown. A release is blocked by the policy if **any** of its declared rules blocks the release.

### Advisory rule

If `advisory_min_severity` is set, the policy blocks any release that has at least one advisory whose severity is greater than or equal to `advisory_min_severity`. Severities map 1:1 to `AdvisorySeverity` in `package.proto` (`SEVERITY_NONE=0` … `SEVERITY_CRITICAL=4`).

### Retirement rule

If `retirement_reasons` is non-empty, the policy blocks any release whose `retired.reason` field is one of the listed values. Reasons map 1:1 to `RetirementReason` in `package.proto` (`RETIRED_OTHER=0` … `RETIRED_RENAMED=4`).

### Cooldown rule

If `cooldown` is set and non-zero, the policy blocks any release whose `published_at` is more recent than `now - cooldown_duration`. The grammar matches the Hex cooldown configuration grammar: `Nd`, `Nw`, `Nmo`, or `0`. Unset or `"0"` disables the rule.

When multiple active policies declare cooldowns, the effective cooldown is the strictest. Local cooldown configuration cannot lower it.

## Client behavior

A conformant client:

1. **Reads policy references from multiple opt-in sources** (e.g., project file, environment variable, global config) and composes them with AND semantics: a release must pass every active policy. The active set is deduplicated on `(repository, name)`.
2. **Fetches and verifies each active policy** before resolution. Signature verification uses the configured public key for the repository.
3. **Filters the candidate set at resolution time only.** Lockfile entries are trusted at install; filtering does not apply to already-locked versions.
4. **Caches each policy independently** with last-known-good fall-back on fetch failure (network, 5xx, signature mismatch). A maximum staleness window — recommended 30 days — bounds the suppression window for a network adversary.

## Cross-references

- [`registry/policy.proto`](/registry/policy.proto) — protobuf schema.
- [`registry/package.proto`](/registry/package.proto) — `AdvisorySeverity` and `RetirementReason` enums.
- [`registry-v2.md`](/registry-v2.md) — registry resources index.
- [Hex dependency cooldown spec](https://gist.github.com/ericmj/16488f164ca2045e12f0f79a73c45031) — sibling spec; the duration grammar and resolution-time filtering model are shared.
