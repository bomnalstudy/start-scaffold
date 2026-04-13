$scriptPath = Join-Path $PSScriptRoot '..\\..\\select-context-pack.ps1'
& $scriptPath @args
exit $LASTEXITCODE

