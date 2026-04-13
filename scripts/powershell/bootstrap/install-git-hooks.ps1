$scriptPath = Join-Path $PSScriptRoot '..\\..\\install-git-hooks.ps1'
& $scriptPath @args
exit $LASTEXITCODE

