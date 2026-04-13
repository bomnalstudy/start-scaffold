# API Contract Rules

Use these rules when designing endpoints, handlers, or database-backed actions.

## Contract First

- Define request DTOs and response DTOs before wiring implementation.
- Keep write DTOs narrow and explicit.
- Do not bind whole request bodies directly into persistent models.
- Reuse API schema components only where meaning truly matches.

## Read And Write Separation

- Separate read shape from write shape when their needs differ.
- Do not leak internal storage shape if a safer or smaller response contract exists.
- Keep list responses and detail responses intentionally different when needed.
- Do not force unrelated entities into a shared generic response wrapper only for convenience.

## Consistency

- Keep naming stable across route params, DTO fields, and stored identifiers.
- Prefer predictable pagination, filtering, and sorting contracts.
- Define error shape and not-found behavior early.
- Define idempotency behavior early for retried writes and unstable network paths.

## Safety

- Ownership and authorization checks must be designed alongside the contract, not added later.
- Avoid wide update APIs that let callers modify fields they do not own.
- Prefer additive helper layers, validators, and mappers before broad in-place handler rewrites.
