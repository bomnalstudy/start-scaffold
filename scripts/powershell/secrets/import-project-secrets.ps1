$scriptPath = Join-Path $PSScriptRoot '..\\..\\import-project-secrets.ps1'
& $scriptPath @args
exit $LASTEXITCODE

