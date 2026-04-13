$scriptPath = Join-Path $PSScriptRoot '..\\..\\debug-orchestrator.ps1'
& $scriptPath @args
exit $LASTEXITCODE

