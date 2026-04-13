# Reference Patterns And Tooling

Use these references when choosing optimization patterns or optional libraries.

## Frontend Responsiveness

- React `startTransition` and `useDeferredValue` fit non-urgent UI updates that should not block urgent interaction feedback.
- `AbortController` fits cancelable fetch and stale-request cleanup.

## Data Fetching And Cache Behavior

- TanStack Query fits shared request caching, dedupe, controlled freshness, retries, and request-waterfall review.
- Prefer it when the product has repeated query keys, route-level prefetching, background refetch needs, or mutation invalidation complexity.

## Concurrency And Burst Control

- `p-limit` fits local async concurrency limiting in Node or browser code without introducing a full queue system.
- BullMQ fits durable queues, worker fleets, concurrency tuning, and rate limiting when work should survive process boundaries.

## Selection Rule

- Use no new dependency when a small local helper is enough.
- Use a focused utility when the problem is narrow and repeated.
- Use a queue or cache framework only when the team actually needs shared durability, observability, or multi-worker control.
