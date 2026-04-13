$scriptPath = Join-Path $PSScriptRoot '..\\..\\load-project-secrets.ps1'
& $scriptPath @args
exit $LASTEXITCODE

