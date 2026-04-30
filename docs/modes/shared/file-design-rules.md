# File Design Rules

This document defines repository-wide rules for keeping files commit-friendly, review-friendly, and easy to split before they become a git burden.

## Goal

- Keep files small enough to review and change safely.
- Detect mixed responsibilities before they turn into oversized files.
- Force splitting decisions earlier than the commit/push crisis point.

## Core Rules

- Treat file design as a global repository rule, not a mode-specific preference.
- Prefer one primary responsibility per file.
- Split before the file becomes hard to review, not after it already blocks work.
- Do not keep growing a file just because it still technically works.

## Size Thresholds

- Under 300 lines: normal target range.
- Over 300 lines: watch closely for mixed responsibilities or rapid growth; this is not a split requirement by itself.
- Over 500 lines: treat as the actual split threshold unless the file is clearly generated or otherwise exempt.

## Mixed Responsibility Signals

Split or redesign when one file starts combining multiple concerns such as:

- UI rendering plus data fetching
- UI rendering plus heavy state orchestration
- API access plus data transformation plus presentation shaping
- script entrypoint plus validation plus business rules plus reporting
- orchestrator dispatch plus stage logic plus logging plus config parsing

## Practical Split Directions

- UI file: keep rendering and surface-level interaction only
- hook/state file: keep state transitions and derived view state
- API file: keep remote access and request/response boundaries
- transform/util file: keep pure mapping and formatting logic
- type file: keep shared contracts and schema-facing types
- script entry file: keep argument parsing and high-level flow only

## Commit-Friendly Rule

Before adding more code to a file, ask:

1. Is this still one responsibility?
2. Will this diff stay reviewable?
3. If I add another 30-50 lines here, should the split happen first?

If the answer trends toward "no", split first.

## Enforcement

- `AGENTS.md` sets the repository-level rule.
- `scripts/run-code-rules-checks.ps1` warns on file growth and common mixed-responsibility signals.
- `scripts/hook-pre-commit.ps1` and `scripts/hook-pre-push.ps1` enforce the most important blocking checks.
