# 2026-04-13 PowerShell Role Structure Log

## Original Goal

- PowerShell 스크립트를 역할 기준으로 보기 쉽게 나누는 구조를 만든다.

## MVP Scope (This Session)

- `scripts/powershell/<role>/` 디렉터리 구조를 만들었다.
- 역할별 README와 `ROLE-MAP.md`를 추가했다.
- 루트 엔트리포인트를 유지한 채 분류 기준을 먼저 고정했다.

## Key Changes

- `scripts/powershell/README.md`를 실제 역할 구조 안내 문서로 바꿨다.
- `scripts/powershell/ROLE-MAP.md`에 현재 루트 PowerShell 스크립트의 역할 분류를 정리했다.
- `bootstrap`, `cleanup`, `context`, `guards`, `harness`, `orchestrator`, `secrets`, `skills` 폴더를 만들고 각 README를 추가했다.
- 각 역할 폴더에 루트 `scripts/*.ps1`를 호출하는 PowerShell wrapper 파일을 추가했다.
- `README.md`에도 새 구조 기준과 호환 엔트리포인트 유지 원칙을 반영했다.

## Validation

- `Get-ChildItem scripts/powershell -Directory`
- `run-code-rules-checks.ps1`

## Mistakes / Drift Signals Observed

- 바로 구현 파일까지 모두 옮기면 기존 문서, 훅, WSL parity, dot-source helper 관계가 같이 흔들릴 가능성이 높았다.

## Prevention for Next Session

- 다음 이동은 역할 폴더 기준으로 한 묶음씩 진행한다.
- helper가 dot-source 되는지 먼저 확인하고 이동한다.
- 루트 엔트리포인트를 compatibility wrapper로 바꾸는 건 role별로 나눠서 한다.

## Direction Check

- 지금은 역할 폴더와 분류 기준을 먼저 세우고 stop 하는 게 맞다.
- 실제 구현 이동은 영향 범위가 더 커서 다음 세션에 role-by-role로 넘기는 게 안전하다.
- 현재는 루트 엔트리포인트와 역할 폴더 wrapper를 같이 유지하는 구조가 가장 안정적이다.

## Next Tasks

- `secrets` 역할부터 구현 파일 이동 가능성 검토
- `guards` 역할의 helper / entrypoint 관계 정리
- 루트 wrapper 전환 자동화 설계
