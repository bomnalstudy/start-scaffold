# Known Failure Patterns

Record only repeated or high-confidence patterns here.
If evidence is weak, use the no-pattern result instead of adding noise.

## Host-Owned Skill Discovery Assumption

- Pattern: repo-side skill registration was treated as if it could fully control slash discovery.
- Why it happened: the first fix focused on skill files and metadata before confirming whether slash indexing was owned by the host UI.
- Trigger: work on slash commands, skill discovery, or chat UI integration.
- Early signal: repo files change, but the slash list still does not move and verification stays inside the repo.
- Prevention Rule: confirm the host boundary first. For slash and discovery issues, check global skill path, restart scope, and host indexing ownership before expanding repo-side registration changes.
- Enforcement: shared docs
- Escalation: if the same assumption happens again, add a short host-owned versus repo-owned checklist to the task template before more repo-side registration work.
- Next check: on the next slash/discovery issue, spend the first check cycle confirming host-owned behavior before editing repo metadata.
