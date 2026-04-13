# Orchestration Plan

## Project / Task

- Add the first real harness scenarios and a script harness runner for them.

## User Problem

- Harness-mode now exists conceptually, but it still needs concrete scenarios and a repeatable execution path.

## Original Goal

- Turn harness-mode into a usable verification loop with the first two concrete scenarios.

## User Value

- Gives the scaffold repeatable regression checks for the earliest orchestrator contracts.
- Makes harness-mode feel operational instead of purely documentary.

## Priority

- Primary KPI (must): Quality that reduces rework
- Secondary KPI (optional): Time saved

## MVP Scope

- Add two harness scenario files.
- Add a script harness runner that executes and asserts those scenarios.
- Keep the scenarios tightly scoped to host-wrapper dry-run and stale snapshot rejection.

## Non-Goal

- Build a generic YAML-driven harness engine.
- Cover every orchestrator flow.
- Add end-to-end application harnesses.

## Generic Requirement

- Keep failure output short and specific.
- Verify stable contracts, not private implementation details.

## Stop If

- The runner starts turning into a full framework.
- The scenarios expand beyond the two high-value checks.

## Pattern

- First Harness Loop

## Roles

### Planner

- Input: harness docs plus current wrapper and state scripts
- Output: narrow scenario set

### Builder

- Input: scenarios and harness runner
- Output: repeatable script checks

### Reviewer

- Input: scenario files and harness runner
- Output: clarity and scope review

### Verifier

- Input: harness run and session guard
- Output: pass/fail validation

### Recorder

- Input: first harness decisions
- Output: worklog

## Scope

- Included: `harness/`, `scripts/run-harness-checks.ps1`, `worklogs/`
- Excluded: generic parser framework, application E2E

## Risks

- The runner could become a hidden mini-framework too early.
- Scenario expectations could drift from the documented examples if the contracts change.

## Done When

- Two harness scenarios exist.
- The runner can execute them and fail loudly on mismatch.

## Verification

- Run `.\scripts\run-harness-checks.ps1 -Scenario all`.
- Run session guard checks on the task and worklog.

## Why Stop Now

- The first two scenarios are enough to prove the harness loop without overbuilding the engine.

## Rollback

- Remove the runner and scenario files if the harness direction changes sharply.
