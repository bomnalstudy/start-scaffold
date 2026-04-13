# Secure By Default Rules

Use these rules when implementing or reviewing code that could expose secrets, auth state, user input, or sensitive operational data.

## Core Principle

- Prefer safe defaults that reduce the chance of accidental exposure.
- Add convenience only after the safe baseline is clear.

## Required Defaults

- Never store plaintext secrets in tracked files.
- Treat auth, secrets, and identity-bearing values as high-risk by default.
- Validate inputs before using them in host calls, state changes, or persistence.
- Redact sensitive values from logs, debug output, and failure messages.
- Prefer explicit allowlists over open-ended pass-through behavior.

## High-Risk Changes

Treat these as high-risk even in scaffold work:

- auth or session handling
- secret export/import flows
- host invocation payloads
- persistence of tokens or credentials
- debug or audit logs that may include identifiers or secrets

## Safe Review Questions

- Does this change introduce a new place where a secret could be printed or stored?
- Does this change trust user input too early?
- Does this change persist auth material in a broad or browser-visible location?
- Does this change expose internal error details that should stay redacted?

## Preferred Patterns

- normalize and validate before execution
- store only the minimum data needed
- keep secret material out of normal logs
- separate high-risk helpers from broad utility files

## Avoid

- convenience logging of tokens, headers, passwords, or vault contents
- browser storage of long-lived tokens without an explicit security reason
- HTML injection sinks without explicit sanitization
- broad payload forwarding without field checks
