---
name: codex-speed-gate
description: Run speed-first gate workflow for Codex sessions in this repository. Use when starting a task, running a checkpoint, or closing a session with explicit stop rationale. Trigger for requests like "start gate", "checkpoint gate", "close gate", "codex skill start", or when user asks to keep MVP scope and avoid drift while coding.
---

# Codex Speed Gate

Use this skill to enforce the repository workflow with minimal command typing.

## Commands

Start:

```powershell
.\scripts\skill-codex.ps1 -Stage start -TaskName "<task name>" -Pack start
```

Checkpoint:

```powershell
.\scripts\skill-codex.ps1 -Stage checkpoint -PlanPath <plan path> -WorklogPath <worklog path>
```

Close:

```powershell
.\scripts\skill-codex.ps1 -Stage close -PlanPath <plan path> -WorklogPath <worklog path>
```

Prompt-only block:

```powershell
.\scripts\skill-codex.ps1 -Stage checkpoint -PlanPath <plan path> -WorklogPath <worklog path> -PrintPromptOnly
```

## Operating Rule

- Always run `start` before coding.
- Run `checkpoint` at major checkpoints only.
- Always run `close` before ending session.
- If a gate fails, pause implementation and fix plan/worklog first.
