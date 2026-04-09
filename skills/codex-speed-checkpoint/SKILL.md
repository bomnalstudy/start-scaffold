---
name: codex-speed-checkpoint
description: Run Codex checkpoint gate for speed-first workflow. Use at major checkpoints to validate scope, code rules, and worklog alignment.
---

# Codex Speed Checkpoint

Run:

```powershell
.\scripts\skill-codex.ps1 -Stage checkpoint -PlanPath <plan path> -WorklogPath <worklog path>
```

Rule:

- Use at major checkpoints, not every turn.
