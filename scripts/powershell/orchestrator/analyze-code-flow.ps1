$scriptPath = Join-Path $PSScriptRoot '..\..\analyze-code-flow.ps1'
& $scriptPath @args
exit $LASTEXITCODE
