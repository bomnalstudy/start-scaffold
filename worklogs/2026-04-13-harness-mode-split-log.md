# Session Log

## Date

2026-04-13

## Original Goal

- Separate harness-mode from orchestrator-mode and add practical harness rules to the scaffold.

## MVP Scope (This Session)

- Add a new harness-mode skill.
- Add harness-mode docs for guide, scenario naming, and stale snapshot rejection.
- Update shared mode references so orchestrator and harness are clearly separated.

## Key Changes

- Added `harness-mode` as a separate skill and mode definition.
- Added harness docs for verification guidance, scenario naming, and stale snapshot rejection.
- Reduced harness emphasis inside orchestrator references so the two concepts are easier to call separately.

## Validation

- Reviewed the updated mode references for separation and overlap.

## Mistakes / Drift Signals Observed

- Existing docs and routing still contain some legacy combined phrasing around orchestration and harness work.

## Prevention for Next Session

- Route runtime design into orchestrator-mode and validation design into harness-mode.
- Clean up remaining legacy combined wording when the touched files are already being edited.

## Direction Check

- Why this still matches the original goal:
- The scaffold now reflects the conceptual split the user asked for without forcing a large migration.
- We can stop at the mode/document layer because harness runtime work is a separate task.

## Next Tasks

1. Add a first concrete harness scenario file that matches the new naming rule.
2. Install `harness-mode` into the global skill directory if slash invocation is needed.
3. Narrow the orchestration context pack so harness docs load only when explicitly needed.
