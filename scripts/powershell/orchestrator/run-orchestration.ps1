$scriptPath = Join-Path $PSScriptRoot '..\\..\\run-orchestration.ps1'
& $scriptPath @args
exit $LASTEXITCODE

