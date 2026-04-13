$scriptPath = Join-Path $PSScriptRoot '..\\..\\run-token-ops-checks.ps1'
& $scriptPath @args
exit $LASTEXITCODE

