$scriptPath = Join-Path $PSScriptRoot '..\\..\\run-harness-checks.ps1'
& $scriptPath @args
exit $LASTEXITCODE

