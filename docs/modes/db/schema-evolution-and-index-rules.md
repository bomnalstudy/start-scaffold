# Schema Evolution And Index Rules

Use these rules when the design needs migrations, constraints, or query-fit indexing.

## Evolution

- Prefer additive schema changes before destructive ones.
- Name backfill, dual-read, or dual-write needs early if existing semantics will change.
- Do not hide a semantic schema change behind a vague column rename.

## Constraints

- Put ownership, uniqueness, and referential integrity in the design, not only in application code.
- Name likely `UNIQUE`, `FOREIGN KEY`, and required-not-null constraints early.
- If a relationship matters to correctness, the schema should make that relationship explicit.

## Index Fit

- Name indexes from the actual query shape, not from guesswork.
- Tie likely indexes to filters, sort keys, pagination anchors, and join paths.
- Avoid "index every field" thinking; every index has write and storage cost.
- If the system will add indexes on a hot table later, call out migration and rollout risk.
