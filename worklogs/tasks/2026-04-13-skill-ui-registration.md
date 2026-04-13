# Orchestration Plan

## Project / Task

- Add UI metadata for repo-local skills so they are easier to invoke from the skill UI

## User Problem

- Repo-local skills exist, but they do not appear callable in the same way as built-in or system skills.
- The likely missing piece is skill UI metadata for discovery and default prompt behavior.

## Original Goal

- Register repo-local skills with lightweight UI metadata so they can be discovered more consistently.

## User Value

- Makes custom repo skills easier to find and invoke.
- Reduces confusion between "skill exists on disk" and "skill appears in the skill UI".

## Priority

- Primary KPI (must): Time saved
- Secondary KPI (optional): Quality that reduces rework

## MVP Scope

- Add `agents/openai.yaml` metadata to the repo-local custom skills.
- Keep metadata simple: display name, short description, default prompt where useful.
- Avoid icon work or external dependencies in this session.

## Non-Goal

- Guarantee behavior of the external UI beyond what metadata supports.
- Add rich icons or external connectors.
- Rework the actual skill content.

## Generic Requirement

- Keep metadata consistent and human-readable.
- Match the naming and purpose of each skill.

## Stop If

- The UI requires additional undocumented metadata beyond the simple interface fields.
- The change starts drifting into packaging or marketplace work.

## Pattern

- Small Fix Pipeline

## Roles

### Planner

- Input: existing skills and system skill metadata examples
- Output: minimal repo-local metadata plan

### Builder

- Input: custom skill folders
- Output: `agents/openai.yaml` files

### Reviewer

- Input: metadata files
- Output: naming and prompt sanity check

### Verifier

- Input: task/worklog
- Output: session guard validation

### Recorder

- Input: registration assumptions
- Output: session log

## Scope

- Included: `skills/`, `worklogs/`
- Excluded: icons, marketplace setup, external docs

## Risks

- The host UI may still need a reload or only index global skills.
- Some UI surfaces may ignore repo-local metadata even when present.

## Done When

- Repo-local custom skills have `agents/openai.yaml` metadata.
- The repository has a clear record of the registration attempt and assumptions.

## Verification

- Run session guard checks on the task and worklog.
- Review the metadata files for consistency.

## Why Stop Now

- Once the metadata exists, the next meaningful test is in the skill UI itself rather than more speculative file changes.

## Rollback

- Remove the metadata files if they prove useless or incompatible with the host UI.
