$scriptPath = Join-Path $PSScriptRoot '..\\..\\hook-pre-commit.ps1'
& $scriptPath @args
exit $LASTEXITCODE

