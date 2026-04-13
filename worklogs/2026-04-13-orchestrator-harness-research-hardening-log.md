# Session Log

## Date

2026-04-13

## Original Goal

- Find the most important missing orchestration and harness patterns from source-backed references and add them to the scaffold.

## MVP Scope (This Session)

- Review current source-backed references.
- Add missing orchestrator reliability rules.
- Add missing harness observability and fixture-isolation rules.
- Keep the changes doc-first.

## Key Changes

- Added orchestrator reliability rules for checkpoint boundaries, replay, interrupts, retry taxonomy, and idempotency keys.
- Added harness observability and fixture-isolation rules for better evidence and cleaner scenario setup.

## Validation

- Planned a session guard validation for the new doc-only pass.

## Mistakes / Drift Signals Observed

- The main risk is importing framework language too literally instead of adapting it to the scaffold.

## Prevention for Next Session

- Turn only the highest-value patterns into scripts or checks.
- Keep framework-specific details out unless they directly improve this repo.

## Direction Check

- Why this still matches the original goal:
- The scaffold now covers several durability and harness gaps that were not explicit before.
- We can stop at the doc layer because the user asked to search and reinforce first.

## Next Tasks

1. Promote one or two reliability rules into concrete adapter or patch-flow code later.
2. Add harness assertions for captured logs once debug-log checks expand.
3. Revisit retries and idempotency once a real host adapter exists.
