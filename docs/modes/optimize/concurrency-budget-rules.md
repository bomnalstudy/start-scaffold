# Concurrency Budget Rules

Use these rules when parallel work, worker pools, queues, or external API pressure affect latency.

## Budget First

- Name the concurrency budget before increasing parallelism.
- Keep separate limits for user-blocking work, background work, and external provider calls.
- Do not let retries multiply effective concurrency without noticing.

## Queue And Worker Use

- Use a simple limiter for narrow async fan-out problems.
- Use a durable queue only when work must survive process boundaries, bursts, or worker restarts.
- If CPU-heavy work is causing lag, move it off the hot path instead of only raising async concurrency.

## Backpressure

- When the system is crowded, slow optional work first.
- Preserve core read and write paths before analytics, prefetch, background refresh, or cosmetic work.
- Prefer predictable bounded throughput over uncontrolled spikes.
