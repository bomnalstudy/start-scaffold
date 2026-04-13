---
name: secure-mode
description: Narrow the session to security-sensitive work in this repository. Use when the user asks for safer defaults, secret handling, auth-sensitive changes, secure coding review, or protection against risky implementation mistakes.
---

# Secure Mode

Read first:

1. `AGENTS.md`
2. `docs/modes/shared/agent-modes.md`
3. `docs/modes/secure/secure-by-default-rules.md`
4. `docs/modes/secure/sensitive-logging-rule.md`
5. `docs/modes/secure/common-vulnerability-patterns.md`
6. `docs/modes/secure/additive-remediation-rule.md`
7. `docs/modes/secure/user-data-leakage-rules.md`
8. `docs/modes/secure/auth-session-review-rules.md`
9. `docs/modes/secure/optional-security-tooling.md`
10. `docs/modes/secure/helper-template-examples.md`
11. `docs/modes/secure/access-control-review-rules.md`
12. `docs/modes/secure/request-binding-rules.md`
13. `docs/modes/secure/coding-rules.md`
14. `docs/modes/secure/multi-machine-secrets.md`
15. `docs/modes/secure/file-growth-guard.md`
16. `secure-secrets/README.md`

Focus on:

- secrets handling
- auth-sensitive changes
- high-risk change review
- sensitive logging and redaction
- unsafe sinks and storage patterns
- additive remediation by helper or wrapper import
- common vulnerability pattern review
- user data leakage prevention
- auth and session review
- optional external scanner fit assessment
- helper-template based additive fixes
- access-control and object-reference review
- request binding and DTO allowlists
- prevention-first safety checks
- oversized file and push-friction prevention

Avoid loading unrelated UI or optimization docs unless the task truly needs them.
