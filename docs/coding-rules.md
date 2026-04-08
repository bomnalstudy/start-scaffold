# Coding Rules

이 문서는 이 스캐폴드의 기본 코딩 규칙입니다.

목표는 "예쁘게 보이는 코드"가 아니라 아래 4가지를 지키는 것입니다.

- 파일을 빨리 찾을 수 있어야 한다
- 변경 영향 범위를 좁게 유지해야 한다
- AI가 한 번에 과도한 수정을 하지 못하게 해야 한다
- 다음 세션에서도 구조를 쉽게 이해할 수 있어야 한다

## 결론 먼저

지금 제안한 방식은 전체적으로 좋은 편입니다.

특히 아래는 실무적으로도 많이 쓰이는 방향입니다.

- 큰 파일을 쪼개는 것
- 로직을 사용처 근처에 colocate 하는 것
- 공용 로직을 별도 폴더로 분리하는 것
- 컴포넌트별 스타일 파일을 분리하는 것
- inline CSS를 기본 금지하는 것

다만 몇 가지는 조금 다듬는 편이 더 좋습니다.

- `500줄 미만`은 좋은 상한선이지만 절대 규칙보다는 "소프트 리밋 + 예외 허용"이 좋습니다.
- `utils`는 편하지만 금방 잡동사니 폴더가 되기 쉬워서 기준을 둬야 합니다.
- 공용 로직은 가능하면 `utils` 안에서도 목적별로 나누는 편이 좋습니다.

## 1. 파일 크기 규칙

- 일반 소스 파일은 500줄을 넘기지 않습니다.
- 권장 길이는 300줄 이하입니다.
- 500줄에 가까워지면 로직, UI, 상태, API, 타입, 스타일을 분리합니다.
- 자동 생성 파일, 스키마 파일, 아이콘 맵 같은 예외는 허용할 수 있습니다.

왜 좋은가:

- AI가 한 번에 과도한 수정 범위를 잡기 어려워집니다.
- 리뷰와 디버깅이 쉬워집니다.
- "한 파일에 다 몰아넣는" 구조 붕괴를 막기 좋습니다.

주의:

- 줄 수만 줄인다고 좋은 구조가 되지는 않습니다.
- 관련 없는 파일 분리는 오히려 탐색 비용을 높일 수 있습니다.

## 2. 폴더 구조 규칙

### 기본 원칙

- 파일은 "종류"보다 "사용처" 기준으로 먼저 묶습니다.
- 즉, `components`, `hooks`, `services`만 일괄로 쌓기보다 기능/화면/컴포넌트 중심으로 colocate 합니다.
- 여러 군데에서 재사용되는 로직만 공용 폴더로 올립니다.

이 방향은 Next.js의 colocation 철학과 잘 맞습니다. Next.js 공식 문서도 프로젝트 파일을 라우트 세그먼트 근처에 안전하게 colocate 할 수 있다고 설명합니다.

### 권장 구조 예시

```text
src/
  app/
  components/
    Button/
      Button.tsx
      Button.module.css
      useButtonState.ts
      button.types.ts
  screens/
    Home/
      HomeScreen.tsx
      HomeScreen.module.css
      HomeHero.tsx
      useHomeData.ts
  features/
    auth/
      components/
      hooks/
      api/
      utils/
      types/
  utils/
    date/
      formatDate.ts
    string/
      truncateText.ts
```

### 언제 colocate 하나

- 한 화면에서만 쓰는 훅
- 한 컴포넌트 전용 스타일
- 특정 기능 내부에서만 쓰는 API 헬퍼
- 해당 기능 전용 타입과 상수

### 언제 공용 폴더로 올리나

- 2곳 이상에서 반복 사용
- 특정 기능이 아닌 전역 규칙에 가까움
- UI 공용 컴포넌트
- 앱 전역 유틸 함수

## 3. `utils` 규칙

`utils`를 쓰는 건 괜찮습니다. 다만 아무 함수나 다 넣으면 제일 먼저 망가지는 폴더도 `utils`입니다.

그래서 아래 기준을 권장합니다.

- `utils`에는 "여러 군데에서 반복 사용되는 순수 함수" 위주로 둡니다.
- 상태를 직접 바꾸거나 네트워크 요청을 하는 로직은 `utils`에 두지 않습니다.
- 도메인 로직은 가능하면 해당 feature 안에 두고, 진짜 공용일 때만 `utils`로 올립니다.
- `utils/index.ts`에 전부 재수출해서 거대한 진입점을 만들지 않습니다.
- `utils` 안에서도 `date`, `string`, `number`, `dom`처럼 목적별로 나눕니다.

## 4. 컴포넌트 규칙

- 한 파일에는 하나의 주요 컴포넌트만 둡니다.
- 작은 내부 보조 컴포넌트는 같은 파일에 둘 수 있지만, 재사용되면 분리합니다.
- 컴포넌트는 가능한 한 UI 표현에 집중시키고, 복잡한 상태/부수효과는 커스텀 훅이나 별도 로직 파일로 뺍니다.
- 커스텀 훅 이름은 항상 `use`로 시작합니다.

이 방향은 Airbnb React 스타일 가이드의 "한 파일에 하나의 React 컴포넌트" 원칙과도 맞고, React 공식 문서의 커스텀 훅 분리 패턴과도 맞습니다.

## 5. 스타일 규칙

- inline CSS는 금지합니다.
- 각 컴포넌트나 화면 폴더에 스타일 파일을 따로 둡니다.
- React/Next 계열에서는 기본값으로 CSS Modules를 권장합니다.
- 전역 스타일은 리셋, 토큰, 레이아웃 기반 정도로만 제한합니다.

왜 inline CSS를 피하나:

- 스타일 재사용과 검색이 어렵습니다.
- 조건부 스타일이 늘어날수록 JSX가 금방 지저분해집니다.
- 디자인 수정 시 영향 범위를 추적하기 어렵습니다.

왜 CSS Modules가 좋은가:

- 클래스 충돌을 줄입니다.
- 컴포넌트 단위 스타일 관리가 쉽습니다.
- 파일 colocate 방식과 잘 맞습니다.

## 6. 추천 운영 규칙

### 프론트엔드 기본

- 컴포넌트 폴더마다 `ComponentName.tsx` + `ComponentName.module.css`를 기본으로 둡니다.
- 상태 로직이 복잡해지면 `useComponentName.ts`로 분리합니다.
- 타입이 많아지면 `component.types.ts` 또는 `types.ts`로 분리합니다.

### 기능 단위 기본

- `features/<feature-name>/components`
- `features/<feature-name>/hooks`
- `features/<feature-name>/api`
- `features/<feature-name>/utils`
- `features/<feature-name>/types`

### 공용 기본

- `components/`: 범용 UI
- `utils/`: 순수 공용 함수
- `styles/`: 토큰, reset, globals

## 7. 이 규칙의 장단점

### 장점

- 파일 찾기가 쉽습니다.
- AI가 문맥을 잃고 과도하게 손대기 어려워집니다.
- 기능별 경계가 분명해집니다.
- 스타일과 로직이 사용처 근처에 있어 유지보수가 쉽습니다.

### 단점

- 너무 잘게 쪼개면 파일 이동이 잦아집니다.
- 작은 프로젝트에서는 구조가 과할 수 있습니다.
- `utils`, `shared`, `common`은 규칙이 약하면 금방 비대해집니다.

## 8. 최종 권장안

당신이 제안한 규칙은 유지하되, 아래처럼 살짝 보정하는 것을 추천합니다.

- 파일 500줄 제한: 유지
- 실무 권장선: 300줄 안팎
- 구조 기준: 사용처 colocate 우선
- 공용 로직: `utils`에 넣되 목적별 하위 폴더로 분리
- 스타일: inline CSS 금지, 컴포넌트/스크린 폴더 내부 CSS Module 사용
- 컴포넌트: 한 파일 하나의 주요 컴포넌트 원칙
- 복잡한 로직: 커스텀 훅 또는 feature 내부 로직 파일로 분리

## 9. 참고 기준

이 문서는 아래 자료를 참고해 정리했습니다.

- React 공식 문서: 컴포넌트와 훅은 순수해야 하며, 반복 로직은 커스텀 훅으로 분리하는 방향을 권장
- Next.js 공식 문서: 프로젝트 파일의 colocation과 private folder 패턴을 지원
- Next.js 공식 문서: CSS Modules는 컴포넌트 단위 스타일링에 적합
- Airbnb React Style Guide: 한 파일에 하나의 React 컴포넌트 원칙
- `alan2207/bulletproof-react`: feature 경계와 확장 가능한 구조를 중시하는 대표 오픈소스 아키텍처 예시

## 10. 이 스캐폴드의 기본 규칙으로 채택

이 프로젝트에서는 아래를 기본값으로 채택합니다.

- 소스 파일은 500줄 초과 금지
- 로직은 사용처 기준으로 colocate
- 공용 순수 함수는 `utils/`에 저장
- `utils/`는 목적별 하위 폴더로 분리
- inline CSS 금지
- 컴포넌트/화면별 CSS 파일 분리
- 가능하면 CSS Modules 사용

## 11. 자동 검사

이 규칙은 문서로만 두지 않고 오케스트레이터로 점검합니다.

실행:

```powershell
.\scripts\run-orchestration.ps1 -Pipeline code-rules
```

현재 자동 검사 범위:

- 파일 줄 수 초과
- inline style 사용
- `.graveyard/` 참조
- 과도한 `utils/index` 재수출
- 일반 `.css` 파일 사용 경고
