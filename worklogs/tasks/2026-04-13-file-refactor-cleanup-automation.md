# 2026-04-13 File Refactor Cleanup Automation

## Original Goal

- Make `file-refactor` capable of finding duplicated or useless repository leftovers and cleaning high-confidence dead weight safely.

## MVP Scope

- Add cleanup rules for `file-refactor`.
- Add a candidate scan script.
- Support automatic cleanup for high-confidence cases using `.graveyard/` for files and direct removal for empty folders.

## Non-Goal

- Build a perfect dead-code detector.
- Auto-delete ambiguous files with no human review.

## Done When

- `file-refactor` points to cleanup rules and candidate scanning.
- A script can detect high-confidence and medium-confidence cleanup candidates.
- High-confidence file cleanup uses `.graveyard/` instead of hard deletion.

## Generic Requirement

- Keep the cleanup automation conservative enough to avoid damaging valid project files.

## Stop If

- The detection logic starts creating broad false positives.
- The cleanup path would bypass `.graveyard/` for removable files.
