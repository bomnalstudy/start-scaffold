# Reference Patterns And Tooling

Use these references when choosing how much tooling a database-backed feature actually needs.

## API Contract References

- OpenAPI fits explicit request and response contracts, typed documentation, client generation, and test tooling.
- JSON:API is useful as a consistency reference for naming, relationship links, and pagination conventions even if you do not adopt the full format.
- Stripe’s public API docs are a strong reference for idempotent writes, cursor pagination, and predictable error handling.

## Data Modeling References

- PostgreSQL docs are a strong reference for constraints, foreign keys, and index tradeoffs even if the final database is not PostgreSQL.
- Prisma is a useful reference for relation modeling and schema readability even when not using Prisma itself.
- Prisma multi-file schema and multi-schema docs are useful references for organizing larger data models without collapsing everything into one file or one namespace.

## Selection Rule

- Use no extra framework when a small, explicit contract and migration plan are enough.
- Use OpenAPI when the team needs stable client/server contracts or generated docs.
- Use a schema tool or ORM only when it reduces drift rather than hiding the data model.
- Treat examples from these tools as references, not mandatory stack choices.
