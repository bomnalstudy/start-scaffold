# 2026-04-13 DB Mode Bootstrap

## Original Goal

- Add a new `db-mode` skill for database and API contract design.

## MVP Scope

- Create the repo-local skill entry point.
- Add starter docs under `docs/modes/db/`.
- Register the mode in shared mode and routing docs.
- Add reference-guided rules for idempotency, pagination, constraints, and index-aware schema evolution.

## Non-Goal

- Implement a real schema, ORM layer, or API runtime.

## Done When

- `db-mode` exists as a reusable skill.
- The mode has a clear read order and focus.
- Shared docs list `db-mode` as a standard mode.

## Generic Requirement

- Keep the mode broad enough to fit different stacks and storage choices.

## Stop If

- The work expands into framework-specific database implementation.
- The mode starts prescribing one fixed ORM or database engine.
