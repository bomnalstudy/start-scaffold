# Orchestration Plan

## Project / Task

- Harden `failure-pattern-mode` into a pattern-to-enforcement workflow

## User Problem

- The repository has a failure-pattern mode, but it is still too abstract.
- The user wants it to work as a practical path from repeated problem to prevention mechanism.

## Original Goal

- Make `failure-pattern-mode` produce reusable prevention records with triggers, enforcement targets, and escalation paths.

## User Value

- Turns retrospective observations into concrete prevention work.
- Makes recurring mistakes easier to convert into rules, checks, or hooks.

## Priority

- Primary KPI (must): Time saved
- Secondary KPI (optional): Quality that reduces rework

## MVP Scope

- Add a failure-pattern recording template.
- Update the mode skill to use `pattern -> trigger -> enforcement -> escalation`.
- Keep the mode lightweight and operational.

## Non-Goal

- Build automated pattern detection.
- Create a full incident-management workflow.
- Add new hooks or rules in this session unless the user asks separately.

## Generic Requirement

- The mode should support both coding and workflow mistakes.
- The output should stay short enough for normal coding sessions.

## Stop If

- The mode becomes a long-form retrospective process.
- The template becomes too detailed to use quickly.

## Pattern

- Feature Delivery Pipeline

## Roles

### Planner

- Input: existing mode, worklog patterns, user request
- Output: concise enforcement-oriented pattern flow

### Builder

- Input: mode skill and failure-pattern docs
- Output: updated skill plus pattern template

### Reviewer

- Input: changed docs
- Output: actionability review

### Verifier

- Input: task/worklog
- Output: focused session guard validation

### Recorder

- Input: final mode changes
- Output: worklog

## Scope

- Included: `skills/`, `docs/`, `worklogs/`
- Excluded: automation scripts, new repo-wide rules

## Risks

- The workflow may still feel too process-heavy if it asks for too many fields.
- Enforcement recommendations can become over-aggressive without real recurrence evidence.

## Done When

- The mode points to a concrete pattern template.
- The mode tells the agent how to choose an enforcement type.
- The mode stays short and reusable.

## Verification

- Run session guard checks on the task and worklog.
- Review the mode for actionable output shape.

## Why Stop Now

- Once the mode can turn repeated failures into concrete prevention records, it is useful enough to test on real patterns.

## Rollback

- Revert the template and skill wording if the process proves too heavy in practice.
