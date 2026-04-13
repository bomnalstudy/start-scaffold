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
5. `docs/modes/secure/coding-rules.md`
6. `docs/modes/secure/multi-machine-secrets.md`
7. `docs/modes/secure/file-growth-guard.md`
8. `secure-secrets/README.md`

Focus on:

- secrets handling
- auth-sensitive changes
- high-risk change review
- sensitive logging and redaction
- unsafe sinks and storage patterns
- prevention-first safety checks
- oversized file and push-friction prevention

Avoid loading unrelated UI or performance docs unless the task truly needs them.
