# Orchestration Plan

## Project / Task

- Add native WSL/Linux parity for harness checks.

## User Problem

- Native runtime support exists for core gates, but harness validation still depends on PowerShell-only execution.

## Original Goal

- Make harness checks runnable from `native-wsl-linux` without routing through PowerShell.

## User Value

- Linux-native validation can cover orchestrator and state-contract regressions directly.

## Priority

- Primary KPI (must): Quality that reduces rework
- Secondary KPI (optional): Time saved

## MVP Scope

- Add native harness entrypoint.
- Add shared native implementations for the two current harness-backed runtime checks.
- Verify both harness scenarios on WSL.

## Non-Goal

- Full native parity for every advanced orchestrator script.
- Expanding harness to many new scenarios in this session.

## Generic Requirement

- Keep shell wrappers thin.
- Put reusable logic in `scripts/shared/`.

## UI UX Routing

- Surface: `non-UI`
- Quality Guard: `n/a`
- Primary UX concern:

## Stop If

- The work starts pulling in unrelated orchestrator parity beyond what current harness scenarios require.
- The native harness wrapper begins duplicating large chunks of logic that belong in shared code.

## Pattern

- Small Fix Pipeline

## Roles

### Planner

- Input: current native parity state and harness scenarios
- Output: focused harness parity scope

### Builder

- Input: existing PowerShell harness flow
- Output: native harness runner and shared native runtime helpers

### Reviewer

- Input: new native scripts
- Output: drift and duplication check

### Verifier

- Input: WSL command results
- Output: harness parity evidence

### Recorder

- Input: parity decision and evidence
- Output: worklog

## Scope

- Included: `scripts/bash/`, `scripts/shared/`, `docs/modes/shared/`, `worklogs/`
- Excluded: new harness scenario design, secrets parity, full orchestrator parity

## Risks

- Native helpers may drift from PowerShell behavior if future changes only land in one runtime.
- Harness parity could hide deeper orchestrator gaps if the current scenarios stay too narrow.

## Done When

- Native harness entrypoint exists.
- Both current harness scenarios pass on WSL.
- The parity roadmap reflects the new status.

## Verification

- Run Windows code rules.
- Run native WSL `run-harness-checks.sh --scenario all`.

## Why Stop Now

- The current harness gap is closed once the existing scenarios run natively and the parity roadmap is updated.

## Rollback

- Remove native harness runner and shared helpers if the runtime strategy changes.
