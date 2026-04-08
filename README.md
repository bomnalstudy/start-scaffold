# Vibe Coding Start Scaffold

AI와 함께 프로젝트를 시작할 때 매번 반복되는 혼란을 줄이기 위한 범용 스캐폴드입니다.

이 템플릿은 아래 문제를 먼저 막는 데 집중합니다.

- 작업 지시가 흩어져 AI가 프로젝트 맥락을 자주 잃는 문제
- 빠른 수정이 누적되며 구조가 망가지는 문제
- 토큰과 컨텍스트를 과소비하는 문제
- 여러 컴퓨터를 오가며 프로젝트별 토큰과 환경변수를 관리하기 어려운 문제
- 개발 일지가 없어 "왜 이렇게 바꿨는지"가 사라지는 문제

## 포함 내용

- `AGENTS.md`: Codex/Claude 공통 프로젝트 운영 규칙
- `CODEX.md`: Codex용 운영 어댑터
- `CLAUDE.md`: Claude용 운영 어댑터
- `docs/`: AI 사용 가이드, 프로젝트 시작 브리프, 코딩 기본 규칙, 실패 예방 기획안, 가드레일, 오케스트레이션 패턴, 하네스 설계, 오케스트레이션/하네스 리서치, 개발 일지, 토큰 운영 표준
- `scripts/`: 프로젝트별 시크릿 내보내기/가져오기/불러오기 스크립트
- `templates/`: `.env` 예시, 개발 일지 템플릿, 오케스트레이션/하네스 명세 템플릿
- `.graveyard/`: 더 이상 쓰지 않는 파일을 주석화 또는 비활성화 후 임시 격리하는 Git 제외 폴더
- `.gitignore`: 로컬 시크릿과 작업 산출물 보호

## 추천 시작 순서

1. `AGENTS.md`와 `docs/token-ops-standard.md`를 먼저 읽습니다.
2. Codex는 `CODEX.md`, Claude는 `CLAUDE.md`를 추가로 읽습니다.
3. `templates/.env.local.example`를 참고해 `.local/project.secrets.env`를 만듭니다.
4. `docs/workflow.md`와 `docs/project-guardrails.md`를 읽고 작업 규칙을 확정합니다.
5. 새 프로젝트나 큰 작업은 `docs/project-start-brief.md` 질문으로 먼저 시작합니다.
6. 프론트엔드 구조 규칙은 `docs/coding-rules.md`를 기준으로 맞춥니다.
7. 바이브 코딩 실패 패턴과 종료 규칙은 `docs/vibe-coding-failure-prevention.md`를 같이 봅니다.
8. 새 작업을 시작하기 전에 `docs/journaling.md` 템플릿으로 로그를 남깁니다.
9. 다른 PC로 옮길 때는 `scripts/export-project-secrets.ps1`로 암호화 번들을 만든 뒤 `scripts/import-project-secrets.ps1`를 사용합니다.

## 빠른 시작

PowerShell:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\scripts\init-project.ps1
```

로컬 시크릿 파일 생성 후 현재 세션에 로드:

```powershell
.\scripts\load-project-secrets.ps1
```

코딩 규칙 오케스트레이션 검사 실행:

```powershell
.\scripts\run-orchestration.ps1 -Pipeline code-rules
```

토큰 운영 + 코딩 규칙 통합 검사 실행:

```powershell
.\scripts\run-orchestration.ps1 -Pipeline all -PlanPath templates/orchestration-plan.md
```

필요한 문서만 선택해서 컨텍스트 로드:

```powershell
.\scripts\select-context-pack.ps1 -Agent codex -Pack implement
```

작업 시작 파일 생성 + 컨텍스트 선택 + 토큰 검사:

```powershell
.\scripts\start-task.ps1 -TaskName "my first mvp" -Agent codex -Pack start
```

프로젝트 참고정보 자동 생성(서버/데이터 루트/핵심 파일):

```powershell
.\scripts\build-project-context.ps1
```

개발일지 핵심 항목 검사:

```powershell
.\scripts\run-orchestration.ps1 -Pipeline worklog -WorklogPath .\worklogs\2026-04-08-my-first-mvp-log.md
```

암호화된 시크릿 번들 생성:

```powershell
.\scripts\export-project-secrets.ps1
```

다른 컴퓨터에서 시크릿 가져오기:

```powershell
.\scripts\import-project-secrets.ps1
```

## 디렉터리 구조

```text
.
|-- AGENTS.md
|-- CODEX.md
|-- CLAUDE.md
|-- README.md
|-- .graveyard
|   |-- files
|   `-- notes
|-- docs
|   |-- ai-usage-guide.md
|   |-- coding-rules.md
|   |-- project-context.compact.md
|   |-- project-context.md
|   |-- harness-guide.md
|   |-- journaling.md
|   |-- multi-machine-secrets.md
|   |-- orchestration-harness-research.md
|   |-- orchestration-patterns.md
|   |-- project-start-brief.md
|   |-- project-guardrails.md
|   |-- token-efficiency.md
|   |-- token-ops-research.md
|   |-- token-ops-standard.md
|   |-- vibe-coding-failure-prevention.md
|   `-- workflow.md
|-- scripts
|   |-- archive-to-graveyard.ps1
|   |-- build-project-context.ps1
|   |-- export-project-secrets.ps1
|   |-- import-project-secrets.ps1
|   |-- init-project.ps1
|   |-- load-project-secrets.ps1
|   |-- run-code-rules-checks.ps1
|   |-- run-worklog-checks.ps1
|   |-- run-token-ops-checks.ps1
|   |-- select-context-pack.ps1
|   |-- start-task.ps1
|   `-- run-orchestration.ps1
|-- templates
|   |-- .env.local.example
|   |-- harness-spec.md
|   |-- journal-entry.md
|   |-- orchestration-plan.md
|   `-- project-context.source.json
`-- worklogs
    `-- README.md
```

## 기본 원칙

- AI는 빠르지만 설계와 검증을 생략하면 프로젝트를 빠르게 망가뜨릴 수도 있습니다.
- 작은 단위 작업, 짧은 컨텍스트, 명확한 로그, 명시적 가드레일을 기본값으로 둡니다.
- 시크릿은 프로젝트별로 분리하고, 평문 공유 대신 암호화 번들로 옮깁니다.
- 수명이 끝난 파일은 삭제 전 `.graveyard/`로 이동해 Git 추적 밖에서 격리합니다.
- `.graveyard/`로 이동하는 파일은 현재 코드에 영향을 주지 못하도록 먼저 주석화하거나 비활성 확장자로 바꿉니다.
- "한 번에 크게"보다 "짧게 만들고 바로 검증"을 우선합니다.
