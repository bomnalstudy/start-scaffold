# Latency And Load Rules

Use these rules when optimizing for steady UX under load.

## Interaction And Main Thread

- Treat interaction lag as a first-class bug even when the UI "looks" complete.
- Break up long CPU-heavy work instead of monopolizing the main thread.
- Use deferred or transitional UI updates for non-urgent renders when the surface supports it.
- Virtualize large lists and avoid rendering hidden or offscreen-heavy sections eagerly.

## Traffic, Concurrency, And Burst Control

- Traffic distribution is one optimization tool, not the whole optimization strategy.
- Put concurrency limits around external work so burst traffic does not turn into retry storms or queue collapse.
- Use queueing when work can be delayed safely, and keep queue ownership explicit.
- Use throttling or debouncing only where it reduces waste without hiding user intent.
- If work is CPU-heavy, do not assume async concurrency alone will help; isolate the work or move it off the hot path.

## Graceful Degradation

- Keep core read and write actions available even when non-critical enhancements are reduced.
- Prefer stale-but-usable data over blank waiting states when correctness allows it.
- Reduce polling, background refresh, and non-critical prefetch before degrading the primary task path.
- When load rises, slow optional work first and preserve the user’s main path.
