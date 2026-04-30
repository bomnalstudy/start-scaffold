window.CODE_FLOW_SUMMARIES = {
  role(role, lang) {
    const ko = {
      automation: "반복 실행, 검사, 생성 작업을 맡는 자동화 영역입니다.",
      backend: "요청 처리와 서버 쪽 기능을 담당하는 영역입니다.",
      config: "도구와 실행 환경의 설정값을 관리합니다.",
      core: "프로젝트의 핵심 규칙이나 공용 동작이 모이는 영역입니다.",
      database: "데이터 구조, 저장소, 스키마와 가까운 영역입니다.",
      docs: "프로젝트 의도, 규칙, 사용법을 설명하는 문서 영역입니다.",
      orchestration: "작업 순서, 상태 전달, 에이전트 흐름을 조율합니다.",
      security: "시크릿, 인증, 권한, 안전한 기본값을 다룹니다.",
      ui: "사용자가 보는 화면과 상호작용을 담당합니다.",
      verification: "테스트, 하네스, 검증 조건을 담당합니다.",
    };
    const en = {
      automation: "Runs repeatable scripts, checks, and generation tasks.",
      backend: "Handles server-side request and feature behavior.",
      config: "Keeps tool and runtime configuration.",
      core: "Holds central project rules or shared behavior.",
      database: "Stays close to data structures, storage, and schema.",
      docs: "Explains project intent, rules, and usage.",
      orchestration: "Coordinates task order, state handoff, and agent flow.",
      security: "Covers secrets, auth, permissions, and safer defaults.",
      ui: "Owns user-facing screens and interactions.",
      verification: "Owns tests, harnesses, and validation rules.",
    };
    return (lang === "ko" ? ko : en)[role] || "";
  },

  file(path, lang) {
    const lower = path.toLowerCase();
    if (lower.endsWith(".md")) return lang === "ko" ? "설명과 운영 기준을 담은 문서입니다." : "Documentation for rules, intent, or usage.";
    if (lower.endsWith(".css")) return lang === "ko" ? "화면의 배치와 시각 스타일을 정의합니다." : "Defines layout and visual styling.";
    if (lower.endsWith(".html")) return lang === "ko" ? "브라우저에서 열리는 화면 진입점입니다." : "Browser entrypoint for the screen.";
    if (lower.endsWith(".js")) return lang === "ko" ? "브라우저 동작이나 데이터 렌더링을 제어합니다." : "Controls browser behavior or data rendering.";
    if (lower.endsWith(".py")) return lang === "ko" ? "분석, 변환, 검사 같은 스크립트 로직입니다." : "Script logic for analysis, conversion, or checks.";
    if (lower.endsWith(".ps1") || lower.endsWith(".sh")) return lang === "ko" ? "명령 실행을 위한 스크립트 진입점입니다." : "Command entrypoint script.";
    if (lower.endsWith(".json")) return lang === "ko" ? "구조화된 설정 또는 생성 데이터입니다." : "Structured config or generated data.";
    return lang === "ko" ? "프로젝트 구성에 포함된 소스 파일입니다." : "Source file in the project structure.";
  },
};
