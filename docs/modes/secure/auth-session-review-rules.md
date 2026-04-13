# Auth Session Review Rules

Use this when code touches login, logout, session, re-authentication, account recovery, or access control.

## Authentication Error Rules

- Use generic failure messages for login, password reset, and account recovery.
- Do not reveal whether the account exists, is disabled, or has a wrong password.
- Keep HTTP and HTML behavior consistent enough to avoid easy account enumeration.

## Session Rules

- Session identifiers must be meaningless to the client.
- Session identifiers should not contain PII or business meaning.
- Prefer strict session acceptance over permissive session acceptance.
- Session lifecycle events may be logged, but raw session identifiers should be masked or hashed if logged at all.
- Regenerate the session identifier after privilege level changes or reauthentication events.
- Treat session identifiers as untrusted input if they arrive from the client.

## Reauthentication Rules

- Require reauthentication for clearly sensitive actions when the product has such flows.
- Trigger reauthentication after strong risk signals such as password change, suspicious device change, or recovery events.

## Authorization Rules

- Put repeated permission checks behind shared guards instead of copying them.
- Review high-risk actions for both authentication and authorization, not only one of them.

## Additive Fix Pattern

Prefer helpers such as:

- `safe-auth-error.*`
- `redact-user-data.*`
- `session-log-policy.*`
- `authz-guard.*`

Import the helper into the current flow instead of broadly rewriting unrelated logic.
