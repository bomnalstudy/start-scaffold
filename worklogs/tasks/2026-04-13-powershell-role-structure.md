# 2026-04-13 PowerShell Role Structure

## Original Goal

- PowerShell 스크립트를 역할별 폴더 기준으로 정리한다.

## MVP Scope

- `scripts/powershell/<role>/` 구조를 공식화한다.
- 각 역할 폴더에 README를 추가한다.
- 현재 `scripts/*.ps1` 파일을 역할 맵으로 문서화한다.
- 루트 엔트리포인트는 호환성을 위해 유지한다.

## Non-Goal

- 모든 PowerShell 구현 파일을 한 번에 실제 이동하는 것
- 문서와 훅의 모든 경로를 즉시 재배선하는 것

## Done When

- 역할 폴더가 생긴다.
- 역할별 README와 role map이 생긴다.
- README에 새 구조 기준이 반영된다.

## Stop If

- 실제 파일 대이동이 문서/훅/WSL parity를 동시에 흔들기 시작하면 이번 세션에서는 멈춘다.
- 역할 분류 기준과 탐색 경로가 생기면 구현 이동은 다음 세션으로 넘긴다.
