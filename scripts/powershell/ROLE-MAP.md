# PowerShell Role Map

`scripts/` 루트에는 아직 일부 공개 진입점이 남아 있지만, PowerShell 스크립트는 역할별 폴더 기준으로 정리합니다.

## bootstrap

- `scripts/powershell/bootstrap/init-project.ps1`
- `scripts/powershell/bootstrap/install-git-hooks.ps1`
- `scripts/powershell/bootstrap/start-task.ps1`

## cleanup

- `scripts/powershell/cleanup/archive-to-graveyard.ps1`
- `scripts/powershell/cleanup/find-code-refactor-candidates.ps1`
- `scripts/powershell/cleanup/find-file-refactor-candidates.ps1`

## context

- `scripts/powershell/context/build-project-context.ps1`
- `scripts/powershell/context/select-context-pack.ps1`

## guards

- `scripts/powershell/guards/hook-pre-commit.ps1`
- `scripts/powershell/guards/hook-pre-push.ps1`
- `scripts/powershell/guards/run-code-rules-checks.ps1`
- `scripts/powershell/guards/run-code-rules.helpers.ps1`
- `scripts/powershell/guards/run-code-rules.security.ps1`
- `scripts/powershell/guards/run-session-guard-checks.ps1`
- `scripts/powershell/guards/run-token-ops-checks.ps1`
- `scripts/powershell/guards/run-worklog-checks.ps1`

## harness

- `scripts/powershell/harness/run-harness-checks.ps1`

## orchestrator

- `scripts/powershell/orchestrator/apply-orchestrator-state-patch.ps1`
- `scripts/powershell/orchestrator/debug-orchestrator.ps1`
- `scripts/powershell/orchestrator/invoke-host-wrapper.ps1`
- `scripts/powershell/orchestrator/invoke-host-wrapper.helpers.ps1`
- `scripts/powershell/orchestrator/orchestrator-state.helpers.ps1`
- `scripts/powershell/orchestrator/run-orchestration.ps1`

## secrets

- `scripts/powershell/secrets/export-project-secrets.ps1`
- `scripts/powershell/secrets/import-project-secrets.ps1`
- `scripts/powershell/secrets/import-project-secrets.helpers.ps1`
- `scripts/powershell/secrets/load-project-secrets.ps1`
- `scripts/powershell/secrets/project-secrets.crypto.helpers.ps1`

## skills

- `scripts/powershell/skills/run-skill.ps1`
- `scripts/powershell/skills/skill-claude.ps1`
- `scripts/powershell/skills/skill-codex.ps1`
- `scripts/powershell/skills/skill-minimum-goal.ps1`

## Rule

- 새 PowerShell 스크립트는 먼저 역할 폴더 위치를 정하고 그 안에 추가합니다.
- 공용 로직은 가능하면 `scripts/shared/`로 올리고, PowerShell 파일은 얇은 entrypoint나 wrapper로 유지합니다.
