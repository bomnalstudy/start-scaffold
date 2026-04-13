# Orchestration Plan

## Project / Task

- Add scaffold guards against oversized files and push-time git friction

## User Problem

- As files grow too large and stay unsplit, the working tree becomes messy and pushes get harder to reason about.
- The user wants this prevented by scaffold behavior, not only by manual discipline.

## Original Goal

- Add scaffold checks that catch oversized source files before commit or push so file growth problems are blocked earlier.

## User Value

- Prevents files from silently growing into hard-to-review, hard-to-commit, hard-to-push states.
- Turns file splitting into an enforced workflow instead of a late cleanup task.

## Priority

- Primary KPI (must): Time saved
- Secondary KPI (optional): Quality that reduces rework

## MVP Scope

- Add commit-time guardrails for staged oversized source files.
- Add push-time verification that re-runs repository code rules before push succeeds.
- Document the new scaffold rule in the repository docs and worklog.

## Non-Goal

- Build an automatic file splitter.
- Enforce language-specific refactor rules beyond simple size growth checks.
- Solve every possible dirty-worktree cause in this session.

## Generic Requirement

- Keep the checks lightweight enough for normal daily use.
- Focus on high-signal blocking rules rather than noisy warnings.

## Stop If

- The guard starts blocking common safe workflows without a clear file-growth signal.
- The implementation grows into a full lint framework redesign.

## Pattern

- Small Fix Pipeline

## Roles

### Planner

- Input: current hooks, code-rules checks, user pain point
- Output: minimal growth-guard design

### Builder

- Input: hook scripts and coding rules docs
- Output: commit/push guards plus docs

### Reviewer

- Input: changed scripts and docs
- Output: false-positive and scope review

### Verifier

- Input: updated plan/worklog and focused script checks
- Output: session guard and code-rules verification

### Recorder

- Input: implementation details and remaining risks
- Output: session worklog

## Scope

- Included: `scripts/`, `docs/`, `worklogs/`
- Excluded: runtime app code, IDE integration, auto-refactor tooling

## Risks

- Commit-time blocking can feel noisy if the threshold is too strict.
- A line-count rule alone will not catch every maintainability problem.

## Done When

- Staged oversized source files can be blocked before commit.
- Pre-push re-checks code rules so oversize issues are harder to ignore.
- The new scaffold behavior is documented.

## Verification

- Run focused session guard checks on the task and worklog.
- Run code-rules checks after the script changes.

## Why Stop Now

- Once the scaffold blocks obvious file-growth problems before commit and push, the main failure mode is reduced without overengineering.

## Rollback

- Revert the hook changes and documentation if the new thresholds create too many false positives.
