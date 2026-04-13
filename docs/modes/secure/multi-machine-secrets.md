# Multi-Machine Secrets

이 스캐폴드는 프로젝트별 시크릿을 로컬 평문 파일로 관리하고, Git에는 암호화된 번들만 저장하는 경량 워크플로를 사용합니다.

## 기본 파일

- `.local/secrets/<profile>.env`: 로컬 평문 시크릿 파일. Git 제외.
- `secure-secrets/<profile>.vault.json`: Git 저장용 암호화 시크릿 번들.
- `templates/.env.local.example`: 시크릿 키 템플릿 예시.

## 권장 흐름

1. 현재 PC에서 `.local/secrets/<profile>.env`를 관리합니다.
2. `export-project-secrets.ps1`로 `secure-secrets/<profile>.vault.json`을 갱신합니다.
3. 암호화본만 Git push/pull로 동기화합니다.
4. 다른 PC에서는 `import-project-secrets.ps1`로 복호화해 로컬 평문 파일을 복원합니다.
5. 작업 전 `load-project-secrets.ps1 -Profile <profile>`로 현재 세션에 적재합니다.

## 보안 원칙

- 평문 시크릿은 저장소에 커밋하지 않습니다.
- 암호화본과 암호는 분리된 채널로 관리합니다.
- 프로젝트별로 서로 다른 암호를 사용하는 편이 좋습니다.
- 평문 파일은 메신저나 공유 드라이브에 그대로 올리지 않습니다.
- 암호를 잊어버리면 암호화본만으로는 복구할 수 없습니다.

## 암호 재확인 / 분실 대응

- 대화형 `export`에서는 암호를 두 번 입력해 오타를 줄입니다.
- `-Passphrase` 파라미터나 `SECRETS_PASSPHRASE` 환경변수를 사용하는 비대화형 흐름은 그대로 유지됩니다.
- 암호를 잊어버리면 기존 `vault.json`은 복호화하지 않는 정책으로 처리합니다.
- 다음에 시크릿을 다시 정리해 커밋할 때 새 암호를 입력해서 새 번들을 만들면 됩니다.
- 기존 시크릿 값을 다시 알아야 하면 각 값을 다시 수집하거나, 본인이 관리 중인 최신 로컬 시크릿 파일에서 새 번들을 생성합니다.

## 스크립트 개요

- `scripts\export-project-secrets.ps1 -Profile <profile>`: 로컬 시크릿 파일을 암호화본으로 내보냅니다.
- `scripts\import-project-secrets.ps1 -Profile <profile>`: 암호화본을 복호화해 로컬 파일로 복원합니다.
- `scripts\load-project-secrets.ps1 -Profile <profile>`: 현재 세션에 환경변수로 적재합니다.
- `scripts\install-git-hooks.ps1`: pre-commit/pre-push 보안 훅을 설치합니다.

## 주의

이 방식은 중앙 비밀관리 SaaS 없이도 여러 컴퓨터 개발 환경을 안전하게 유지하기 위한 경량 Git+암호화 모델입니다.

권장 시작:

```powershell
.\scripts\init-project.ps1
.\scripts\install-git-hooks.ps1
.\scripts\export-project-secrets.ps1 -Profile <profile>
```
