$scriptPath = Join-Path $PSScriptRoot '..\\..\\hook-pre-push.ps1'
& $scriptPath @args
exit $LASTEXITCODE

