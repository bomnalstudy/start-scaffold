# Agent Skills (Codex + Claude)

Use these wrappers to run gates and print a compact prompt block in one command.

## Why

- less command typing during chat
- same workflow for Codex and Claude
- speed-first MVP flow with explicit stop rules

## Codex Skill

Start:

```powershell
.\scripts\skill-codex.ps1 -Stage start -TaskName "my task" -Pack start
```

Checkpoint:

```powershell
.\scripts\skill-codex.ps1 -Stage checkpoint -PlanPath .\worklogs\tasks\2026-04-09-my-task.md -WorklogPath .\worklogs\2026-04-09-my-task-log.md
```

Close:

```powershell
.\scripts\skill-codex.ps1 -Stage close -PlanPath .\worklogs\tasks\2026-04-09-my-task.md -WorklogPath .\worklogs\2026-04-09-my-task-log.md
```

## Claude Skill

Start:

```powershell
.\scripts\skill-claude.ps1 -Stage start -TaskName "my task" -Pack start
```

Checkpoint:

```powershell
.\scripts\skill-claude.ps1 -Stage checkpoint -PlanPath .\worklogs\tasks\2026-04-09-my-task.md -WorklogPath .\worklogs\2026-04-09-my-task-log.md
```

Close:

```powershell
.\scripts\skill-claude.ps1 -Stage close -PlanPath .\worklogs\tasks\2026-04-09-my-task.md -WorklogPath .\worklogs\2026-04-09-my-task-log.md
```

## Prompt-Only Mode

If you only want a reusable prompt block without running checks:

```powershell
.\scripts\skill-codex.ps1 -Stage checkpoint -PlanPath <plan> -WorklogPath <log> -PrintPromptOnly
```

## MVP Rule

- Always run `start`
- Run `checkpoint` only at major checkpoints (speed-first mode)
- Always run `close` before ending session

## Mode Rule

- Use short domain names with the `*-mode` format when narrowing a chat session.
- Current standard modes are `ux-ui-mode`, `secure-mode`, `performance-mode`, `orchestrator-mode`, and `failure-pattern-mode`.
- Treat `ux/ui-mode` as a chat alias for `ux-ui-mode`.
- When a mode is called, load only the docs and rules needed for that mode first.
- Read [docs/modes/shared/agent-modes.md](/c:/Users/ghpjh/Desktop/project/start-scaffold/docs/modes/shared/agent-modes.md) for the mode-specific document and output expectations.
- Use the repo-local skill entry points under `skills/` when you want the mode to be an explicit reusable skill rather than only a documentation rule.

## Repo-Local Utility Skills

- `file-refactor`: use when an existing file is too large, mixes responsibilities, or needs to be split to match the global file design rules.

## UI UX Rule

- For frontend UI/UX work, agents must also follow `docs/modes/ux-ui/ui-ux-product-rules.md`.
- Use `web-ui-quality-guard` for browser-first UI.
- Use `app-ui-quality-guard` for app-first UI.
- Use `frontend-quality-guard` only to route when the surface is still unclear.
- Record the surface as `web`, `app`, `shared`, or `non-UI` in the task plan before implementation.
- Record the chosen quality guard in the same task plan so later sessions can recover the UI context quickly.
