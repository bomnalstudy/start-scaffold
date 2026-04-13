# 2026-04-13 Native Secrets Format 3

## Original Goal

- `export/import-project-secrets`를 Windows PowerShell과 native WSL/Linux가 같이 쓰는 공용 포맷으로 올린다.

## MVP Scope

- 기본 export 포맷을 `format 3`으로 전환한다.
- PowerShell import가 `format 3`을 읽게 한다.
- WSL native export/import를 `python3 + openssl` 기반으로 바꾼다.
- runtime parity 문서와 secure secrets 문서를 갱신한다.

## Non-Goal

- legacy `format 1`, `format 2`를 native WSL에서 완전 복호화하는 것
- 중앙 시크릿 서비스 연동

## Done When

- PowerShell에서 `format 3` export/import가 동작한다.
- WSL native에서 `format 3` export/import가 동작한다.
- runtime parity roadmap에서 secrets workflow가 `done`으로 올라간다.

## Stop If

- legacy `format 1` / `format 2` native 복호화까지 한 번에 넣으려다 포맷 설계가 과도하게 커지면 이번 세션에서는 멈춘다.
- Windows와 WSL이 같은 `format 3` bundle을 읽고 쓰는 smoke test가 끝나면 추가 추상화 없이 멈춘다.
