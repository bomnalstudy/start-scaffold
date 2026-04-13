$scriptPath = Join-Path $PSScriptRoot '..\\..\\skill-codex.ps1'
& $scriptPath @args
exit $LASTEXITCODE

