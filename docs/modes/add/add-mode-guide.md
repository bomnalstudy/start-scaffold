# Add Mode Guide

`add-mode` is the repository customization mode.

Use it when the user describes a rule, preference, workflow, or recurring requirement that should keep applying in future sessions without being restated every time.

The goal is not to implement product code first.
The goal is to decide which repository-owned instruction layers should change so the new requirement becomes part of the scaffold's normal behavior.

## Read First

1. `AGENTS.md`
2. `docs/modes/shared/agent-modes.md`
3. `docs/modes/shared/agent-skills.md`
4. `docs/modes/README.md`
5. this file
6. `docs/modes/add/requirement-routing-rules.md`
7. the relevant task plan and worklog
8. the specific skill/docs files already closest to the requested behavior

## What Counts As Add-Mode Work

- a user says "from now on always do X"
- a user wants a persistent working style or review rule
- a project needs a repeated instruction baked into repo docs
- a current mode or skill is missing project-specific guidance
- a repeated chat explanation should become a reusable scaffold rule

## What Does Not Count

- one-off feature requests
- temporary task-specific notes
- host-owned behavior that the repo cannot control by editing local files
- broad refactors with no clear persistent rule to encode

## Workflow

1. Extract the durable request in one sentence.
2. Decide whether it is global, mode-specific, shared across modes, or host-owned.
3. Map the request to the smallest set of repository surfaces that should change.
4. Prefer additive edits over rewrites.
5. Update task/worklog records when the change introduces a new rule, mode rule, or important assumption.
6. Verify that the new rule is discoverable from the most likely entry points.

## Output Shape

Report the result in this order:

- durable requirement
- classification
- target surfaces
- why those surfaces were chosen
- changes made
- verification
- deferred items

## Guardrails

- Do not duplicate large chunks of existing docs when a cross-reference is enough.
- Do not treat host indexing, slash discovery, or model product behavior as repo-owned unless confirmed.
- Do not add new automation scripts unless repeated manual work is already obvious.
- Keep the rule close to where future agents will actually look first.
