---
name: db-mode
description: Narrow the session to database and API contract design work in this repository. Use when the user asks to design schemas, model ownership, query boundaries, DTOs, CRUD flows, or database-backed API contracts before implementation.
---

# DB Mode

Read first:

1. `docs/modes/shared/agent-modes.md`
2. `docs/modes/db/db-api-design-guide.md`
3. `docs/modes/db/data-modeling-rules.md`
4. `docs/modes/db/api-contract-rules.md`
5. `docs/modes/db/data-organization-rules.md`
6. `docs/modes/db/schema-evolution-and-index-rules.md`
7. `docs/modes/db/idempotency-and-pagination-rules.md`
8. `docs/modes/db/reference-patterns-and-tooling.md`
9. the current task plan and worklog
10. `docs/modes/secure/access-control-review-rules.md` when ownership or cross-user access matters
11. `docs/modes/orchestrator/state-ownership-rules.md` when shared state or pipeline contracts overlap with database values

Focus on:

- entity and table boundaries
- ownership and relationship clarity
- clean grouping of canonical, derived, and relationship data
- write and read path separation
- API DTO shape and field allowlists
- pagination, filtering, and mutation contract design
- idempotency and retry-safe mutation design
- index, constraint, and migration fit
- schema and contract naming consistency
- additive schema evolution instead of risky broad rewrites

Do not jump straight into ORM-specific implementation before the data model and API contract are clear.
