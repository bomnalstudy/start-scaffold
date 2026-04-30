# Live Flow Board Log

## What Changed

- Added a React + ELKJS code flow board under `apps/code-flow-board`.
- Added a Vite dev server plugin that watches project file changes.
- The dev server reruns `scripts/shared/analyze_code_flow.py` after changes and pushes update events to the browser.
- Added npm scripts: `flow:dev`, `flow:build`, and `flow:preview`.
- Kept the existing static board as a lightweight fallback.

## Why

Users need to keep the flowchart open while vibe-coding. A static HTML file requires manual regeneration and refresh, so a live board mode is needed for continuous feedback.

## Verification

- Ran `npm install`.
- Adjusted Vite dependencies to versions compatible with Node 20.18.0.
- Ran `npm run flow:build`; build passed.
- Started `npm run flow:dev`; `http://127.0.0.1:5179` returned HTTP 200.
- Ran `.\scripts\run-code-rules-checks.ps1`; it passed with 0 errors and 0 warnings.
- Fixed React board styling by using the global CSS entry instead of CSS Modules for app-level class names.
- Reworked the live board into a draw.io-like editor shell with a top menu, toolbar, left role dock, grid canvas page, and right details dock.
- Reworked the board again into a modern node-map canvas inspired by the provided reference: left role rail, floating top bar, dotted canvas, card-like nodes, floating zoom controls, and right details dock.
- Added role-colored edges, card-like orchestrator nodes, small node metrics, and a right-side insight card pattern without copying the reference UI directly.
- Restored flowchart-semantic node outlines while keeping the card-like internal labels and metrics.
- Added canvas controls: Alt + wheel zoom, Space + drag pan, zoom buttons, and reset.
- Added `CODE_FLOW_ROOT` and `CODE_FLOW_PORT` support so the board can run from this scaffold while observing another project.
- Added `scripts/start-code-flow-board.ps1` as the Windows launcher for target-project viewing.
- Excluded helper/output folders from analysis: `start-scaffold`, `.tmp`, `backups`, and `graphify-out`.
- Made app component grouping more granular under `apps/<app>/src/<area>` so same-app relationships can appear in the board.
- Removed the default center `project` node from the live board layout.
- Changed the live board to show `role -> code area` structure first, then real dependency edges between visible code areas.
- Changed component ranking so connected app code appears before huge docs/reference folders.
- Added component description fields to the flow JSON so nodes can explain what each area does.
- Added `scripts/enrich-code-flow-descriptions.ps1` and `scripts/shared/enrich_code_flow_descriptions.py` for required local-AI node explanations.
- Added `CODE_FLOW_AI_COMMAND` support to the live Vite server so local AI CLIs generate descriptions during refresh.
- Removed heuristic description fallback; node explanations now require a local AI command.
- Changed Markdown classification so every `.md` file is treated as documentation before orchestration/security/etc. path keywords.
- Added explicit `Start` and `End` nodes to the live board so the graph reads as a top-to-bottom flow, not only a reference network.
- Replaced the vague `core` role with clearer categories: `domain`, `service`, `repository`, and `entrypoint`.
- Renamed UI labels so `automation` appears as run scripts and `verification` appears as tests/checks.
- Changed the live board to render role-level nodes instead of file/component-level nodes.
- Role nodes now carry related file samples so users can see which files belong to that role without duplicate node summaries.
- Added `skill` as a separate role for `SKILL.md` and files under `skills/`.
- Added direct node dragging on the SVG board, with edge paths recalculated from the moved node positions.
- Excluded supporting roles (`docs`, `skill`) from the live graph canvas and role filter because they guide implementation rather than execute runtime flow.
- Standardized the live board server back to port `5179` and stopped the extra `5180` dev server during verification.
- Replaced the role reference graph with a flowchart-style runtime sequence: start, load config, receive input, handle request, branch decisions, process, persist, output, verify, end.
- Added edge labels for decision branches such as yes/no, step execution, repeated work, pass, and needs-fix.
- Excluded `references` from default analysis to keep external/reference material out of the current project map.
- Added `scripts/shared/infer_code_flows.py` and `scripts/infer-code-flows.ps1` so a local AI CLI can infer real workflow nodes and decision edges from selected code evidence.
- Changed the live board refresh pipeline from component-description enrichment to mandatory AI flow inference.
- Changed the React layout to render `flows` from `code-flow.json` first, instead of a hard-coded role sequence.
- Added node evidence display in the details dock so users can see why the AI created a given flowchart step.
- Added a repository-wide rule for large analysis/AI/export work: process in sequential batches and preserve intermediate results instead of doing one all-at-once export.
- Changed AI flow inference to process selected components in sequential batches and save `docs/generated/code-flow-work/batch-*.json`.
- Changed final AI flow assembly to merge one batch at a time, saving `merge-*.json` and updating the partial `code-flow.json` after each merge step.
- Changed AI flow inference defaults so `MaxComponents=0` means no artificial code-area cap.
- Changed AI flow inference to split each code area into small file units, so all non-supporting files can be covered sequentially without sending a huge folder prompt to one AI call.
- Changed AI flow inference to merge immediately after each batch and write a partial `code-flow.json`, so the board can show progress before the entire project finishes.
- Added `code-flow-memory.json` as a persistent flowchart summary file that is reused as the seed for future AI updates.
- Changed the board API to serve saved flow memory immediately when the current scan has no `flows`, instead of blocking the UI while AI inference runs.
- Tightened AI prompts so all user-facing flow names, summaries, labels, evidence, and edge explanations stay in natural Korean when `Language=ko`.
- Reaffirmed Markdown files as supporting work context only; `.md` files should be lower priority than executable/source files and should not decide the main result flow.
- Changed AI flow candidate ordering so result-impacting product code is analyzed first: `apps/**/src`, product roles, then config/automation/checks, with docs/worklogs/Markdown last or excluded from runtime flow inference.
- Excluded one-off script paths from runtime flow inference when their names indicate cleanup, migration, seed, backfill, rerun, temporary, or similar single-use maintenance work.

## Remaining Risk

- ELKJS makes the production bundle large; code splitting can be added later if load time becomes a problem.
- The code-flow analyzer is still static and can miss dynamic framework behavior.
- Alias imports and runtime-only links may still require a richer resolver to show every workflow edge.
- AI-generated flowcharts depend on the user's local CLI auth, budget, command format, and the quality of selected file excerpts.
- Each merge step still depends on local AI output quality; batch and merge files make failed or weak runs easier to inspect and retry.
