# 2026-04-13 DB Mode Bootstrap Log

## What changed

- Added `db-mode` as a repo-local skill with DB and API contract design focus.
- Added starter docs for data modeling and API contract rules.
- Added reference-guided docs for schema evolution, indexing, idempotency, pagination, and tooling choices.
- Added data-organization guidance for grouping related records, separating canonical and derived data, and making meaningful relationship models explicit.
- Registered the mode in shared mode and routing docs.

## Why

- Database and API design need a dedicated narrow context instead of being mixed into secure, optimize, or orchestrator work.
- The mode needed stronger external references so later schema and endpoint work can start from stable patterns instead of ad hoc habits.

## Verification

- Run `run-session-guard-checks`.
- Run `run-code-rules-checks`.

## Source References

- OpenAPI Specification: https://spec.openapis.org/oas/v3.1.2.html
- JSON:API format and recommendations: https://jsonapi.org/format/index.html , https://jsonapi.org/recommendations/
- PostgreSQL constraints and indexes: https://www.postgresql.org/docs/14/ddl-constraints.html , https://www.postgresql.org/docs/9.4/sql-createindex.html
- Stripe idempotency and pagination patterns: https://docs.stripe.com/api/idempotent_requests?lang=curl , https://docs.stripe.com/apis
- Prisma relations and organization references: https://www.prisma.io/docs/orm/prisma-schema/data-model/relations , https://www.prisma.io/docs/orm/more/best-practices , https://www.prisma.io/docs/orm/prisma-schema/data-model/multi-schema

## Mistakes / Drift Signals Observed

- The mode is intentionally still scaffold-level and does not yet enforce one storage engine or framework.

## Prevention for Next Session

- Keep implementation details out until a real schema or endpoint design task appears.

## Direction Check

- Stop here because the mode bootstrap is complete and reusable.
- Next work should fill in project-specific schema and API conventions only when a concrete feature exists.

## Next Tasks

- Add schema naming and migration rules if the project starts real DB work.
- Add API pagination and idempotency guidance when endpoint design begins.

## Remaining risk

- `db-mode` is intentionally generic for now, so real project rules will still need to be layered on top later.
