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

Before implementing a new direction, gather and review 3 to 5 strong UI references if the task allows it.

If the surface is unclear, also read the global `frontend-quality-guard` skill from your Codex skills home.

If the surface is browser-first, also read the global `web-ui-quality-guard` skill from your Codex skills home.

If the surface is app-first, also read the global `app-ui-quality-guard` skill from your Codex skills home.

## Must Do

- classify the surface as `web`, `app`, `shared`, or `non-UI`
- record the chosen quality guard
- state the primary UX concern before broad polishing
- summarize the typography, spacing, icon, and CTA patterns borrowed from references when references are used
- keep the main task obvious before adding decoration
- prefer layout, hierarchy, readability, contrast, spacing, responsive fit, and interaction clarity over feature sprawl
- keep icon use consistent and outline-based unless the product already uses a different system

## Avoid First

- security or optimization docs unless the UX/UI task clearly requires them
- unrelated architecture docs
- adding interface features when the main issue is clarity, structure, or interaction flow
- using emoji as UI icons
- choosing colors or fonts impulsively without a narrow system

## Output Shape

When doing implementation or review in this mode, prefer:

- reference summary
- surface classification
- chosen quality guard
- main UX issue
- minimal UX/UI change plan
- focused verification

## Stop Rule

- Stop when the UX/UI task is clear, the right guard is selected, and the requested change is complete enough for the current MVP.
