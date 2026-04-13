# Orchestration Plan

## Project / Task

- UI/UX follow-up integration for the scaffold workflow

## User Problem

- The scaffold already has UI quality rules and external skills, but the active workflow does not make UI surface classification and guard selection explicit enough.
- The user also wants the broader backlog written down so future work does not get lost.

## Original Goal

- Document the current scaffold backlog and finish the pending UI/UX follow-up by wiring the UI guard flow into scaffold-facing docs and templates.

## User Value

- Future sessions can quickly remember the next priorities.
- UI work starts with clearer rules, so generated frontend output is less likely to drift into cluttered or low-quality results.

## Priority

- Primary KPI (must): Time saved
- Secondary KPI (optional): Quality that reduces rework

## MVP Scope

- Create a backlog document for the current requested task list.
- Add explicit UI surface classification and quality guard selection guidance to the scaffold workflow artifacts used during planning.
- Keep the change limited to docs/templates and avoid broad process redesign.

## Non-Goal

- Implement the orchestrator versioning system itself.
- Build the failure-pattern system, traffic distribution layer, or auto-security feature in this session.
- Redesign unrelated workflow or repository structure.

## Generic Requirement

- Keep the guidance reusable for both Codex and Claude sessions.
- Keep the planning additions short enough for normal MVP work.

## UI UX Routing

- Surface: `shared`
- Quality Guard: `frontend-quality-guard` with browser-first scaffold docs aligned to `web-ui-quality-guard`
- Primary UX concern: make UI task routing obvious early so future sessions do not miss the correct quality rules

## Stop If

- The UI/UX follow-up starts expanding into a full design system or a broad workflow rewrite.
- The backlog document turns into implementation detail that should live in separate task plans instead.

## Pattern

- Feature Delivery Pipeline

## Roles

### Planner

- Input: user backlog items, existing UI/UX rules, current scaffold docs
- Output: minimal doc changes that make UI task routing explicit

### Builder

- Input: selected docs and template files
- Output: updated roadmap, task plan template guidance, and session log

### Reviewer

- Input: changed docs
- Output: scope check against MVP and drift risks

### Verifier

- Input: updated task plan and worklog paths
- Output: focused orchestration/session guard results

### Recorder

- Input: key changes and assumptions
- Output: worklog entry for the session

## Scope

- Included: `docs/`, `templates/`, `worklogs/`
- Excluded: `scripts/`, runtime pipeline code, infrastructure implementation

## Risks

- UI guidance may stay too abstract if the plan template does not clearly ask for surface classification.
- Scope may drift into broader roadmap design if the backlog notes become too detailed.

## Done When

- The requested task list is documented in the repository.
- The scaffold planning flow explicitly records UI surface classification and matching quality guard for UI work.
- A session worklog exists with rationale, verification, and remaining risks.

## Verification

- Review the changed docs for alignment with `docs/modes/ux-ui/ui-ux-product-rules.md`.
- Run focused orchestration/session guard checks on the new task plan and worklog.

## Why Stop Now

- Once the backlog is captured and UI routing is embedded into the normal planning flow, the missing UX/UI follow-up is closed without overbuilding the process.

## Rollback

- Remove the new roadmap file and revert the template/doc wording if the additions prove too noisy for daily use.
