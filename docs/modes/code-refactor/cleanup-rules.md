# Cleanup Rules

Use these rules when `code-refactor-mode` is cleaning dead weight, stale aliases, empty folders, or low-value leftovers.

## Goal

- Remove obvious repository clutter before it keeps creating false choices and duplicated maintenance.
- Prefer safe cleanup with evidence over broad speculative deletion.

## Cleanup Confidence Levels

### High Confidence

These can be cleaned automatically when the user asks for cleanup:

- deprecated compatibility alias files with a clear replacement
- empty folders left after a migration
- wrapper files that only exist to preserve an old naming family after the new family is in place

### Medium Confidence

These should be proposed first, not auto-removed blindly:

- duplicate-content helpers or scripts
- likely unreferenced test or demo scripts
- old examples that may still serve as documentation

## Removal Style

- For files, follow the repository rule: archive to `.graveyard/` instead of hard deleting.
- For empty folders, direct removal is acceptable.
- Keep a note for every archived file explaining why it was retired.

## Stop Rule

- Stop automatic cleanup when a candidate still has active references, unclear ownership, or possible documentation value.
