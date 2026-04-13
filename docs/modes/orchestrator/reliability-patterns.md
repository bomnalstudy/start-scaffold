# Reliability Patterns

Use these patterns when an orchestrator run must be resumable, replayable, and safe under retries.

## Why

- durable orchestration needs more than a happy-path state contract
- retries and partial failures can duplicate side effects if boundaries are unclear
- human review or manual approval requires safe pause and resume points

## 1. Checkpoint Boundaries

- Persist state at explicit step boundaries, not only at the end of a full run.
- A checkpoint should exist before and after any expensive or externally visible action.
- A checkpoint should be enough to resume execution without recomputing hidden local state.

Recommended checkpoint moments:

- after intake normalization
- after planning
- before host invocation
- after host invocation
- before patch commit
- after patch commit

## 2. Replay Rule

- Replays must start from a known checkpoint, not from arbitrary partial in-memory state.
- Replay should skip already-persisted successful work whenever possible.
- Replay must keep the same run correlation ids or clearly link the replay to the original run.

## 3. Interrupt Rule

- Add explicit interrupt points for approval, review, or external wait states.
- Interrupts should happen at checkpoint boundaries so resume is deterministic.
- Do not hide human-in-the-loop pauses inside ad hoc local files or comments.

## 4. Retry Taxonomy

Split retries by failure type:

- transient infrastructure failure
- host timeout or temporary unavailability
- stale snapshot or contract conflict
- validation failure
- side-effect ambiguity

Rules:

- retry transient failures with bounded backoff
- do not blindly retry contract conflicts; reread state first
- do not blindly retry ambiguous side effects; confirm idempotency first
- make retry policy explicit in the orchestrator or adapter, not implicit in scattered callers

## 5. Idempotency and Cache Keys

- Every external side effect should have an idempotency key or an equivalent stable correlation key.
- Cached or reused results must be tied to stable inputs, code version, and run or task scope.
- Result reuse is only safe when persistence exists and the cache key meaning is explicit.

Suggested cache key ingredients:

- normalized inputs
- code or contract version
- orchestrator role
- run or thread scope

## 6. Child Flow Rule

- Use child orchestrators or child flows when a sub-run has its own lifecycle, retries, or handoff history.
- Do not split into child flows only for organization if no independent lifecycle exists.

## Avoid

- one giant run with no intermediate checkpoints
- retries that can duplicate side effects
- replay paths that depend on hidden local variables
- manual approval steps with no persisted resume point
