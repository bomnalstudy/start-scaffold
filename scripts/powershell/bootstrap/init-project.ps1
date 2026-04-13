$scriptPath = Join-Path $PSScriptRoot '..\\..\\init-project.ps1'
& $scriptPath @args
exit $LASTEXITCODE

