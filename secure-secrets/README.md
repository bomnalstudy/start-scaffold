# Secure Secrets

Store encrypted project secret bundles here, one file per profile.

Example:

- `secure-secrets/project-a.vault.json`
- `secure-secrets/project-b.vault.json`

How to create/update:

```powershell
.\scripts\export-project-secrets.ps1 -Profile project-a
```

How to restore on another machine:

```powershell
.\scripts\import-project-secrets.ps1 -Profile project-a
```

Security notes (format 2):

- passphrase key is derived with `PBKDF2-SHA256` + random salt
- encrypted bundle includes `HMAC-SHA256` integrity tag
- modified/tampered bundles fail on import
- interactive export asks for passphrase confirmation
- forgotten passphrases are treated as non-recoverable; create a new vault with a new passphrase on the next export

Never commit `.local/secrets/*.env`.
