$scriptPath = Join-Path $PSScriptRoot '..\\..\\skill-minimum-goal.ps1'
& $scriptPath @args
exit $LASTEXITCODE

