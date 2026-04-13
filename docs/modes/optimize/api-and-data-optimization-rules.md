# API And Data Optimization Rules

Use these rules when the bottleneck is request, cache, storage, or save behavior.

## Request Shape

- Do not fire duplicate requests for the same key when a shared cache or request dedupe layer can serve them.
- Reduce request waterfalls before increasing server power.
- Batch or combine requests only when it lowers end-to-end latency instead of creating larger blocking payloads.
- Cancel stale or superseded requests so old responses do not waste bandwidth or overwrite fresher intent.

## Cache And Freshness

- Name cache freshness rules explicitly.
- Avoid default refetch behavior when it creates noisy reloads or unnecessary background churn.
- Pick stale-time and retry behavior intentionally for each data class.
- Separate "must be exact now" data from "can be briefly stale" data.

## Saves And Mutations

- Keep write flows fast, narrow, and explicit.
- Avoid refetching the world after a small mutation when a local targeted update is enough.
- Use backoff and bounded retries for unstable writes.
- Guard against duplicate submissions from repeated taps or unstable networks.

## Storage And Retrieval

- Keep hot-path reads small and predictable.
- Move heavy transformations away from the user-blocking path when possible.
- Paginate or stream large result sets instead of forcing giant blocking loads.
