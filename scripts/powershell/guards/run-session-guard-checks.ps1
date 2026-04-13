$scriptPath = Join-Path $PSScriptRoot '..\\..\\run-session-guard-checks.ps1'
& $scriptPath @args
exit $LASTEXITCODE

