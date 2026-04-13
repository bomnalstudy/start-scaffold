# Multi-Machine Secrets

여러 개발 환경에서 같은 프로젝트 시크릿을 다뤄야 할 때는 로컬 평문 파일과 Git에 올릴 암호화 번들을 분리합니다.

## 기본 파일

- `.local/secrets/<profile>.env`
  - 현재 머신에서만 쓰는 로컬 평문 시크릿 파일
  - Git 제외 대상
- `secure-secrets/<profile>.vault.json`
  - Git에 올릴 수 있는 암호화 번들
- `templates/.env.local.example`
  - 필요한 키 이름 예시

## 권장 흐름

1. 현재 머신에서 `.local/secrets/<profile>.env`를 관리합니다.
2. `export-project-secrets`로 `secure-secrets/<profile>.vault.json`을 갱신합니다.
3. Git에는 암호화 번들만 공유합니다.
4. 다른 머신에서는 `import-project-secrets`로 로컬 평문 파일을 복원합니다.
5. 작업 직전에는 `load-project-secrets`로 현재 세션에 적재합니다.

## 현재 표준 포맷

- 기본 export 포맷은 `format 3`입니다.
- 구성:
  - `PBKDF2-SHA256`
  - `AES-256-CBC`
  - `HMAC-SHA256`
- 이 포맷은 Windows PowerShell과 `native-wsl-linux` 둘 다에서 사용할 수 있도록 맞춥니다.
- 기존 `format 1`, `format 2` 번들은 PowerShell import에서 계속 읽을 수 있습니다.
- WSL native import는 `format 3`을 기준으로 사용합니다.
  - 오래된 번들은 PowerShell runtime이 있으면 호환 import로 fallback 할 수 있습니다.
  - 그래도 한 번 다시 export 해서 `format 3`으로 올려두는 것을 권장합니다.

## 보안 원칙

- 평문 시크릿 파일은 저장소에 커밋하지 않습니다.
- 번들과 passphrase는 분리해서 전달합니다.
- passphrase를 잃어버리면 기존 번들은 복구하지 않는 방향으로 처리합니다.
- 가능하면 프로젝트마다 다른 passphrase를 씁니다.
- 세션 토큰, API key, 사용자 정보가 로그에 raw로 남지 않게 합니다.

## 실행 예시

PowerShell:

```powershell
.\scripts\export-project-secrets.ps1 -Profile start-scaffold
.\scripts\import-project-secrets.ps1 -Profile start-scaffold
.\scripts\load-project-secrets.ps1 -Profile start-scaffold
```

WSL native:

```bash
./scripts/bash/export-project-secrets.sh --profile start-scaffold --passphrase "<passphrase>"
./scripts/bash/import-project-secrets.sh --profile start-scaffold --passphrase "<passphrase>"
source ./scripts/bash/load-project-secrets.sh --profile start-scaffold
```

## 운영 메모

- 새 표준은 `format 3`이므로, native WSL 사용이 필요하면 기존 vault도 한 번 새로 export 해두는 편이 좋습니다.
- 암호화 번들 포맷을 바꾸는 작업은 아키텍처 변경으로 보고 worklog에 남깁니다.
