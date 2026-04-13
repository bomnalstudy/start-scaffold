# User Data Leakage Rules

Use these rules when handling user identifiers, profile data, auth state, session data, or personal information.

## Core Principle

- User data should be visible only to the minimum code path that truly needs it.
- Logs, errors, debug traces, and client-visible state should expose less data than the business flow itself sees.

## Treat As Sensitive By Default

- email addresses
- phone numbers
- session identifiers
- access tokens
- user ids when they are linkable to a real account
- IP addresses when stored or displayed outside narrow security use
- government or payment identifiers
- internal account state such as locked, disabled, suspended

## Safe Handling Rules

- Prefer redacted or pseudonymous forms in logs.
- Prefer short-lived correlation ids over raw user identifiers in operational traces.
- Keep user-visible errors generic when account existence or auth state could be inferred.
- Keep session data server-side when possible; do not embed user or account meaning inside session ids.
- Do not store user identity data in browser-visible storage unless the product explicitly requires it and the risk is documented.

## Allowed Logging Pattern

- log `userPresent=true` or `profileLoaded=true`
- log a hashed or redacted stable identifier only when operational correlation truly needs it
- log session lifecycle events without raw session token values
- prefer a salted hash of the session id over the raw session id if session correlation is truly needed

## Avoid

- `Login failed, invalid user`
- `Account disabled for jane@example.com`
- `Loaded user profile for 010-1234-5678`
- raw email, phone, session id, or access token in debug traces
