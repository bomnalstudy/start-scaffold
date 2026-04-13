# Orchestration Plan

## Project / Task

- Harden secure-mode specifically against user data leakage in logs, auth errors, and session handling.

## User Problem

- Security hardening should more explicitly prevent leaks of user-identifying or account-state data.

## Original Goal

- Strengthen secure-mode so it can better spot and prevent user data leakage.

## User Value

- Reduces privacy and account-enumeration risk.
- Gives future secure reviews concrete user-data handling rules.

## Priority

- Primary KPI (must): Quality that reduces rework
- Secondary KPI (optional): Time saved

## MVP Scope

- Add user-data leakage rules.
- Add auth/session review rules.
- Add focused code-rules warnings for PII logging and auth enumeration strings.

## Non-Goal

- Build a full privacy compliance framework.
- Add identity-specific code when no application auth flow exists yet.

## Generic Requirement

- Keep the rules reusable across projects.
- Keep the warnings narrow and high-signal.

## Stop If

- The checks start flagging normal documentation or generic guidance too broadly.
- The rules drift into jurisdiction-specific compliance advice.

## Pattern

- Privacy-Focused Secure Hardening

## Roles

### Planner

- Input: secure-mode baseline plus privacy and auth references
- Output: narrow leak-prevention scope

### Builder

- Input: scope
- Output: docs and checks

### Reviewer

- Input: warnings and docs
- Output: signal review

### Verifier

- Input: code-rules and session guard
- Output: validation

### Recorder

- Input: leak-prevention rationale
- Output: worklog

## Scope

- Included: `docs/modes/secure/`, `skills/secure-mode/`, `docs/modes/shared/agent-modes.md`, `scripts/run-code-rules-checks.ps1`, `worklogs/`
- Excluded: full privacy platform work, legal compliance mapping

## Risks

- PII heuristics can become noisy if they are too broad.
- Auth message checks can accidentally flag documentation samples if they are not scoped carefully.

## Done When

- Secure-mode has explicit user-data leakage and auth/session review rules.
- Code-rules includes focused warnings for likely PII logging and auth enumeration text.

## Verification

- Run code-rules checks.
- Run session guard checks on the task and worklog.

## Why Stop Now

- This closes a high-value privacy gap without pretending the scaffold is a full compliance system.

## Rollback

- Remove or narrow the new checks if they prove noisy.
