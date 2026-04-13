# 2026-04-13 Native Secrets Format 3 Log

## Original Goal

- `export/import-project-secrets`를 PowerShell 경유 없는 native WSL/Linux까지 포함하는 공용 포맷으로 올린다.

## MVP Scope (This Session)

- `format 3` 시크릿 번들을 도입한다.
- PowerShell export/import와 native WSL export/import를 같은 포맷에 맞춘다.
- runtime parity와 secure docs를 갱신한다.

## Key Changes

- `scripts/project-secrets.crypto.helpers.ps1`를 추가해 PBKDF2, HMAC, AES-CBC 로직을 공용 helper로 뺐다.
- `scripts/export-project-secrets.ps1` 기본 포맷을 `format 3`으로 바꿨다.
- `scripts/import-project-secrets.ps1` / `import-project-secrets.helpers.ps1`에 `format 3` 복호화와 검증을 추가했다.
- `scripts/shared/secure_bundle.py`를 추가해 native WSL export/import를 `python3 + openssl`로 처리하게 했다.
- `scripts/bash/export-project-secrets.sh`, `scripts/bash/import-project-secrets.sh`를 native 진입점으로 바꿨다.
- `docs/modes/secure/multi-machine-secrets.md`를 UTF-8 정상 문서로 다시 작성하고 `format 3` 기준을 반영했다.
- `docs/modes/shared/runtime-parity-roadmap.md`에서 secrets workflow를 `done`으로 올렸다.

## Validation

- PowerShell `export-project-secrets.ps1` smoke test
- PowerShell `import-project-secrets.ps1` smoke test
- native WSL `export-project-secrets.sh` smoke test
- native WSL `import-project-secrets.sh` smoke test
- `run-code-rules-checks.ps1`
- `run-session-guard-checks.ps1`

## Mistakes / Drift Signals Observed

- legacy `format 1`, `format 2`는 native WSL에서 그대로 복호화하지 못한다.
- 기존 문서 하나가 인코딩이 깨져 있어 secrets 흐름 설명을 신뢰하기 어려웠다.

## Prevention for Next Session

- 새 표준 포맷은 `format 3`으로 유지하고, native 사용이 필요하면 기존 번들을 재-export 하도록 명시한다.
- secure/runtime 관련 문서는 인코딩이 깨지면 바로 재작성한다.

## Direction Check

- WSL parity를 억지로 PowerShell bridge에 묶지 않고, 공용 포맷과 thin wrapper 방향으로 정리한 것은 맞다.
- legacy native parity보다 현재 표준 포맷의 안정화를 우선한 판단도 맞다.
- 지금은 `format 3` smoke test와 문서 갱신이 끝나면 stop 하고, legacy upgrade helper 여부는 next session으로 넘긴다.

## Next Tasks

- `format 3` smoke test를 harness 시나리오로 올릴지 검토
- legacy vault upgrade helper가 필요한지 판단
- slash skill index 노출 문제는 별도 호스트 이슈로 분리 추적
