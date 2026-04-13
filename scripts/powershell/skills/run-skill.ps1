$scriptPath = Join-Path $PSScriptRoot '..\\..\\run-skill.ps1'
& $scriptPath @args
exit $LASTEXITCODE

