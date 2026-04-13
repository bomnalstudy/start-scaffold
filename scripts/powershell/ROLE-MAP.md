# PowerShell Role Map

루트 `scripts/*.ps1` 엔트리포인트는 호환성을 위해 유지하고, 이 문서에서 역할 기준 분류를 먼저 고정합니다.

## bootstrap

- `scripts/init-project.ps1`
- `scripts/install-git-hooks.ps1`
- `scripts/start-task.ps1`

## cleanup

- `scripts/archive-to-graveyard.ps1`
- `scripts/find-code-refactor-candidates.ps1`
- `scripts/find-file-refactor-candidates.ps1`

## context

- `scripts/build-project-context.ps1`
- `scripts/select-context-pack.ps1`

## guards

- `scripts/hook-pre-commit.ps1`
- `scripts/hook-pre-push.ps1`
- `scripts/run-code-rules-checks.ps1`
- `scripts/run-code-rules.helpers.ps1`
- `scripts/run-code-rules.security.ps1`
- `scripts/run-session-guard-checks.ps1`
- `scripts/run-token-ops-checks.ps1`
- `scripts/run-worklog-checks.ps1`

## harness

- `scripts/run-harness-checks.ps1`

## orchestrator

- `scripts/apply-orchestrator-state-patch.ps1`
- `scripts/debug-orchestrator.ps1`
- `scripts/invoke-host-wrapper.ps1`
- `scripts/invoke-host-wrapper.helpers.ps1`
- `scripts/orchestrator-state.helpers.ps1`
- `scripts/run-orchestration.ps1`

## secrets

- `scripts/export-project-secrets.ps1`
- `scripts/import-project-secrets.ps1`
- `scripts/import-project-secrets.helpers.ps1`
- `scripts/load-project-secrets.ps1`
- `scripts/project-secrets.crypto.helpers.ps1`

## skills

- `scripts/run-skill.ps1`
- `scripts/skill-claude.ps1`
- `scripts/skill-codex.ps1`
- `scripts/skill-minimum-goal.ps1`

## Rule

- 새 PowerShell 스크립트를 추가할 때는 먼저 이 역할 맵에 들어갈 위치를 정합니다.
- 공용 로직은 가능하면 `scripts/shared/`로 올리고, PowerShell entrypoint는 얇게 유지합니다.
