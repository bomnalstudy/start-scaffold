# Orchestration Patterns

이 문서는 바이브 코딩에서 AI를 "한 번에 다 시키는 방식" 대신 역할과 단계를 나눠 자동화하는 패턴을 정리합니다.

## 목적

- 컨텍스트 낭비를 줄인다
- 작업 실패 지점을 빨리 찾는다
- 큰 작업을 재현 가능한 파이프라인으로 바꾼다
- 프로젝트가 망가지기 전에 중간 검증 지점을 강제한다

## 기본 구조

권장 오케스트레이션 흐름:

1. Intake
2. Plan
3. Execute
4. Verify
5. Log
6. Handoff

각 단계는 서로 다른 책임을 가집니다.

## 역할 분리 패턴

### 1. Planner

역할:

- 요구사항을 작은 작업 단위로 분해
- 영향 범위와 위험도를 분류
- 검증 조건 정의

출력:

- 작업 계획
- 수정 대상 파일 목록
- 완료 기준

언제 쓰나:

- 작업 범위가 2개 이상 모듈에 걸칠 때
- 구현 전에 설계 합의가 필요할 때

### 2. Builder

역할:

- 계획된 범위 안에서만 구현
- 불필요한 확장 없이 최소 수정 수행

출력:

- 코드 변경
- 구현 메모

언제 쓰나:

- 버그 수정
- 기능 추가
- 리팩터링의 실제 실행 단계

### 3. Reviewer

역할:

- 회귀 위험, 누락된 검증, 과도한 변경 감지
- 스타일보다 안정성 중심으로 판단

출력:

- 위험 목록
- 수정 권고

언제 쓰나:

- 인증, 결제, 저장소, 빌드 설정 같은 중위험 이상 변경

### 4. Verifier

역할:

- 테스트, 스모크 체크, 체크리스트 검증
- "되는 것처럼 보이는 코드"를 걸러냄

출력:

- 통과/실패 결과
- 실패 시 재현 정보

### 5. Recorder

역할:

- 개발 일지 기록
- 다음 세션에 필요한 핵심 맥락 보존

출력:

- `worklogs/` 로그
- 남은 TODO

## 추천 오케스트레이션 패턴

### Pattern A. Small Fix Pipeline

대상:

- 단일 버그
- 단일 모듈

흐름:

1. Planner가 원인 후보와 변경 범위를 정의
2. Builder가 최소 수정 수행
3. Verifier가 재현 여부와 테스트를 확인
4. Recorder가 로그를 남김

장점:

- 토큰이 적게 듦
- 빠르게 반복 가능

### Pattern B. Feature Delivery Pipeline

대상:

- 작은 기능 추가
- UI + API 같이 두 영역 이상이 연동되는 작업

흐름:

1. Planner가 기능을 단계별로 분리
2. Builder가 단계별 구현
3. Reviewer가 범위 초과나 설계 붕괴를 점검
4. Verifier가 시나리오 테스트
5. Recorder가 의사결정과 남은 이슈 기록

장점:

- 구현 속도와 안정성의 균형이 좋음

### Pattern C. High-Risk Change Pipeline

대상:

- 인증
- 결제
- 데이터 마이그레이션
- 핵심 설정 변경

흐름:

1. Planner가 롤백 전략 포함 계획 작성
2. Reviewer가 변경 전 계획을 먼저 검토
3. Builder가 작은 배치로 구현
4. Verifier가 하네스 기반으로 핵심 흐름 확인
5. Recorder가 리스크와 후속 작업 기록

장점:

- 프로젝트 붕괴 가능성을 크게 줄임

## 오케스트레이터가 지켜야 할 규칙

- 한 단계의 출력 형식은 고정합니다.
- 다음 단계는 이전 단계의 출력만 보고 움직일 수 있어야 합니다.
- 단계 간 역할 중복을 최소화합니다.
- 실패 시 어느 단계에서 멈췄는지 분명해야 합니다.
- 자동화할수록 로그와 검증을 더 엄격히 둡니다.

## 출력 형식 예시

Planner 출력 예시:

```md
Goal: 로그인 실패 원인 수정
Scope: src/auth.ts, src/session.ts
Risks: 세션 만료 처리 회귀 가능성
Done When:
- 로그인 성공
- 실패 케이스 메시지 유지
- 기존 세션 갱신 로직 정상 동작
```

Verifier 출력 예시:

```md
Checks:
- login success flow: pass
- invalid password flow: pass
- session refresh flow: fail

Notes:
- refresh token 만료 처리에서 기존 동작과 차이 발생
```

## 자동화 우선순위

처음부터 모든 걸 오케스트레이션하지 말고 아래 순서로 키웁니다.

1. 작업 계획 템플릿화
2. 검증 체크리스트 고정
3. 개발 일지 자동 기록
4. 반복 작업 스크립트화
5. 필요 시 역할 분리 자동화

## 하드닝 원칙 (Research-backed)

근거:

- Test Pyramid: https://martinfowler.com/articles/practical-test-pyramid.html
- Airflow Task DAG discipline: https://airflow.apache.org/docs/apache-airflow/2.10.5/core-concepts/tasks.html
- OpenAI eval practices: https://platform.openai.com/docs/guides/evaluation-best-practices

적용:

- 단계 의존성(선행/후행)을 명시한다.
- 각 단계의 실패/재시도/중단 조건을 명시한다.
- 고비용 단계(예: E2E)는 최소화하고 저비용 검사를 먼저 수행한다.
- 종료 시 다음 세션 재현을 위한 로그를 남긴다.

## 현재 스캐폴드 기본 오케스트레이터

이 스캐폴드는 현재 아래 파이프라인을 기본 제공합니다.

### `code-rules`

목적:

- 코딩 기본 규칙 위반을 빠르게 발견

실행:

```powershell
.\scripts\run-orchestration.ps1 -Pipeline code-rules
```

현재 포함 검사:

- 파일 500줄 초과
- 300줄 초과 경고
- JSX/TSX/JS/TS inline style 감지
- `.graveyard/` 참조 감지
- 과도한 `utils/index` barrel 경고
- `.module.css`가 아닌 일반 CSS 경고

### `token-ops`

목적:

- 작업 계획이 토큰 절약형 최소 실행 기준을 만족하는지 확인

실행:

```powershell
.\scripts\run-orchestration.ps1 -Pipeline token-ops -PlanPath templates/orchestration-plan.md
```

현재 포함 검사:

- `Original Goal` 섹션 존재/내용
- `MVP Scope` 섹션 존재/내용
- `Non-Goal` 섹션 존재/내용
- `Done When` 섹션 존재/내용
- `Stop If` 섹션 존재/내용

### `all`

목적:

- token-ops + code-rules를 한 번에 검증

실행:

```powershell
.\scripts\run-orchestration.ps1 -Pipeline all -PlanPath templates/orchestration-plan.md
```

향후 추가 우선순위:

- `Original Goal`, `Non-Goal`, `Done When` 존재 여부 검사
- 범용 작업 시 `Generic Requirement`, `Stop If` 존재 여부 검사
- 완료 보고에 "왜 여기서 멈춰도 되는지"가 있는지 검사
- 테스트 전용 하드코딩 경고

## 토큰 절약 팁

- Planner 단계에서는 코드 전체 대신 구조와 관련 파일만 전달
- Builder 단계에서는 계획과 수정 대상 파일만 전달
- Reviewer 단계에서는 diff와 핵심 파일만 전달
- Verifier 단계에서는 실행 결과와 실패 로그만 전달
