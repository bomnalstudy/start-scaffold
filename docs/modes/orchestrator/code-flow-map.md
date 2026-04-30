# Code Flow Map

Use this when a project has been cloned or imported and the user needs to see how the current code is organized before changing it.

## Purpose

- analyze the current repository with a lightweight static scan
- group files into role-oriented areas such as UI, backend, database, security, orchestration, automation, docs, and verification
- generate a Mermaid flow chart that helps non-developers see the project shape
- keep the first pass cheap and repeatable before asking an AI model to infer deeper behavior

## Command

PowerShell:

```powershell
.\scripts\analyze-code-flow.ps1
```

Bash:

```bash
./scripts/bash/analyze-code-flow.sh
```

Default outputs:

- `docs/generated/code-flow.mmd`
- `docs/generated/code-flow.json`
- `docs/generated/code-flow-data.js`

Viewer:

- `docs/code-flow-board.html`

Automatic refresh points:

- `scripts/powershell/bootstrap/start-task.ps1` refreshes the map when a new task starts.
- `scripts/run-orchestration.ps1` refreshes the map after a successful pipeline unless `-SkipCodeFlowMap` is passed.
- `scripts/bash/run-orchestration.sh` refreshes the map after a successful pipeline unless `--skip-code-flow-map` is passed.

## Output Contract

The JSON output contains:

- `roles`: count of files grouped by inferred role
- `components`: top-level or two-level project areas with primary role and sample files
- `dependencies`: local component references detected by static import patterns
- `externalDependencies`: package/module references detected by static import patterns
- `files`: scanned files with inferred role and component

The Mermaid output is a compact flow chart:

```text
Current project -> role -> component -> dependency edge
```

The HTML board reads `docs/generated/code-flow-data.js` so it can be opened directly in a browser without a dev server.

## Orchestrator Rule

When starting work in an unfamiliar cloned project, prefer running the code flow map before broad manual exploration.

During normal vibe-coding sessions, keep the map current by using the normal task start and orchestration commands instead of manually editing generated files.

Use the generated chart as a navigation aid, not as proof of runtime behavior. The static scan can miss dynamic imports, reflection, framework routing, generated code, runtime configuration, and implicit conventions.

## MVP Boundary

This feature intentionally starts as a local static analyzer.

Do not add a full AI interpretation layer or dependency graph database until the generated Mermaid/JSON output and static board prove useful in real cloned projects.
