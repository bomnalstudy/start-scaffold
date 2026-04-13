# Interaction And Render Rules

Use these rules when the app feels sticky, janky, or late to respond even when data is technically loading correctly.

## Interaction

- Prioritize visible feedback for taps, clicks, typing, and navigation before non-urgent recomputation.
- Keep urgent interaction updates separate from slower render or reconciliation work when the stack supports it.
- Treat blocked typing, delayed button feedback, and frozen scroll as optimization failures.

## Render Work

- Break up long tasks instead of stacking heavy synchronous work on the main thread.
- Virtualize large lists and avoid rendering oversized hidden trees eagerly.
- Defer non-critical panels, charts, and secondary visual detail until the primary interaction path is stable.
- Consider `content-visibility` or similar offscreen rendering controls only when the surface and accessibility behavior are understood.

## Loading States

- Avoid replacing a stable screen with a large blank loading state when incremental or stale content can remain visible.
- Prefer progressive reveal and targeted skeletons over whole-screen reset behavior.
