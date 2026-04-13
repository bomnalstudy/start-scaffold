$scriptPath = Join-Path $PSScriptRoot '..\\..\\run-code-rules-checks.ps1'
& $scriptPath @args
exit $LASTEXITCODE

