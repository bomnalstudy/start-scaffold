# 2026-04-13 Minimum Goal Skill Unification Log

## What changed

- Added shared `minimum-goal-*` skills and a shared runner script.
- Pointed `skill-codex.ps1` and `skill-claude.ps1` to the shared runner.
- Marked the older `claude-speed-*` and `codex-speed-*` skills as compatibility aliases.
- Documented that repo-local mode skills are agent-neutral and usable from both Claude and Codex.

## Why

- The workflow was already shared under the hood, so separate speed-family names added unnecessary duplication.
- A neutral `minimum-goal-*` family is easier to remember and fits the repository intent better than `speed`.

## Verification

- Run `run-session-guard-checks`.
- Run `run-code-rules-checks`.

## Mistakes / Drift Signals Observed

- The host UI may still list old names until global skill registration is updated separately.

## Prevention for Next Session

- Add new shared skills first, then deprecate old aliases gradually instead of deleting them abruptly.

## Direction Check

- Stop here because the unified skill family exists and old commands still have a safe path.
- A later cleanup can remove deprecated aliases only after confirming the new names are adopted.

## Next Tasks

- If needed, install `minimum-goal-*` into the global skill directory for slash discovery.
- Later, retire the deprecated `*-speed-*` aliases once usage is stable.

## Remaining risk

- Some host UIs may continue showing older skill names until their skill index refreshes.
