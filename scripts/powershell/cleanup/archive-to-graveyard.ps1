$scriptPath = Join-Path $PSScriptRoot '..\\..\\archive-to-graveyard.ps1'
& $scriptPath @args
exit $LASTEXITCODE

