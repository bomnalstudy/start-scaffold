# Orchestration Plan

## Project / Task

- Add a runtime parity roadmap and fill the missing native worklog validation path for WSL/Linux.

## User Problem

- The scaffold can now run in WSL natively for some paths, but parity status is not yet explicit and one validation path is still missing.

## Original Goal

- Make native runtime parity more concrete by documenting the remaining gaps and implementing the missing worklog validation path.

## User Value

- Makes Linux-native support easier to trust and easier to extend without guessing what is still missing.

## Priority

- Primary KPI (must): Quality that reduces rework
- Secondary KPI (optional): Time saved

## MVP Scope

- Add a runtime parity roadmap document.
- Add native `run-worklog-checks` support and connect it to native orchestration.
- Verify the new native validation path and keep the change scoped.

## Non-Goal

- Reach full parity for secrets, harness, or orchestrator advanced runtime in this session.
- Reorganize every existing script into new folders immediately.

## Generic Requirement

- Keep shell wrappers thin.
- Prefer shared Python logic over large duplicated shell behavior.

## UI UX Routing

- Surface: `non-UI`
- Quality Guard: `n/a`
- Primary UX concern:

## Stop If

- The work starts expanding into full secrets or advanced orchestrator parity.
- Shared logic begins to fragment across shells instead of consolidating.

## Pattern

- Small Fix Pipeline

## Roles

### Planner

- Input: current runtime state and native gaps
- Output: parity roadmap and minimal next upgrade

### Builder

- Input: existing PowerShell checks and bash entrypoints
- Output: shared worklog checker and updated bash orchestration

### Reviewer

- Input: new roadmap and native scripts
- Output: parity scope check

### Verifier

- Input: code rules plus native command results
- Output: validation evidence

### Recorder

- Input: key parity decisions
- Output: worklog

## Scope

- Included: `docs/modes/shared/`, `scripts/shared/`, `scripts/bash/`, `worklogs/`
- Excluded: secrets parity, advanced orchestrator parity, harness parity implementation

## Risks

- The parity matrix could drift if updates are not kept current.
- Native wrappers could still diverge if too much logic stays outside `scripts/shared/`.

## Done When

- Runtime parity status is documented clearly.
- Native worklog checks exist and are wired into native orchestration.
- Validation evidence exists for the new path.

## Verification

- Run Windows code rules.
- Run shared Python code rules.
- Run native worklog check through bash entrypoints.

## Why Stop Now

- This closes a concrete parity gap and makes the remaining upgrade path explicit without over-expanding the session.

## Rollback

- Remove the new roadmap doc and native worklog wrapper if the parity direction changes.
