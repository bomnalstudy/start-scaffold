---
name: optimize-mode
description: Narrow the session to optimization work in this repository. Use when the user asks to reduce lag, keep UX smooth under load, improve API/data efficiency, design concurrency or traffic controls, or refactor for steady responsiveness.
---

# Optimize Mode

Read first:

1. `docs/modes/shared/agent-modes.md`
2. `docs/modes/optimize/optimize-guide.md`
3. `docs/modes/optimize/latency-and-load-rules.md`
4. `docs/modes/optimize/api-and-data-optimization-rules.md`
5. `docs/modes/optimize/additive-optimization-rule.md`
6. `docs/modes/optimize/request-cancellation-and-waterfall-rules.md`
7. `docs/modes/optimize/interaction-and-render-rules.md`
8. `docs/modes/optimize/concurrency-budget-rules.md`
9. `docs/modes/optimize/measurement-rules.md`
10. `docs/modes/optimize/reference-patterns-and-tooling.md`
11. the current task plan and worklog
12. `docs/modes/orchestrator/orchestration-patterns.md` when pipeline flow affects runtime load
13. `docs/modes/harness/harness-guide.md` when validation behavior is part of the bottleneck

Focus on:

- user-perceived responsiveness
- load, save, and navigation latency
- bottleneck isolation
- queueing, caching, batching, throttling, and cancellation
- request waterfall reduction and stale-request rejection
- interaction smoothness, render discipline, and long-task reduction
- bounded concurrency and explicit backpressure
- measurement-backed tuning
- traffic distribution and concurrency controls inside a wider optimization topic
- graceful degradation and steady UX under load
- additive refactors via helper, wrapper, scheduler, or cache-layer imports before risky inline rewrites

Do not collapse this mode into traffic-only thinking or backend-only tuning.
