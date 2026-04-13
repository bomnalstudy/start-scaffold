# Orchestration Plan

## Project / Task

- Research common coding-time security failures and harden secure-mode so it can find and fix them safely.

## User Problem

- Security work is especially sensitive, and the scaffold needs stronger guidance for both detection and low-risk remediation.

## Original Goal

- Turn secure-mode into a better vulnerability-finding and safer remediation mode using source-backed patterns.

## User Value

- Catches more common security issues early.
- Reduces the chance of breaking working code during security fixes.

## Priority

- Primary KPI (must): Quality that reduces rework
- Secondary KPI (optional): Time saved

## MVP Scope

- Add a common vulnerability pattern catalog.
- Add an additive remediation rule that prefers new helper files plus imports.
- Add a few high-signal execution-risk checks to code-rules.

## Non-Goal

- Build a full SAST engine.
- Add framework-specific fixes for code that does not exist in this repo.
- Solve every security category with code checks alone.

## Generic Requirement

- Keep the advice reusable across projects.
- Keep code checks narrow and high-signal.

## Stop If

- The security catalog turns into a generic textbook.
- The new checks create more noise than value.

## Pattern

- Source-Backed Secure Mode Hardening

## Roles

### Planner

- Input: secure-mode rules plus external security references
- Output: practical pattern shortlist

### Builder

- Input: shortlist
- Output: docs and focused checks

### Reviewer

- Input: new rules and checks
- Output: signal-to-noise review

### Verifier

- Input: code-rules and session guard
- Output: validation

### Recorder

- Input: security hardening rationale
- Output: worklog

## Scope

- Included: `docs/modes/secure/`, `skills/secure-mode/`, `scripts/run-code-rules-checks.ps1`, `worklogs/`
- Excluded: dependency installs, external scanners, app-specific remediation

## Risks

- Security advice can sprawl if not kept practical.
- Execution-risk checks can become noisy if patterns are too broad.

## Done When

- Secure-mode has clearer vulnerability categories and safer remediation guidance.
- Code-rules catches a few additional high-risk execution patterns.

## Verification

- Run code-rules checks.
- Run session guard checks on the task and worklog.

## Why Stop Now

- This raises secure-mode quality without pretending the scaffold is a full security product.

## Rollback

- Remove or narrow the new checks if they prove noisy.
