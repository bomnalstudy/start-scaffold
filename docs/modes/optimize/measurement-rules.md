# Measurement Rules

Optimization work must name what is being measured before changing architecture.

## Minimum Measurements

- user-visible interaction delay
- meaningful content visibility timing
- request count and request waterfall depth
- save latency and retry count
- queue depth or concurrency saturation when background work exists
- long-task presence on heavy UI paths

## Before And After Rule

- Record a simple baseline before optimization when possible.
- After the change, confirm whether the targeted bottleneck actually moved.
- If the metric did not improve, do not keep defending the optimization by theory alone.

## Review Rule

- Prefer one or two concrete measurements over a vague "feels faster" claim.
- If exact measurement is impossible in the scaffold, at least record the proxy you used and why it is the right proxy.
