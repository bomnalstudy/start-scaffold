$scriptPath = Join-Path $PSScriptRoot '..\\..\\find-code-refactor-candidates.ps1'
& $scriptPath @args
exit $LASTEXITCODE

