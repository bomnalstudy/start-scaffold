# Requirement Routing Rules

Use these rules to decide where a persistent user requirement should live.

## Decision Order

1. Decide whether the request is durable enough to encode.
2. Decide whether the behavior is repo-owned or host-owned.
3. Choose the narrowest repository layer that future sessions will reliably load.
4. Update only the minimum supporting files needed for discoverability.

## Route To `AGENTS.md`

Use `AGENTS.md` when the request is a repository-wide operating rule that should apply across agents, modes, and tasks.

Examples:

- universal coding constraints
- session start/close behavior
- global risk rules
- repository-wide file design or logging rules

## Route To `docs/modes/shared/`

Use shared mode docs when the rule is reused by multiple modes but is still narrower than a full repository-wide operating rule.

Examples:

- mode naming rules
- shared mode routing behavior
- reusable environment or file-structure guidance

## Route To `docs/modes/<mode>/`

Use a mode doc when the requirement only matters inside one domain.

Examples:

- secure review additions for `secure-mode`
- harness assertion rules for `harness-mode`
- customization workflow rules for `add-mode`

## Route To `skills/<skill>/SKILL.md`

Use a skill file when another agent needs an explicit trigger description, short workflow, and "read first" list.

The skill should route to docs.
Do not restate full reference material there.

## Route To `skills/<skill>/agents/openai.yaml`

Use UI metadata when the repo-local skill should be easier to discover in the skill UI or through a stable default prompt.

## Route To Task Plans And Worklogs

Use `worklogs/tasks/` and `worklogs/` when the change introduces:

- a new rule
- an architectural or workflow decision
- an important AI assumption
- a prevention note for future sessions

## Route To Scripts Or Checks

Only add or change scripts/checks when a durable rule has already become operationally important and docs alone are no longer enough.

Prefer this escalation order:

1. doc rule
2. skill wording
3. template or task/worklog field
4. code-rules check
5. wrapper or script automation

## Repo-Owned Boundary Rule

Pause and classify the request as host-owned when it mainly depends on:

- slash discovery or UI indexing
- model product behavior outside the repo
- global skills outside this repository
- external platform settings not controlled here

If the request is host-owned, document the boundary and make only the repo-side changes that still help.
