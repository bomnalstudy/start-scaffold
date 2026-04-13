$scriptPath = Join-Path $PSScriptRoot '..\\..\\export-project-secrets.ps1'
& $scriptPath @args
exit $LASTEXITCODE

