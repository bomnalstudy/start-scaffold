# CODEX.md

This file is the Codex-specific adapter for this repository.

Codex must follow these documents in order:

1. `AGENTS.md`
2. `docs/token-ops-standard.md`
3. `docs/project-start-brief.md`
4. `docs/modes/ux-ui/ui-ux-product-rules.md` for frontend UI/UX tasks
5. task-specific docs as needed

Before loading docs, select one context pack:

```powershell
.\scripts\select-context-pack.ps1 -Agent codex -Pack implement
```

Codex skill wrapper (recommended):

```powershell
.\scripts\skill-codex.ps1 -Stage start -TaskName "my task" -Pack start
```

## Codex Execution Profile

- Start from a minimal MVP scope and close it fast.
- Keep context narrow: only open files relevant to the current task.
- Prefer short iteration loops: plan -> edit -> verify -> stop.
- Do not optimize beyond the current `Done When` unless explicitly asked.
- For frontend UI/UX tasks, always classify the target as web, app, or shared first, then follow the matching quality guard rules.

## Codex Output Rules

- Keep updates compact and decision-oriented.
- Report what changed, what was intentionally skipped, and why we should stop.
- If the task scope grows, pause and re-baseline `MVP Scope` and `Non-Goal`.

## Token Discipline

- Reuse stable prefixes and fixed templates to maximize cache hits.
- Avoid dumping full logs or full files when snippets are enough.
- Separate implementation, review, and architecture into different runs.
