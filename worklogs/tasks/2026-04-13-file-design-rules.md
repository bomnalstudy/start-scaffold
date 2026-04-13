# Orchestration Plan

## Project / Task

- Add global file design rules and extend code checks for split signals

## User Problem

- Large files are not just a git friction problem. They are usually a design problem that grows until commits and pushes become painful.
- The user wants a repository-wide rule, not a mode-specific skill, so file design problems are addressed earlier.

## Original Goal

- Add repository-wide file design rules and extend code checks so mixed-responsibility and file-growth signals are surfaced earlier.

## User Value

- Encourages file splitting before a change becomes hard to review or hard to push.
- Makes file design a default operating rule rather than an optional cleanup step.

## Priority

- Primary KPI (must): Time saved
- Secondary KPI (optional): Quality that reduces rework

## MVP Scope

- Add a shared file design rules document.
- Add a global rule to `AGENTS.md`.
- Extend code-rules checks with a few high-signal mixed-responsibility warnings.

## Non-Goal

- Build language-perfect architectural analysis.
- Auto-refactor files.
- Enforce framework-specific design dogma.

## Generic Requirement

- Keep the rules cross-cutting and repository-wide.
- Prefer a small number of high-signal heuristics over a noisy ruleset.

## Stop If

- The checks become too speculative and start producing low-value warnings.
- The implementation drifts into a full linting framework redesign.

## Pattern

- Small Fix Pipeline

## Roles

### Planner

- Input: current coding rules, file-growth guard work, user request
- Output: concise global design-rule plan

### Builder

- Input: `AGENTS.md`, shared docs, code-rules script
- Output: new document and heuristic checks

### Reviewer

- Input: changed docs and checks
- Output: signal/noise review

### Verifier

- Input: task/worklog and code-rules output
- Output: focused validation

### Recorder

- Input: rationale and remaining risks
- Output: session log

## Scope

- Included: `AGENTS.md`, `docs/`, `scripts/`, `worklogs/`
- Excluded: app code refactors, CI integration, auto-splitting

## Risks

- Heuristic rules can over-warn if they are too broad.
- Some file types legitimately mix concerns at a small scale.

## Done When

- A shared file design rules doc exists.
- `AGENTS.md` states the file design rule globally.
- Code checks warn on a few obvious mixed-responsibility signals.

## Verification

- Run session guard checks on the task and worklog.
- Run code-rules checks after the new heuristics are added.

## Why Stop Now

- Once the repository has a clear global rule and a few practical signals, we can tune from real usage instead of overdesigning upfront.

## Rollback

- Remove the new heuristics and document if they create too much noise.
