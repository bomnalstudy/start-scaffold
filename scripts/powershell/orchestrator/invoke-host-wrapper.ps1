$scriptPath = Join-Path $PSScriptRoot '..\\..\\invoke-host-wrapper.ps1'
& $scriptPath @args
exit $LASTEXITCODE

