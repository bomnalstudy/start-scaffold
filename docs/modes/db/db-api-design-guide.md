# DB API Design Guide

`db-mode` is the design mode for database-backed features.

Use it when the work starts with questions like:

- what entities exist
- who owns each record
- how values are written, read, or updated
- what the API should accept and return
- how to avoid drifting schema and endpoint behavior

## Primary Goal

- Make data ownership, API contracts, and storage boundaries explicit before implementation.
- Help the project group related data cleanly without forcing one fixed schema pattern.

## Design Order

1. name the main entities
2. define ownership and relationships
3. define canonical versus derived data boundaries
4. define write paths, validation boundaries, and idempotency needs
5. define read paths, query shape, and pagination
6. define API request and response contracts
7. name constraint, index, and schema evolution concerns
8. only then choose implementation details

## Output Shape

- entity list
- ownership rules
- main relationships
- data grouping and namespace notes
- write DTOs and read DTOs
- endpoint or action contract
- pagination and retry rules when relevant
- migration or evolution notes when needed
