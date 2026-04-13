# Session Log

## Date

2026-04-13

## Original Goal

- Add repository-wide file design rules and extend code checks so mixed-responsibility and file-growth signals are surfaced earlier.

## MVP Scope (This Session)

- Add a shared file design rules document.
- Add a global rule to `AGENTS.md`.
- Extend code-rules checks with a few high-signal mixed-responsibility warnings.

## Key Changes

- Added `docs/modes/shared/file-design-rules.md`.
- Added a global file design rule section to `AGENTS.md`.
- Extended `scripts/run-code-rules-checks.ps1` with mixed-responsibility heuristics for React files, PowerShell scripts, and orchestrator-related files.

## Validation

- Ran session guard checks for the task plan and worklog.
- Ran code-rules verification after the new heuristics were added.
- Observed one warning: `scripts/import-project-secrets.ps1` matched `script-flow-mix`, which looks like a valid future split candidate rather than a blocker.

## Mistakes / Drift Signals Observed

- The main risk is warning fatigue if heuristics are too broad.
- The first run already surfaced one real script-mixing signal, so future tuning should stay narrow and practical.

## Prevention for Next Session

- Only promote warnings to blocking rules after repeated real failures.
- Tune heuristics from real false positives instead of guessing.

## Direction Check

- Why this still matches the original goal:
- The repository now treats file design as a global rule and catches a few common split signals before files become a git problem.
- We can stop after validation because deeper analysis or auto-refactoring is outside this MVP.

## Next Tasks

1. Refine warning thresholds after a few real uses.
2. Consider adding a report for top mixed-responsibility candidates in the repo.
3. Optionally extend heuristics by language only when repeated cases justify it.
