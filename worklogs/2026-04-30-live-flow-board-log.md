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
- Excluded `references` from default analysis to keep external/reference material out of the current project map.

## Remaining Risk

- ELKJS makes the production bundle large; code splitting can be added later if load time becomes a problem.
- The code-flow analyzer is still static and can miss dynamic framework behavior.
- Alias imports and runtime-only links may still require a richer resolver to show every workflow edge.
- AI-generated descriptions depend on the user's local CLI auth, budget, and command format.
