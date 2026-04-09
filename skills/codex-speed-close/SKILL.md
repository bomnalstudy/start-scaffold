---
name: codex-speed-close
description: Run Codex close gate to end session safely with stop rationale and next tasks. Use before ending a task/session.
---

# Codex Speed Close

Run:

```powershell
.\scripts\skill-codex.ps1 -Stage close -PlanPath <plan path> -WorklogPath <worklog path>
```

Rule:

- Always run before ending session.
