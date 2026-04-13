$scriptPath = Join-Path $PSScriptRoot '..\\..\\find-file-refactor-candidates.ps1'
& $scriptPath @args
exit $LASTEXITCODE

