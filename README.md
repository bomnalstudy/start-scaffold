# Vibe Coding Start Scaffold

AI 코딩 에이전트가 프로젝트를 시작하고, 작업 범위를 좁히고, 규칙을 지키며, 로그를 남기고, 반복 실수를 줄이도록 돕는 범용 스캐폴드입니다.

이 저장소는 특히 아래 문제를 줄이는 데 초점을 둡니다.

- 작업할 때마다 규칙과 시작 절차가 흔들리는 문제
- 세션이 길어질수록 범위와 문맥이 퍼지는 문제
- 오케스트레이터, 하네스, UI, 보안, 최적화 같은 축이 뒤섞이는 문제
- 시크릿과 개발 로그, 작업 기록이 제각각 흩어지는 문제
- 같은 실수를 나중 세션에서 다시 반복하는 문제

## 핵심 구성

- `AGENTS.md`
  - Codex, Claude, 기타 AI 에이전트가 공통으로 따라야 할 운영 기준
- `CODEX.md`, `CLAUDE.md`
  - 에이전트별 어댑터 문서
- `docs/`
  - 모드 문서, 가드레일, 워크플로, 토큰 운영 규칙
- `scripts/`
  - task 시작, context 선택, 코드 규칙 검사, 시크릿 처리, 스킬 실행 스크립트
- `skills/`
  - repo-local 스킬 엔트리
- `templates/`
  - task plan, harness, 예시 helper, 상태 계약 템플릿
- `worklogs/`
  - 작업 계획과 변경 로그
- `.graveyard/`
  - 더 이상 쓰지 않는 파일을 주석 처리 또는 비활성화 후 격리하는 보관 폴더

## 빠른 시작

1. `AGENTS.md`와 `docs/token-ops-standard.md`를 먼저 읽습니다.
2. 사용하는 에이전트에 따라 `CODEX.md` 또는 `CLAUDE.md`를 봅니다.
3. 필요하면 시크릿 파일을 준비합니다.
4. 새 작업은 `start-task.ps1` 또는 `minimum-goal-*` 계열로 시작합니다.
5. 작업 중간에는 필요한 mode만 좁게 불러서 진행합니다.

PowerShell 예시:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\scripts\init-project.ps1
```

새 task 시작:

```powershell
.\scripts\start-task.ps1 -TaskName "my first mvp" -Agent codex -Pack start
```

공용 minimum-goal 스킬 시작:

```powershell
.\scripts\skill-minimum-goal.ps1 -Agent codex -Stage start -TaskName "my task" -Pack start
```

필요한 문서만 골라서 context 로드:

```powershell
.\scripts\select-context-pack.ps1 -Agent codex -Pack implement
```

코드 규칙 검사:

```powershell
.\scripts\run-code-rules-checks.ps1
```

## 현재 스킬

### 공용 작업 게이트

- `minimum-goal-start`
  - 새 작업을 시작할 때 사용
  - task plan, worklog, 시작 가드를 빠르게 맞출 때 적합
- `minimum-goal-checkpoint`
  - 큰 체크포인트에서 사용
  - 범위가 퍼지지 않았는지, 문서와 로그가 맞는지 확인할 때 적합
- `minimum-goal-close`
  - 세션이나 작업을 닫기 전에 사용
  - 지금 멈춰도 되는지와 다음 작업을 정리할 때 적합
- `minimum-goal-gate`
  - 위 세 단계를 한 가족처럼 묶어서 볼 때 사용
  - Claude와 Codex 둘 다 같은 흐름으로 쓰고 싶을 때 적합

### 작업 모드

- `ux-ui-mode`
  - UX/UI 작업 전용
  - 화면 마무리, 정보 위계, 가독성, quality guard 선택이 필요할 때 사용
- `secure-mode`
  - 보안 전용
  - 시크릿, 인증, 유저 정보 유출, unsafe sink, access control 검토가 필요할 때 사용
- `optimize-mode`
  - 최적화 전용
  - 렉 감소, API/data 효율, 취소, 워터폴, 동시성 budget, 반응성 개선이 필요할 때 사용
- `db-mode`
  - DB 및 API 계약 설계 전용
  - 엔티티, ownership, relationship, DTO, pagination, idempotency 설계가 필요할 때 사용
- `code-refactor-mode`
  - 코드 리뷰 및 리팩터링 전용
  - 중복 로직, mixed responsibility, dead weight, maintainability 개선이 필요할 때 사용
- `orchestrator-mode`
  - 오케스트레이터 전용
  - host wrapper, state ownership, version naming, patch flow, reliability 규칙을 다룰 때 사용
- `harness-mode`
  - 하네스 전용
  - scenario, assertion, fixture isolation, verification loop를 설계할 때 사용
- `failure-pattern-mode`
  - 반복 실수 기록 전용
  - 같은 문제가 다시 나오지 않게 pattern, trigger, prevention, enforcement를 남길 때 사용

## 스킬 사용 기준

- 하나의 작업에는 보통 하나의 주요 mode만 잡는 것이 좋습니다.
- 두 개 이상이 필요하면 주 mode를 먼저 정하고, 다른 mode 규칙은 최소한만 빌려옵니다.
- repo-local mode 스킬은 Claude와 Codex 둘 다 사용할 수 있습니다.
- slash 목록이 바로 안 바뀌면 세션 재시작이나 창 리로드가 필요할 수 있습니다.

## 자주 쓰는 스크립트

- `scripts/start-task.ps1`
  - 새 task plan과 worklog를 만들고 시작 가드를 돌립니다.
- `scripts/run-orchestration.ps1`
  - session guard, token ops, code rules, worklog 체크를 파이프라인처럼 실행합니다.
- `scripts/run-code-rules-checks.ps1`
  - 파일 크기, 책임 혼합, graveyard 참조, 보안 신호 등을 검사합니다.
- `scripts/find-code-refactor-candidates.ps1`
  - code-refactor 기준으로 정리 후보를 찾습니다.
- `scripts/archive-to-graveyard.ps1`
  - 수명이 끝난 파일을 `.graveyard/`에 안전하게 보관합니다.
- `scripts/load-project-secrets.ps1`
  - 로컬 시크릿을 현재 세션에 로드합니다.
- `scripts/export-project-secrets.ps1`
  - 암호화된 시크릿 번들을 만듭니다.
- `scripts/import-project-secrets.ps1`
  - 다른 환경에서 암호화된 시크릿 번들을 복원합니다.

## 디렉터리 구조

```text
.
|-- AGENTS.md
|-- CODEX.md
|-- CLAUDE.md
|-- README.md
|-- docs/
|   |-- modes/
|   |   |-- ux-ui/
|   |   |-- secure/
|   |   |-- optimize/
|   |   |-- db/
|   |   |-- code-refactor/
|   |   |-- orchestrator/
|   |   |-- harness/
|   |   |-- failure-pattern/
|   |   `-- shared/
|   `-- ...
|-- scripts/
|-- skills/
|-- templates/
|-- worklogs/
|-- .graveyard/
|   |-- files/
|   `-- notes/
`-- .githooks/
```

## 운영 원칙

- 작은 범위부터 닫습니다.
- 문서와 로그를 같이 유지합니다.
- 활성 코드에서 `.graveyard/`를 참조하지 않습니다.
- 보안, 최적화, 오케스트레이터, 하네스, 리팩터링은 각각 mode로 좁혀서 다룹니다.
- “무조건 크게 정리”보다 “작고 검증 가능한 개선”을 우선합니다.

## 참고

- 실제 규칙의 기준 문서는 `AGENTS.md`입니다.
- mode별 상세 규칙은 `docs/modes/<mode>/` 아래에 있습니다.
- 작업 시작과 종료 시 필요한 필드는 `worklogs/`와 템플릿을 기준으로 관리합니다.
