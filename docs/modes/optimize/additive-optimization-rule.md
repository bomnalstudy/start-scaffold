# Additive Optimization Rule

When optimizing existing code, prefer additive changes that reduce risk.

## Preferred Remediation Style

- add a request wrapper instead of rewriting every fetch call at once
- add a cache client or helper instead of rebuilding every data path
- add a concurrency limiter or queue adapter instead of inlining ad hoc throttles everywhere
- add a scheduler, worker handoff, or deferred hook instead of over-editing a stable UI file
- add importable measurement helpers before spreading logging code across many files

## Why

- additive changes are easier to review
- behavior changes are more localized
- rollback is simpler
- file growth and accidental regressions stay smaller

## Stop And Re-Scope If

- the optimization requires a cross-cutting rewrite to many unrelated files
- the actual bottleneck is still unverified
- the proposed cache or queue layer would hide correctness issues
