# AGENTS.md

이 파일은 Codex, Claude, 기타 AI 코딩 에이전트가 프로젝트에서 공통으로 따라야 할 운영 기준 문서입니다.

## 1. 목표

- 명확한 요구 기준을 가진 최소 프로젝트를 빠르게 완성한다.
- 빠른 구현보다 프로젝트 지속 가능성을 우선한다.
- 구조를 깨는 임시 수정은 최소화한다.
- 모든 중요한 변경은 이유와 영향 범위를 기록한다.
- 모든 작업은 `docs/token-ops-standard.md`를 먼저 따른다.

## 2. 작업 원칙

- "개발자다운 과한 완성도"보다 "작고 명확하게 끝나는 결과물"을 우선한다.
- 항상 최소 프로젝트와 최소 범위부터 닫는다.
- 요구 조건이 명확하지 않으면 먼저 기준을 세운다.
- 항상 작은 단위로 나눠서 수정한다.
- 코드를 바꾸기 전 현재 구조와 의존성을 먼저 확인한다.
- 한 번에 너무 많은 파일을 동시에 바꾸지 않는다.
- "작동만 하는 코드"보다 "다음 세션에서도 읽히는 코드"를 선호한다.

## 3. 변경 전 체크

- 이번 변경의 목적이 한 문장으로 설명되는가
- 영향받는 파일과 기능 범위를 알고 있는가
- 되돌리기 쉬운 단위인가
- 테스트나 검증 방법이 있는가
- `Original Goal`, `Non-Goal`, `Done When`이 정의되어 있는가
- `MVP Scope`가 최소 범위로 정의되어 있는가
- 범용 작업이라면 `Generic Requirement`와 `Stop If`가 정의되어 있는가

## 4. 위험 변경 규칙

- 인증, 결제, 배포, 저장소, 빌드 설정 변경은 기본적으로 고위험으로 본다.
- 고위험 변경은 계획, 검증, 롤백 경로 없이 바로 진행하지 않는다.
- 문제 원인을 모르는 상태에서 연쇄 수정하지 않는다.

## 4.1 코딩 기본 규칙

- 일반 소스 파일은 500줄을 넘기지 않는다.
- 300줄을 넘어가면 예의주시하고 책임 혼합이나 빠른 증가 여부를 확인한다.
- 파일은 종류보다 사용처 기준으로 colocate 한다.
- 여러 곳에서 재사용되는 순수 로직만 `utils/`로 올린다.
- `utils/`는 목적별 하위 폴더로 나눈다.
- inline CSS는 금지한다.
- 각 컴포넌트/화면 폴더에 별도 CSS 파일을 둔다.
- 가능하면 CSS Modules를 우선 사용한다.
- 실행 환경 전략은 `docs/modes/shared/runtime-environment-patterns.md`를 따른다.
- 환경 패턴은 기본적으로 `powershell-bridged`를 사용하고, Linux-first 요구가 명확할 때만 `native-wsl-linux`를 검토한다.

## 4.1.1 File Design Rule

- 파일 설계 규칙은 특정 skill이 아니라 저장소 전체에 항상 적용되는 전역 규칙으로 본다.
- 파일은 커밋과 리뷰가 가능한 단위로 유지한다.
- 하나의 파일에 여러 책임이 섞이기 시작하면 먼저 분리 방향을 검토한다.
- 300줄을 넘는 파일은 예의주시 대상으로 보고, 책임 혼합이나 빠른 증가가 있을 때만 분리를 검토한다.
- 500줄을 넘는 파일은 생성물이나 명확한 예외가 아니면 실제 분리 대상으로 본다.
- UI, 상태, API 접근, 변환 로직, 스크립트 제어 흐름이 한 파일에 과도하게 섞이지 않도록 한다.
- 세부 기준은 `docs/modes/shared/file-design-rules.md`를 따른다.

## 4.2 UI UX 작업 규칙

- 사용자 대면 UI 작업이면 `docs/modes/ux-ui/ui-ux-product-rules.md`를 반드시 먼저 따른다.
- 작업 대상이 웹이면 `web-ui-quality-guard`, 앱이면 `app-ui-quality-guard` 기준을 적용한다.
- 웹/앱이 아직 불명확하면 `frontend-quality-guard`로 surface를 먼저 정한 뒤 진행한다.
- UI 작업에서도 기능 추가보다 정보 위계, 가독성, 대비, 반응형/안전영역, 조작 용이성을 우선한다.
- 이모지는 제품 UI에 기본값으로 넣지 않는다.

## 5. 보관 폴더 규칙

- 더 이상 쓰지 않거나 수명이 끝난 파일은 바로 삭제하지 말고 `.graveyard/` 아래로 이동한다.
- `.graveyard/`에 들어간 파일은 "언제든 삭제 가능" 상태여야 한다.
- 살아있는 코드가 `.graveyard/` 내용을 참조하면 안 된다.
- `.graveyard/`는 Git 커밋/푸시 대상에서 제외한다.
- `.graveyard/`로 옮기기 전 현재 코드에 영향을 줄 수 없도록 무력화한다.

무력화 규칙:

- 텍스트 파일은 전체 내용을 주석 블록 또는 주석 라인으로 감싼다.
- 주석 개념이 없는 파일은 `.disabled` 같은 비실행 확장자를 붙여 로드되지 않게 한다.
- 설정 파일, 스크립트, 소스 파일은 원본 상태로 `.graveyard/`에 두지 않는다.

권장 구조:

- `.graveyard/files/`: 사용 종료 파일
- `.graveyard/notes/`: 왜 치웠는지 짧은 메모

## 6. 금지 사항

- 근거 없이 대규모 리팩터링하지 않는다.
- 사용자의 기존 의도를 무시하고 스타일을 전면 교체하지 않는다.
- 최소 프로젝트가 아직 닫히지 않았는데 편의성, 확장성, 추상화를 먼저 추가하지 않는다.
- 시크릿, 토큰, 키를 코드나 문서에 직접 기록하지 않는다.
- 실패 원인을 모르는 상태에서 파일을 계속 덧수정하지 않는다.

## 7. 개발 일지 규칙

- 아래 중 하나에 해당하면 `worklogs/`에 기록한다.
- 아키텍처 변경
- 새 규칙 도입
- 장애 수정
- AI가 만든 중요한 추론 또는 가정

기록 항목:

- 무엇을 바꿨는가
- 왜 바꿨는가
- 검증은 어떻게 했는가
- 남은 리스크는 무엇인가

## 8. 토큰 절약 규칙

- 전체 파일을 매번 붙이지 않는다.
- 긴 문서는 필요한 섹션만 참조한다.
- 한 요청에는 하나의 명확한 목표만 준다.
- 리뷰와 구현 요청을 한 번에 섞지 않는다.
- 불필요한 잡담과 반복 설명을 줄인다.
- 문서는 `docs/context-routing.md`와 `scripts/powershell/context/select-context-pack.ps1` 기준으로 필요한 것만 연다.

## 9. 세션 시작 행동

세션 시작 시 AI는 아래 순서로 움직인다.

1. `docs/token-ops-standard.md` 기준을 확인한다.
2. 현재 목표를 한 줄로 재정의한다.
3. `Original Goal`, `MVP Scope`, `Non-Goal`, `Done When`을 적는다.
4. 범용 작업이면 `Generic Requirement`, `Stop If`를 적는다.
5. 관련 파일만 읽는다.
6. 변경 계획을 짧게 제시한다.
7. 항상 최소 MVP 범위부터 수정한다.
8. 검증한다.
9. 필요하면 개발 일지에 남긴다.

## 10. 세션 종료 행동

- 변경 파일 요약
- 검증 결과
- Original Goal 충족 여부
- MVP Scope 충족 여부
- Generic Requirement 충족 여부
- 왜 지금 멈춰도 되는지
- 다음 작업 추천 1~3개
- 아직 확인되지 않은 리스크

## 11. Mode Docs Structure Rule

- Docs primarily used by a skill or mode must live under `docs/modes/<mode>/`.
- Docs reused by multiple skills or modes must live under `docs/modes/shared/`.
- When moving such docs, update all references in skills, templates, scripts, and worklogs in the same change.
