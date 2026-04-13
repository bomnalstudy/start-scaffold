---
name: file-refactor
description: Refactor existing files in this repository to match the global file design rules. Use when a file is too large, mixes multiple responsibilities, repeatedly triggers code-rules warnings, or needs to be split into review-friendly units before more work is added.
---

# File Refactor

Use this skill when the problem is not just "change code" but "reshape the file so future changes stay manageable."

## Read First

1. `AGENTS.md`
2. `docs/modes/shared/file-design-rules.md`
3. `docs/modes/secure/file-growth-guard.md`
4. the current task plan and worklog

If the file already triggered a repository warning, read the relevant warning output before editing.

## Trigger Signals

Use this skill when one or more of these are true:

- the file is over 300 lines and still growing
- the file is over 500 lines
- the file mixes UI, state, API, transformation, or orchestration responsibilities
- the file keeps getting touched across multiple sessions
- code-rules checks flag responsibility-mix or file-growth warnings

## Workflow

1. Identify the file's current responsibilities.
2. Decide the primary responsibility that should remain in the original file.
3. Move reusable or secondary concerns into colocated files first.
4. Keep behavior stable while reducing responsibility mixing.
5. Re-run focused checks after the split.

## Preferred Split Directions

- UI rendering -> component or screen file
- state orchestration -> hook or state helper
- API access -> api or service file
- pure transforms -> util or mapper file
- shared types -> types file
- script helpers -> helper file separate from entry flow
- orchestrator reporting/config helpers -> separate from dispatch flow

## Output Shape

When using this skill, report:

- target file
- mixed responsibilities found
- chosen split boundary
- files created or changed
- verification result

## Avoid

- broad opportunistic refactors outside the target file set
- changing behavior unless the task explicitly asks for behavioral cleanup too
- introducing abstractions that are larger than the current MVP needs

## Stop Rule

- Stop when the target file is more reviewable, responsibility mixing is reduced, and the related warnings or growth concerns are resolved enough for the current task.
