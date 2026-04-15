# Mode Docs Layout

This folder groups repository docs by the skill or mode that uses them most directly.

## Rule

- Docs that are primarily loaded by a mode skill should live under `docs/modes/<mode>/`.
- Docs shared by multiple mode skills should live under `docs/modes/shared/`.
- Keep non-mode repository docs at the top level of `docs/`.
- When a moved doc path changes, update every skill, template, script, and worklog reference in the same change.

## Current Structure

- `docs/modes/ux-ui/`: UX/UI mode docs
- `docs/modes/add/`: scaffold customization mode docs
- `docs/modes/secure/`: security mode docs
- `docs/modes/optimize/`: optimization mode docs
- `docs/modes/db/`: database and API contract mode docs
- `docs/modes/code-refactor/`: maintainability review and refactor mode docs
- `docs/modes/orchestrator/`: orchestrator runtime and pipeline docs
- `docs/modes/harness/`: harness scenario and verification docs
- `docs/modes/failure-pattern/`: repeated-failure and journaling docs
- `docs/modes/shared/`: docs reused across multiple modes
  - includes repository-wide docs such as file design rules
  - includes repository-wide environment strategy docs such as runtime environment patterns

## Why

- Keeps skill-related context easier to find.
- Makes later mode growth less confusing.
- Reduces drift between skill definitions and the docs they are supposed to load.
