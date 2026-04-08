# Token Efficiency

This is the quick checklist version.

Authoritative policy:

- `docs/token-ops-standard.md`

Research basis:

- `docs/token-ops-research.md`

## Fast Checklist

- one objective per run
- stable header (`Original Goal`, `MVP Scope`, `Non-Goal`, `Done When`, `Stop If`)
- only relevant files/snippets, not full repo context
- implement -> verify -> stop
- defer non-goal improvements

## Request Patterns

Good:

- "Fix only `src/auth.ts` for login failure. Minimal change. Stop after verification."
- "Review only regression risks in this diff. Skip style feedback."

Bad:

- "Refactor the whole project while improving performance and architecture."

## Completion Rule

A run is complete when:

- `Done When` is met
- output explains why we should stop now
- remaining enhancements are explicitly deferred
