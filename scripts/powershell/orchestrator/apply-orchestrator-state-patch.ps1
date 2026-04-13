$scriptPath = Join-Path $PSScriptRoot '..\\..\\apply-orchestrator-state-patch.ps1'
& $scriptPath @args
exit $LASTEXITCODE

