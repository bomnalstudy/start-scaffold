# Token Ops Standard

This is the mandatory token-efficiency operating standard for all AI work in this repository.

If a task conflicts with this document, we pause and re-scope before continuing.

## 1. Objective

- Minimize token spend while preserving task correctness.
- Keep context stable, short, and reusable across turns.
- Finish small MVP tasks quickly instead of running long, drifting sessions.

## 2. Required Workflow

Every task follows this sequence:

1. Write `Original Goal`, `MVP Scope`, `Non-Goal`, `Done When`.
2. Load only relevant files.
3. Implement minimum viable change.
4. Verify with focused checks.
5. Stop when `Done When` is satisfied.

## 3. Context Budget Rules

- Do not send whole files unless required.
- Prefer diffs, snippets, and line-bounded context.
- Keep one objective per run.
- Split implementation and review into separate runs.
- Keep static instructions stable and place variable details at the end.

## 4. Prompt Structure Rules

Use a stable prefix for repeated tasks:

```md
Original Goal:
MVP Scope:
Non-Goal:
Done When:
Stop If:
```

Then append only the minimum dynamic context:

- target files
- current error/output summary
- required verification

## 5. Caching and Reuse Rules

- Reuse consistent instruction headers between similar runs.
- Keep common tool instructions unchanged where possible.
- Avoid unnecessary rewording of repeated system constraints.
- Track `cached_tokens` or equivalent usage signals when available.

## 6. Anti-Patterns (Disallowed)

- "Read the whole repo and improve everything."
- Multi-goal prompts mixing bugfix, refactor, perf, and design at once.
- Repeating the same long requirements block every turn.
- Sending full logs when a short error summary is enough.

## 7. Agent-Specific Adapters

- Codex adapter: `CODEX.md`
- Claude adapter: `CLAUDE.md`

Both adapters must enforce this standard first.

## 8. Enforcement Checklist

Before starting a run, all must be true:

- `Original Goal` exists.
- `MVP Scope` is minimal.
- `Non-Goal` is explicit.
- task context is file-scoped.
- verification target is defined.

Before closing a run, all must be true:

- `Done When` is satisfied.
- output includes "why we should stop now".
- unfinished items are deferred to next iteration.
