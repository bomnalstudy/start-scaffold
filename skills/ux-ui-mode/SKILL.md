---
name: ux-ui-mode
description: Narrow the session to user-facing UX or UI work in this repository. Use when the user asks to finish UX/UI, polish a screen, improve usability, classify the surface as web/app/shared, apply the right quality guard, or continue prior frontend design work without loading unrelated docs first.
---

# UX UI Mode

Use this skill to keep frontend UX and UI work focused on the right rules and outputs.

## Read First

1. `docs/modes/ux-ui/ui-ux-product-rules.md`
2. `docs/modes/shared/agent-modes.md`
3. the current task plan and worklog for the UX/UI task

If the surface is unclear, also read:

- `C:\Users\ghpjh\.codex\skills\frontend-quality-guard\SKILL.md`

If the surface is browser-first, also read:

- `C:\Users\ghpjh\.codex\skills\web-ui-quality-guard\SKILL.md`

If the surface is app-first, also read:

- `C:\Users\ghpjh\.codex\skills\app-ui-quality-guard\SKILL.md`

## Must Do

- classify the surface as `web`, `app`, `shared`, or `non-UI`
- record the chosen quality guard
- state the primary UX concern before broad polishing
- keep the main task obvious before adding decoration
- prefer layout, hierarchy, readability, contrast, spacing, responsive fit, and interaction clarity over feature sprawl

## Avoid First

- security or performance docs unless the UX/UI task clearly requires them
- unrelated architecture docs
- adding interface features when the main issue is clarity, structure, or interaction flow

## Output Shape

When doing implementation or review in this mode, prefer:

- surface classification
- chosen quality guard
- main UX issue
- minimal UX/UI change plan
- focused verification

## Stop Rule

- Stop when the UX/UI task is clear, the right guard is selected, and the requested change is complete enough for the current MVP.
