# Orchestration Plan

## Project / Task

- Turn the first real `failure-pattern-mode` result into a lightweight prevention rule in the repository.

## User Problem

- We identified one actionable pattern: repo-side skill registration work started before confirming what the host slash UI actually owns.
- The repository needs a small prevention rule so future sessions check the host boundary first instead of guessing from repo files alone.

## Original Goal

- Record the first real failure pattern and connect it to a concrete prevention rule.

## User Value

- Reduces wasted repo-side changes when a behavior is actually controlled by the chat host or editor UI.
- Makes slash/skill registration debugging faster and less speculative.

## Priority

- Primary KPI (must): Time saved
- Secondary KPI (optional): Quality that reduces rework

## MVP Scope

- Record the first real failure pattern in a mode-owned failure-pattern document.
- Add a short shared skill-operations note about host-owned versus repo-owned behavior.
- Avoid adding heavyweight checklists or hooks in this pass.

## Non-Goal

- Add a new hook or code-rules check.
- Rework slash integration beyond the documented prevention rule.
- Create a heavy postmortem system.

## Generic Requirement

- Keep the prevention rule short and operational.
- Use the lightest enforcement that still helps the next session.

## Stop If

- The change starts expanding into broader skill packaging or UI debugging work.
- The repository needs host-specific behavior that cannot be stated as a simple operator rule.

## Pattern

- Lightweight Prevention Insertion

## Roles

### Planner

- Input: recent skill registration work and the first real failure-pattern result
- Output: minimal prevention insertion plan

### Builder

- Input: shared skill docs and failure-pattern docs
- Output: one prevention note plus one recorded pattern entry

### Reviewer

- Input: updated docs
- Output: scope and wording sanity check

### Verifier

- Input: task/worklog
- Output: session guard validation

### Recorder

- Input: final prevention rule
- Output: worklog entry

## Scope

- Included: `docs/modes/failure-pattern/`, `docs/modes/shared/`, `worklogs/`
- Excluded: hooks, scripts, UI metadata redesign

## Risks

- The note could be too vague to help if it does not clearly separate host-owned and repo-owned behavior.
- Overcorrecting into process overhead would hurt the lightweight goal of `failure-pattern-mode`.

## Done When

- The first real failure pattern is recorded in the repository.
- Shared skill guidance reminds future sessions to confirm host ownership before repo-side registration work.

## Verification

- Review the updated docs for directness and scope.
- Run session guard checks on the task and worklog.

## Why Stop Now

- The pattern is best prevented with a small operator rule first.
- Stronger enforcement should wait for repeat evidence.

## Rollback

- Remove the new note and pattern entry if they prove noisy or unhelpful.
