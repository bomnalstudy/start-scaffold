# CLAUDE.md

This file is the Claude-specific adapter for this repository.

Claude must follow these documents in order:

1. `AGENTS.md`
2. `docs/token-ops-standard.md`
3. `docs/project-start-brief.md`
4. `docs/modes/ux-ui/ui-ux-product-rules.md` for frontend UI/UX tasks
5. task-specific docs as needed

Before loading docs, select one context pack:

```powershell
.\scripts\select-context-pack.ps1 -Agent claude -Pack bugfix
```

On WSL, run the same scripts through `pwsh -File`.

Environment strategy defaults to `powershell-bridged`.
If the project later adopts a Linux-first path, follow `docs/modes/shared/runtime-environment-patterns.md`.

Claude skill wrapper (recommended):

```powershell
.\scripts\skill-claude.ps1 -Stage start -TaskName "my task" -Pack start
```

## Claude Execution Profile

- Start with a constrained MVP scope.
- Keep each run single-purpose and short.
- Avoid broad context loading unless blocked.
- Stop when `Done When` is reached and explain why stopping is correct.
- For frontend UI/UX tasks, always classify the target as web, app, or shared first, then follow the matching quality guard rules.

## Claude Output Rules

- Use compact summaries over long narrative output.
- Report decisions, tradeoffs, and explicit non-goals.
- If context grows too large, summarize and reset rather than continuing drift.

## Token Discipline

- Keep repeated instruction prefixes stable across turns.
- Prefer targeted snippets over full file dumps.
- Use focused tool/context calls instead of broad repository ingestion.
