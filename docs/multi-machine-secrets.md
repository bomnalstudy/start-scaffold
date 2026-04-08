# Multi-Machine Secrets

이 스캐폴드는 프로젝트별 시크릿을 로컬 평문 파일로 관리하면서도, 다른 컴퓨터로 옮길 때는 암호화 번들로 전달할 수 있게 설계되어 있습니다.

## 기본 파일

- `.local/project.secrets.env`: 로컬 평문 시크릿. Git 제외.
- `handoff/project-secrets.enc.json`: 이동용 암호화 번들. 기본적으로 Git 제외.
- `templates/.env.local.example`: 필요한 키 예시.

## 권장 흐름

1. 현재 PC에서 `.local/project.secrets.env`를 관리합니다.
2. 다른 PC로 옮겨야 할 때만 암호화 번들을 생성합니다.
3. 전달은 메신저보다 안전한 저장소나 직접 이동을 권장합니다.
4. 대상 PC에서 복호화 후 로컬 시크릿 파일로 복원합니다.

## 보안 원칙

- 평문 시크릿은 저장소에 커밋하지 않습니다.
- 암호화 번들과 암호는 같은 채널로 보내지 않습니다.
- 프로젝트별로 서로 다른 암호를 쓰는 것이 좋습니다.
- 공유가 끝난 번들은 삭제합니다.

## 스크립트 개요

- `scripts\export-project-secrets.ps1`: 로컬 `.env` 형식 파일을 암호화 번들로 내보냅니다.
- `scripts\import-project-secrets.ps1`: 암호화 번들을 복호화해 로컬 시크릿 파일로 복원합니다.
- `scripts\load-project-secrets.ps1`: 로컬 시크릿 파일을 현재 PowerShell 세션 환경변수로 적재합니다.

## 주의

이 방식은 Doppler 같은 중앙 관리형 서비스의 대체재가 아니라, 프로젝트 단위 이동성과 분리 보관을 위한 경량 로컬 운영 방식입니다.
