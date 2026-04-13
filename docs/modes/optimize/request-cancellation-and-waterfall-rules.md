# Request Cancellation And Waterfall Rules

Use these rules when request timing, duplicate fetches, or sequential API chains are hurting perceived speed.

## Cancellation

- Cancel stale or superseded requests when user intent has clearly moved on.
- Do not let an older response overwrite newer intent after search input, tab changes, route changes, or repeated saves.
- Prefer an explicit cancellation boundary in request helpers instead of scattered ad hoc guards.

## Waterfall Control

- Treat unnecessary sequential fetch chains as a performance smell.
- Identify which requests are truly dependent and which can be parallelized or prefetched.
- Avoid route-level loading flows that block on one request before starting the next when the data is independent.
- When a request can be prefetched safely, do it before the user reaches the blocking point.

## Response Ordering

- Make stale-response handling explicit.
- Use request keys, run IDs, or abort signals so the UI can reject old results safely.
- Never assume the last request sent is the last response received.
