# Orchestration Plan

## Project / Task

- Create repository mode skills and implement `ux-ui-mode` first

## User Problem

- The repository now has a named mode system, but the modes do not yet exist as actual skill files the agent can trigger directly.
- The user wants a practical `ux-ui-mode` first so topic-specific work can continue in chat with narrower context.

## Original Goal

- Split the named mode system into concrete skill files and make `ux-ui-mode` usable first.

## User Value

- The agent can switch into a predictable topic mode from chat without manually restating which rules and docs to load.

## Priority

- Primary KPI (must): Time saved
- Secondary KPI (optional): Quality that reduces rework

## MVP Scope

- Add repo-local skill folders for `ux-ui-mode`, `secure-mode`, `performance-mode`, `orchestrator-mode`, and `failure-pattern-mode`.
- Make `ux-ui-mode` the most complete of the set by explicitly routing UX/UI work to the right docs, surface classification, and output shape.
- Update scaffold docs so the new skills are discoverable.

## Non-Goal

- Build automatic skill dispatch scripts in this session.
- Fully implement every mode with scripts and validations.
- Redesign the existing speed-gate skills.

## Generic Requirement

- Keep each skill concise and repository-specific.
- Make the trigger descriptions readable enough that a future agent can pick the right mode from normal chat language.

## UI UX Routing

- Surface: `shared`
- Quality Guard: `frontend-quality-guard` with browser-first scaffold docs aligned to `web-ui-quality-guard`
- Primary UX concern: make `ux-ui-mode` load the right UX/UI rules quickly and keep non-UI docs out unless needed

## Stop If

- The new skills start duplicating large amounts of existing documentation.
- The work drifts into building wrappers or automation scripts instead of the skill files themselves.

## Pattern

- Feature Delivery Pipeline

## Roles

### Planner

- Input: existing mode docs, current skill patterns
- Output: minimal skill set and one stronger first implementation

### Builder

- Input: `skills/`, mode definitions, UI docs
- Output: new skill folders and linked documentation

### Reviewer

- Input: skill files and doc updates
- Output: scope/drift check and trigger clarity review

### Verifier

- Input: new task plan and worklog
- Output: focused session guard checks

### Recorder

- Input: changed skill set and assumptions
- Output: session worklog

## Scope

- Included: `skills/`, `docs/`, `worklogs/`
- Excluded: `scripts/`, editor integrations, external skill installation

## Risks

- Mode descriptions may be too vague to trigger reliably if they do not include concrete example language.
- `ux-ui-mode` may still be too abstract if it does not clearly say what to read, what to record, and what to avoid.

## Done When

- Repo-local skill files exist for all five named modes.
- `ux-ui-mode` is concrete enough to use immediately for chat-driven UX/UI work.
- Repository docs point to the new mode skills.

## Verification

- Review the skill descriptions and `ux-ui-mode` instructions for trigger clarity.
- Run focused session guard checks on the plan/worklog.

## Why Stop Now

- Once the mode skills exist and `ux-ui-mode` is usable, the repository has the minimum structure needed to try the pattern in real chat work before overbuilding automation.

## Rollback

- Remove the new skill folders and related doc references if the mode system proves too noisy or redundant.
