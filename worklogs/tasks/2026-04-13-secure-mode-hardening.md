# Orchestration Plan

## Project / Task

- Strengthen secure-mode with secure-by-default docs and a few high-signal code checks.

## User Problem

- Secure-mode exists, but the most practical prevention rules for sensitive logging, unsafe browser token storage, and HTML injection sinks are not yet explicit.

## Original Goal

- Make secure-mode more operational by adding concrete secure-by-default guidance and lightweight enforcement.

## User Value

- Catches a few expensive security mistakes earlier.
- Gives later secure reviews a shared baseline instead of ad hoc judgment.

## Priority

- Primary KPI (must): Quality that reduces rework
- Secondary KPI (optional): Time saved

## MVP Scope

- Add secure-by-default and sensitive-logging docs.
- Update secure-mode references to read them first.
- Extend code-rules with a few high-signal security warnings.

## Non-Goal

- Build a full security scanner.
- Add broad secret-detection heuristics beyond the existing hook protections.
- Cover every OWASP category.

## Generic Requirement

- Keep checks narrow and practical.
- Prefer high-signal warnings over noisy guess-heavy scanning.

## Stop If

- The checks start flagging normal code too broadly.
- The docs drift into generic security handbook territory.

## Pattern

- Secure By Default Foundation

## Roles

### Planner

- Input: secure-mode docs and current code-rules coverage
- Output: narrow security hardening scope

### Builder

- Input: secure docs and code-rules script
- Output: new docs plus focused checks

### Reviewer

- Input: new rules and findings
- Output: signal-to-noise review

### Verifier

- Input: code-rules run and session guard
- Output: validation result

### Recorder

- Input: security hardening choices
- Output: worklog

## Scope

- Included: `docs/modes/secure/`, `skills/secure-mode/`, `docs/modes/shared/agent-modes.md`, `scripts/run-code-rules-checks.ps1`, `worklogs/`
- Excluded: runtime auth rewrites, full static analysis engine

## Risks

- Even focused security checks can become noisy if patterns are too broad.
- Existing secure docs with broken encoding still exist, so the new docs must become the primary entry point.

## Done When

- Secure-mode points at new secure-by-default docs.
- Code-rules includes the new focused security warnings.

## Verification

- Run code-rules checks.
- Run session guard checks on the task and worklog.

## Why Stop Now

- This gives secure-mode practical enforcement without overbuilding a scanner.

## Rollback

- Remove or narrow the new warnings if they prove noisy.
