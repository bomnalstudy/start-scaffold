# 2026-04-13 Optimize Mode Hardening

## Original Goal

- Rename `performance-mode` to `optimize-mode` and expand it into a broader optimization mode for latency, load, API/data efficiency, and steady UX under traffic.

## MVP Scope

- Rename the mode and skill references.
- Add mode-specific docs under `docs/modes/optimize/`.
- Ground the mode in external guidance for responsiveness, request efficiency, cancellation, caching, concurrency, and queue-based burst control.
- Add narrower rules for request cancellation, waterfall reduction, render discipline, concurrency budgeting, and measurement.

## Non-Goal

- Build a full performance framework or add new runtime dependencies.
- Tune a real product path before the app-specific bottleneck exists.

## Done When

- `optimize-mode` replaces `performance-mode` in active docs and skill metadata.
- Optimization docs cover responsiveness, API/data flow, load handling, and additive remediation.
- Repo checks pass.

## Generic Requirement

- Keep the mode scaffold broad enough to reuse across different app architectures.

## Stop If

- The rename requires unrelated history cleanup or host-specific slash UI reindexing work.
- The optimization guidance starts prescribing framework-specific architecture without a verified bottleneck.
