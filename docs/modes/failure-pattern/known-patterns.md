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

## Rename Drift Between Public Entry And Internal Implementation

- Pattern: a rename was applied to the public-facing command or skill name, but the internal implementation file or helper name stayed on the old term.
- Why it happened: the interface rename landed first, while lower-level script and helper names were left for later cleanup.
- Trigger: renaming a mode, skill, wrapper, or script family across the scaffold.
- Early signal: a new top-level name exists, but wrappers still point at old implementation names or docs mention both names unevenly.
- Prevention Rule: every rename task must check four layers before closing: public skill name, runner script, internal implementation file, and shared docs/routing references.
- Enforcement: shared docs
- Escalation: if the same drift happens again, add a rename-completeness checklist to the task template for mode and script migrations.
- Next check: on the next naming migration, verify that the user-facing entry point and the real implementation file use the same primary term before stopping.

## Bulk Archive Basename Collision

- Pattern: cleanup automation tried to archive multiple files with the same basename and collided inside `.graveyard/files`.
- Why it happened: the archive flow originally used only the leaf filename, which is not unique enough for bulk cleanup across many folders.
- Trigger: batch retirement of similarly named files such as many `SKILL.md` files or repeated script names from different directories.
- Early signal: archive output paths collapse to the same destination name, or a second archive attempt fails even though the source files differ.
- Prevention Rule: archive paths for retired files must be derived from the relative source path, not only the leaf filename.
- Enforcement: code-rules script
- Escalation: if archive collisions appear again, add a focused regression check for batch archive scenarios before using cleanup automation on repeated filenames.
- Next check: the next time batch cleanup archives repeated filenames, confirm the graveyard paths remain unique per relative source path.
