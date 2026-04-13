$scriptPath = Join-Path $PSScriptRoot '..\\..\\build-project-context.ps1'
& $scriptPath @args
exit $LASTEXITCODE

