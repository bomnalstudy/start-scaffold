# Idempotency And Pagination Rules

Use these rules when designing create, update, retry, list, or search contracts.

## Idempotency

- Mutating endpoints that may be retried should define an idempotency strategy early.
- Keep the key scope explicit: what operation it protects, for how long, and which parameters must match.
- Do not pretend retries are safe if duplicate writes can still occur.
- Separate naturally idempotent reads from retried writes that need explicit keys or dedupe storage.

## Pagination

- Prefer stable pagination contracts over ad hoc `page` and `size` behavior.
- Cursor pagination is usually safer than offset pagination for large or fast-changing collections.
- Keep list responses explicit about sort order, cursor anchor, and next-page continuation.
- Do not design list endpoints that silently change order between calls without saying so.

## Search And Filtering

- Keep filter names and semantics stable.
- Separate full-text search, structured filters, and sort semantics in the contract.
- Define not only what can be filtered, but what the default order is when filters are absent.
