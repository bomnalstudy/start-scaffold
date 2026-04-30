# Code Flow Map Log

## What Changed

- Added a local static code flow analyzer.
- Added PowerShell and Bash entrypoints.
- Wired automatic refresh into task start and successful orchestration runs.
- Added a static browser board at `docs/code-flow-board.html`.
- Added generated viewer data at `docs/generated/code-flow-data.js`.
- Added basic flowchart shape semantics to the board.
- Added English/Korean language selection to the board UI.
- Changed the default board language to Korean.
- Changed the graph canvas to a top-to-bottom flowchart layout.
- Added component and sample-file summaries in the Details panel.
- Added orchestrator documentation for generated code flow maps.
- Registered the flow map doc in `orchestrator-mode`.

## Why

The scaffold should help non-developers understand cloned projects by turning the current code structure into a visible flow chart before broad code changes begin.

The map should also stay fresh during repeated vibe-coding sessions, so normal task and orchestration entrypoints now refresh it automatically.

## Verification

- Ran `.\scripts\analyze-code-flow.ps1`.
- Confirmed it scanned 296 files and generated `docs/generated/code-flow.mmd` plus `docs/generated/code-flow.json`.
- Ran `.\scripts\run-code-rules-checks.ps1`; it passed with 0 errors and 0 warnings.
- Ran `.\scripts\run-orchestration.ps1 -Pipeline code-rules`; it passed and refreshed the code flow map automatically.
- Confirmed the analyzer now emits Mermaid, JSON, and browser viewer data.
- Ran `node --check docs\code-flow-board\board.js`; syntax check passed.
- Ran `.\scripts\run-code-rules-checks.ps1`; it passed with 0 errors and 0 warnings after language selection was added.
- Ran `node --check` for `board.js`, `i18n.js`, and `summaries.js`; all passed.
- Ran `.\scripts\run-orchestration.ps1 -Pipeline code-rules`; checks passed and regenerated flow artifacts.

## Remaining Risk

- Static scans can miss dynamic framework behavior, generated files, runtime routing, and implicit dependencies.
- The first Mermaid view is intentionally structural; it does not yet show live orchestration status.
