# Multi-Machine Secrets

이 스캐폴드는 프로젝트별 시크릿을 프로필 단위로 로컬 평문 파일에 관리하면서, Git에는 암호화본만 저장하도록 설계되어 있습니다.

## 기본 파일

- `.local/secrets/<profile>.env`: 로컬 평문 시크릿. Git 제외.
- `secure-secrets/<profile>.vault.json`: Git 저장용 암호화 시크릿 번들.
- `templates/.env.local.example`: 키 템플릿 예시.

## 권장 흐름

1. 현재 PC에서 `.local/secrets/<profile>.env`를 관리합니다.
2. `export-project-secrets.ps1`로 `secure-secrets/<profile>.vault.json`을 갱신합니다.
3. 암호화본만 Git push/pull로 동기화합니다.
4. 다른 PC에서 `import-project-secrets.ps1`로 로컬 평문 파일을 복원합니다.
5. 작업 전 `load-project-secrets.ps1 -Profile <profile>`로 세션에 적재합니다.

## 보안 원칙

- 평문 시크릿은 저장소에 커밋하지 않습니다.
- 암호화본과 암호는 분리된 채널로 관리합니다.
- 프로젝트별로 서로 다른 암호를 쓰는 것이 좋습니다.
- 평문 파일은 절대 메신저로 공유하지 않습니다.

## 스크립트 개요

- `scripts\export-project-secrets.ps1 -Profile <profile>`: 로컬 시크릿 파일을 암호화본으로 내보냅니다.
- `scripts\import-project-secrets.ps1 -Profile <profile>`: 암호화본을 복호화해 로컬 파일로 복원합니다.
- `scripts\load-project-secrets.ps1 -Profile <profile>`: 현재 세션에 환경변수로 적재합니다.
- `scripts\install-git-hooks.ps1`: pre-commit/pre-push 보안 훅을 활성화합니다.

## 주의

이 방식은 중앙 비밀관리 SaaS 없이도 멀티 컴퓨터 개발을 안전하게 유지하기 위한 경량 Git+암호화 모델입니다.

권장 시작:

```powershell
.\scripts\init-project.ps1
.\scripts\install-git-hooks.ps1
.\scripts\export-project-secrets.ps1 -Profile <profile>
```
