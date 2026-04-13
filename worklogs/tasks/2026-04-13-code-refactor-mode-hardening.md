# 2026-04-13 Code Refactor Mode Hardening

## Original Goal

- Rename `file-refactor` into a review-driven `code-refactor-mode` and strengthen it with external refactoring and code-review guidance.

## MVP Scope

- Add `code-refactor-mode` docs and skill files.
- Add a compatibility wrapper for candidate scanning under a code-refactor name.
- Update shared mode and skill docs to point at `code-refactor-mode`.

## Non-Goal

- Build a full automatic dead-code detector.
- Replace repository-specific rules with generic external style doctrine.

## Done When

- `code-refactor-mode` exists as the main review/refactor skill.
- Shared docs refer to the new mode.
- Cleanup scanning is callable through a code-refactor-named script.

## Generic Requirement

- Keep the mode focused on maintainability and safe refactoring rather than broad redesign.

## Stop If

- The mode starts prescribing architecture instead of review-driven cleanup.
- The rename would break existing repository cleanup automation.
