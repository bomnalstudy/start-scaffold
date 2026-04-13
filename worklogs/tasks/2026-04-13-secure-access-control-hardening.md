# Orchestration Plan

## Project / Task

- Harden secure-mode further for access control, direct object reference, and wide request binding risks.

## User Problem

- Even with current secure-mode rules, access-control and mass-assignment style problems are not yet explicit enough in the scaffold.

## Original Goal

- Add source-backed guidance for access-control and request-binding risks plus import-first helper examples.

## User Value

- Reduces the chance that future app code leaks or mutates another user's data through weak object scoping.
- Gives secure-mode more concrete review language for common vibe-coding mistakes.

## Priority

- Primary KPI (must): Quality that reduces rework
- Secondary KPI (optional): Time saved

## MVP Scope

- Add access-control review rules.
- Add request-binding rules.
- Add helper examples for ownership checks and allowlisted mapping.

## Non-Goal

- Build a full authorization framework.
- Add framework-specific middleware.

## Generic Requirement

- Keep the rules reusable.
- Keep helper examples narrow and import-friendly.

## Stop If

- The docs drift into framework-specific implementation.
- The helpers become too opinionated for a scaffold.

## Pattern

- Access Control and Binding Hardening

## Roles

### Planner

- Input: current secure-mode docs plus source-backed access control guidance
- Output: narrow hardening scope

### Builder

- Input: scope
- Output: docs and helper examples

### Reviewer

- Input: rules and helpers
- Output: scaffold-fit review

### Verifier

- Input: code-rules and session guard
- Output: validation

### Recorder

- Input: rationale
- Output: worklog

## Scope

- Included: `docs/modes/secure/`, `templates/`, `skills/secure-mode/`, `worklogs/`
- Excluded: runtime authz framework code

## Risks

- Access-control rules can sound obvious unless they are tied to concrete review cues.
- Helper examples can be misread as complete security implementations if not kept minimal.

## Done When

- Secure-mode has clearer access-control and request-binding review rules.
- Helper examples exist for ownership checks and allowlisted mapping.

## Verification

- Run code-rules checks.
- Run session guard checks on the task and worklog.

## Why Stop Now

- This closes another common vibe-coding security gap without overcommitting to one stack.

## Rollback

- Remove the docs and helper examples if they prove too abstract or duplicative.
