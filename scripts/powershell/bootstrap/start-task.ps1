$scriptPath = Join-Path $PSScriptRoot '..\\..\\start-task.ps1'
& $scriptPath @args
exit $LASTEXITCODE

