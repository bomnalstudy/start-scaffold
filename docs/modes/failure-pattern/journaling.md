# Journaling

개발 일지는 길게 쓰는 문서가 아니라, 다음 세션의 나와 AI가 다시 궤도에 오르기 위한 최소한의 기록입니다.

## 언제 기록하나

- 기능 단위를 마쳤을 때
- 버그 원인을 찾았을 때
- 설계 결정을 내렸을 때
- AI가 만든 가정이 프로젝트에 영향을 줄 때

## 기록 원칙

- 짧고 검색 가능하게 씁니다.
- 감상보다 사실과 판단 근거를 적습니다.
- "무엇을 안 했는지"도 적으면 좋습니다.

## 최소 템플릿

- 날짜/세션
- Original Goal
- MVP Scope(이번 세션)
- Key Changes(핵심 변화)
- 검증 결과
- Mistakes / Drift Signals
- Prevention for Next Session
- Direction Check
- Next Tasks(앞으로의 과제)

핵심:

- "무엇을 바꿨는지"보다 "왜 바꿨는지"를 남깁니다.
- 다음 세션이 같은 실수를 반복하지 않도록 `Prevention`을 씁니다.
- 다음 실행 항목은 `Next Tasks`로 명시합니다.

자동 검사:

```powershell
.\scripts\run-orchestration.ps1 -Pipeline worklog -WorklogPath <worklog-file>
```

## 파일 운영 추천

- `worklogs/2026-04-08-auth-fix.md`
- `worklogs/2026-04-08-build-pipeline.md`

파일명은 날짜와 주제를 함께 넣어 검색성을 높입니다.
