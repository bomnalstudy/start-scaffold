$scriptPath = Join-Path $PSScriptRoot '..\\..\\run-worklog-checks.ps1'
& $scriptPath @args
exit $LASTEXITCODE

