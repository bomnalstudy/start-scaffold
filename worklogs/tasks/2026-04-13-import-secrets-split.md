# Orchestration Plan

## Project / Task

- Split `scripts/import-project-secrets.ps1` into a thinner entry script plus reusable helpers

## User Problem

- The new file-design check surfaced `scripts/import-project-secrets.ps1` as a script that mixes entry flow, reporting, and helper logic.
- The repository should follow its own file-splitting rules when a real signal appears.

## Original Goal

- Reduce responsibility mixing in `scripts/import-project-secrets.ps1` by moving reusable helper logic into a separate file.

## User Value

- Makes the secrets import flow easier to review and maintain.
- Validates that the scaffold's new file design rules lead to concrete cleanup, not only warnings.

## Priority

- Primary KPI (must): Time saved
- Secondary KPI (optional): Quality that reduces rework

## MVP Scope

- Extract reusable import helper functions into a colocated helper script.
- Keep the main import script focused on argument handling, validation, and top-level flow.
- Verify that the code-rules warning is reduced or removed.

## Non-Goal

- Redesign the export/import format.
- Build a full shared secrets module for every script in this session.
- Change the user-visible import behavior.

## Generic Requirement

- Keep the split small and local to the import flow.
- Preserve current command-line behavior.

## Stop If

- The split starts forcing broader changes across unrelated secrets scripts.
- The import behavior changes beyond structural cleanup.

## Pattern

- Small Fix Pipeline

## Roles

### Planner

- Input: current import script and warning output
- Output: minimal split boundary

### Builder

- Input: import script
- Output: helper file plus leaner entry script

### Reviewer

- Input: changed scripts
- Output: responsibility-boundary review

### Verifier

- Input: code-rules output and task/worklog
- Output: focused validation

### Recorder

- Input: split rationale and remaining risks
- Output: session log

## Scope

- Included: `scripts/`, `worklogs/`
- Excluded: export script redesign, vault format changes

## Risks

- Helper extraction could accidentally change import behavior if shared state is moved incorrectly.
- The warning may remain if the split is too shallow.

## Done When

- `import-project-secrets.ps1` is structurally smaller and more focused.
- Reusable helper logic lives in a separate file.
- Code-rules results are equal or better than before.

## Verification

- Run session guard checks on the task and worklog.
- Run code-rules checks after the split.

## Why Stop Now

- Once the main script is thinner and the warning is reduced, the repository has proven the new rule on a real case without over-refactoring the secrets flow.

## Rollback

- Restore the original single-file script if helper extraction changes behavior unexpectedly.
