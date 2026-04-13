# Orchestration Plan

## Project / Task

- Harden repository UX/UI rules with typography, color, icon, overflow, and reference-first guidance

## User Problem

- The current UX/UI rules set the general direction, but they are still too loose for consistent visual decisions.
- The user wants stronger guardrails around colors, fonts, icon style, layout overflow, and reference usage.

## Original Goal

- Strengthen the repository UX/UI rules so future UI work starts from clearer product design constraints.

## User Value

- Reduces visual drift and amateur-looking outputs.
- Makes UI work more repeatable without turning the repo into a full design system.

## Priority

- Primary KPI (must): Time saved
- Secondary KPI (optional): Quality that reduces rework

## MVP Scope

- Extend the UX/UI rules doc with guidance for typography, color, icons, overflow, and reference-first work.
- Update `ux-ui-mode` so these rules appear in the active workflow, not just in passive docs.
- Keep the guidance implementation-oriented and avoid building a full brand system.

## Non-Goal

- Define a full design token library.
- Pick final brand fonts for every future product.
- Build automated visual tests in this session.

## Generic Requirement

- Keep the rules practical for both web and app-oriented UI work.
- Base the guidance on public design and accessibility sources.

## Stop If

- The rules drift into a full design manual instead of operational defaults.
- The new rules become so specific that they stop being reusable across MVP projects.

## UI UX Routing

- Surface: `shared`
- Quality Guard: `frontend-quality-guard` with stronger browser-first guidance
- Primary UX concern: reduce visual inconsistency and prevent low-signal polish mistakes before implementation starts

## Pattern

- Feature Delivery Pipeline

## Roles

### Planner

- Input: current UX/UI rules and user-requested constraints
- Output: stronger but still reusable rule set

### Builder

- Input: UX/UI docs and mode skill
- Output: updated rules and workflow

### Reviewer

- Input: changed docs
- Output: signal/noise review on the new constraints

### Verifier

- Input: task/worklog and docs
- Output: focused session guard validation

### Recorder

- Input: key changes and remaining risks
- Output: worklog entry

## Scope

- Included: `docs/`, `skills/`, `worklogs/`
- Excluded: UI implementation code, design token packages, visual regression tooling

## Risks

- The rules may still need refinement after real UI tasks.
- Font guidance without a fixed brand font set must stay generic enough to avoid premature lock-in.

## Done When

- UX/UI rules cover typography, color, icon style, overflow, and reference-first workflow.
- `ux-ui-mode` explicitly instructs the agent to use the stronger rules.
- The repository has a clearer operational baseline for real UI work.

## Verification

- Run session guard checks on the task and worklog.
- Review the updated rules for consistency with public design and accessibility guidance.

## Why Stop Now

- Once these stronger defaults are documented and linked into the active mode, the repository is ready for the next real UX/UI implementation pass.

## Rollback

- Revert the new rule sections if they prove too rigid or too noisy in actual UI work.
