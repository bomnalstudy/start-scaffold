$scriptPath = Join-Path $PSScriptRoot '..\\..\\skill-claude.ps1'
& $scriptPath @args
exit $LASTEXITCODE

