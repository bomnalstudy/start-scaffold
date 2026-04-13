# Orchestration Plan

## Project / Task

- Add the first concrete state snapshot and patch-apply flow for orchestrator-mode.

## User Problem

- The shared state rules exist, but there is not yet a concrete patch path that rejects stale snapshots and enforces owner-scoped writes.

## Original Goal

- Turn the shared state contract into a usable patch validation skeleton.

## User Value

- Reduces conflicting shared-value writes before multiple orchestrators start mutating the same state.
- Makes the stale snapshot rule actionable instead of only conceptual.

## Priority

- Primary KPI (must): Quality that reduces rework
- Secondary KPI (optional): Time saved

## MVP Scope

- Add state helper functions.
- Add a patch-apply script with stale snapshot rejection and owner-scope checks.
- Add example snapshot and patch files.
- Document the patch flow for orchestrator-mode.

## Non-Goal

- Build a full persistent state service.
- Implement merge queues or locks.
- Replace the host wrapper or harness runtime.

## Generic Requirement

- Keep the patch flow inspectable from files.
- Keep rejection output explicit and machine-readable.

## Stop If

- The script starts growing into a full orchestration runtime.
- Ownership rules become too fuzzy to validate mechanically.

## Pattern

- Shared State Patch Skeleton

## Roles

### Planner

- Input: state contract and ownership rules
- Output: first patch-apply scope

### Builder

- Input: scripts and templates
- Output: helper, patch script, examples, doc

### Reviewer

- Input: patch validation behavior
- Output: scope and rule check

### Verifier

- Input: dry-run commands and session guard
- Output: stale reject and valid dry-run validation

### Recorder

- Input: final flow
- Output: worklog

## Scope

- Included: `scripts/`, `templates/`, `docs/modes/orchestrator/`, `worklogs/`
- Excluded: networked state storage, adapter execution

## Risks

- Dot-path patching could be too permissive if owner prefixes are not checked carefully.
- Example files could be mistaken for production data if naming is not explicit.

## Done When

- A valid worker patch can pass dry-run validation.
- A stale patch can be rejected with an explicit error.
- The flow is documented for orchestrator-mode.

## Verification

- Run one valid dry-run patch.
- Run one stale-snapshot rejection check.
- Run session guard checks on the task and worklog.

## Why Stop Now

- This closes the biggest missing link in orchestrator-mode without overbuilding storage or locking.

## Rollback

- Remove the patch flow files if the contract shape changes significantly.
