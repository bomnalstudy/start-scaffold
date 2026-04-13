# Sensitive Logging Rule

Use this rule for debug output, error messages, and operational logs.

## Rule

- Logs must help debugging without exposing secret or identity-bearing values.
- Log shapes should stay stable, but sensitive fields must be omitted or redacted.

## Never Log Raw Values For

- passwords
- tokens
- api keys
- authorization headers
- passphrases
- client secrets
- raw vault contents

## Preferred Pattern

- log field presence, not full value
- log ids or hashes only when they are safe enough for correlation
- log redacted placeholders such as `[REDACTED]` when needed for debugging

## Good Example

```text
Loaded secrets profile start-scaffold. Keys loaded: 6.
```

## Bad Example

```text
Loaded Authorization header: Bearer abcdef...
```

## Error Messages

- keep user-facing errors short
- put only non-sensitive correlation data in debug logs
- never echo raw secret input back into exceptions or console output
