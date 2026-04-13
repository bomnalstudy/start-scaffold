# Orchestration Plan

## Project / Task

- Split code-rules helpers from the main script and add secure helper templates for additive remediation.

## User Problem

- The main code-rules script is starting to grow too large, and secure-mode needs ready-made helper examples for low-risk import-based fixes.

## Original Goal

- Keep code-rules maintainable and make additive secure fixes easier to apply.

## User Value

- Reduces maintenance friction in the rules engine.
- Gives future secure fixes reusable import-first building blocks.

## Priority

- Primary KPI (must): Quality that reduces rework
- Secondary KPI (optional): Time saved

## MVP Scope

- Split helper and security-specific code-rules logic into separate script files.
- Add secure helper template examples.
- Document how to use the helper templates.

## Non-Goal

- Rebuild code-rules as a full plugin system.
- Add runtime dependencies or framework-specific helper packages.

## Generic Requirement

- Keep the main rules script smaller and easier to scan.
- Keep helper templates narrow and import-friendly.

## Stop If

- The split starts introducing lots of indirection for little gain.
- The helper templates become too framework-specific to reuse.

## Pattern

- Rule Engine Maintenance

## Roles

### Planner

- Input: current rules script and secure remediation guidance
- Output: narrow split and helper scope

### Builder

- Input: scripts and templates
- Output: split rules helpers and secure helper examples

### Reviewer

- Input: updated script layout and templates
- Output: maintainability and reuse review

### Verifier

- Input: code-rules and session guard
- Output: validation

### Recorder

- Input: split rationale
- Output: worklog

## Scope

- Included: `scripts/`, `templates/`, `docs/modes/secure/`, `worklogs/`
- Excluded: runtime integration into app code

## Risks

- Helper splits can make rule flow harder to follow if the boundaries are weak.
- Template examples can age if not kept generic.

## Done When

- The main code-rules script is smaller.
- Secure helper examples exist and are documented.

## Verification

- Run code-rules checks.
- Run session guard checks on the task and worklog.

## Why Stop Now

- This keeps the scaffold maintainable while adding practical secure remediation examples.

## Rollback

- Merge the helper scripts back if the split proves unhelpful.
