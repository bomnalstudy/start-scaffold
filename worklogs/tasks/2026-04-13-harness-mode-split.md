# Orchestration Plan

## Project / Task

- Split harness work from orchestrator-mode and add first harness-mode rules plus scenario templates.

## User Problem

- Harness and orchestrator concerns are starting to blur even though they serve different purposes.
- The scaffold needs a separate harness mode so validation work stays distinct from runtime orchestration design.

## Original Goal

- Separate harness-mode from orchestrator-mode and add practical harness rules to the scaffold.

## User Value

- Keeps runtime design and verification design from drifting into each other.
- Gives future regression checks a clearer home.

## Priority

- Primary KPI (must): Quality that reduces rework
- Secondary KPI (optional): Time saved

## MVP Scope

- Add a new harness-mode skill.
- Add harness-mode docs for guide, scenario naming, and stale snapshot rejection.
- Update shared mode references so orchestrator and harness are clearly separated.

## Non-Goal

- Implement the full harness runtime.
- Move every old harness reference in one pass.
- Add new automated checks in this pass.

## Generic Requirement

- Keep the split explicit and easy to follow in chat.
- Keep harness docs focused on verification, not runtime ownership.

## Stop If

- The split starts turning into a large doc migration.
- The new mode becomes too generic to distinguish from orchestrator-mode.

## Pattern

- Mode Boundary Clarification

## Roles

### Planner

- Input: existing orchestrator references and harness template
- Output: narrow split plan

### Builder

- Input: modes docs and skills
- Output: new harness-mode docs and references

### Reviewer

- Input: split definitions
- Output: overlap and clarity review

### Verifier

- Input: task/worklog
- Output: session guard validation

### Recorder

- Input: mode split decisions
- Output: worklog

## Scope

- Included: `docs/modes/harness/`, `skills/harness-mode/`, shared mode references, `templates/harness-spec.md`, `worklogs/`
- Excluded: runtime harness scripts

## Risks

- Old references may still mention harness under orchestrator-mode.
- Over-splitting could add naming overhead if the distinction is not maintained.

## Done When

- Harness has its own mode, docs, and skill.
- Shared mode definitions describe orchestrator and harness separately.

## Verification

- Review the updated mode references.
- Run session guard checks on the task and worklog.

## Why Stop Now

- The conceptual split is the high-value change; runtime harness work can follow later.

## Rollback

- Remove harness-mode and revert the shared mode references if the split proves confusing.
