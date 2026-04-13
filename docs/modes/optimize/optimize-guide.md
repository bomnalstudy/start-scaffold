# Optimize Guide

`optimize-mode` is the broad optimization mode for this scaffold.

Use it when the goal is not only to survive traffic spikes, but to keep the product feeling consistently fast and calm while users load data, save data, navigate, search, or trigger parallel work.

## Primary Goal

- Keep user-perceived responsiveness stable.
- Reduce avoidable waiting, wasted work, and request waterfalls.
- Keep behavior predictable under both normal and crowded usage.
- Improve performance without risky rewrites when an additive layer can solve the problem.

## Optimize First Areas

- input responsiveness and scroll smoothness
- route and screen transition latency
- data load and save latency
- API overfetch, duplicate fetch, and retry storms
- queue backlogs and burst control
- graceful degradation under load
- bottleneck isolation across UI, network, storage, and worker paths
- cancellation and waterfall control for request-heavy paths
- offscreen rendering discipline for large or complex surfaces

## Measure The Right Things

- `INP` mindset for interaction responsiveness
- `LCP` mindset for meaningful content visibility
- save latency and retry behavior for writes
- request count, concurrency, and waterfall depth for data flows
- long tasks and blocked main-thread work for UI-heavy paths

## Operating Rule

- Prefer the smallest optimization that removes real user discomfort.
- Prefer additive helpers, wrappers, schedulers, cache clients, and background workers before deep rewrites.
- Do not add concurrency, caching, or distribution blindly without naming the bottleneck first.
- Always name the measurement or proxy that justifies the optimization.
