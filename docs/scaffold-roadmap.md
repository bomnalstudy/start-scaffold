# Scaffold Roadmap

## Purpose

- Keep the near-term scaffold backlog visible so orchestration, harness, UI/UX, and reliability work do not drift across sessions.

## Current Priorities

### 1. Code version naming rules

- Define a consistent naming rule for versioned code artifacts in the scaffold.
- Apply the rule with extra care to orchestrator and harness outputs so pipeline stages do not confuse similar files later.
- Document where the version label must appear: file name, generated output, plan/worklog references, and handoff points.
- Keep a stable host-wrapper path for orchestrator execution so host drift does not spread across orchestrators.
- Make the main orchestrator own the shared state contract while worker orchestrators read snapshots and submit patch-style updates.

### 2. Failure pattern memory

- Add a place to record recurring problem patterns.
- Add a lightweight prevention loop so the same issue is less likely to repeat in later sessions.
- Keep the format short enough to be used during normal MVP work.

### 3. Performance and stability design

- Design for app responsiveness and reduced lag under load.
- Treat traffic distribution as one part of a broader performance topic that also includes bottleneck isolation, queueing, caching, throttling, and graceful degradation.
- Keep the first pass at the design level and avoid premature infrastructure lock-in until the pipeline and harness boundaries are clearer.

### 4. UX/UI follow-up

- Finish the in-progress UX/UI guardrail work inside this scaffold.
- Make UI tasks explicitly classify their surface as `web`, `app`, `shared`, or `non-UI`.
- Make the matching quality guard visible in task planning so future UI work starts from the right rule set.

### 5. Secure-by-default coding support

- Design a scaffold feature or workflow that strengthens security while coding.
- Focus on prevention-first help such as checks, prompts, and safe defaults instead of heavy platform features in the first pass.
- Keep secrets, auth, and other high-risk areas behind explicit review gates.

## Suggested Order

1. Finish UX/UI follow-up in the scaffold workflow.
2. Define code version naming rules for orchestrator and harness paths.
3. Add failure pattern recording and repeat-prevention hooks.
4. Draft performance and stability architecture.
5. Design secure-by-default coding support.

## Notes

- This roadmap is a memory aid, not a commitment to build everything in one session.
- Each item should still be split into its own minimal task plan before implementation.
