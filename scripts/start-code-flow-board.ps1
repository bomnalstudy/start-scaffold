[CmdletBinding()]
param(
    [string]$TargetRoot = (Split-Path -Parent $PSScriptRoot),
    [int]$Port = 5179,
    [Parameter(Mandatory = $true)]
    [string]$AiCommand,
    [string]$Language = "ko",
    [int]$MaxComponents = 0,
    [int]$MaxFilesPerComponent = 4,
    [int]$BatchSize = 4
)

$ErrorActionPreference = "Stop"

$scaffoldRoot = Split-Path -Parent $PSScriptRoot
$resolvedTarget = (Resolve-Path -LiteralPath $TargetRoot).Path

$env:CODE_FLOW_ROOT = $resolvedTarget
$env:CODE_FLOW_PORT = [string]$Port
$env:CODE_FLOW_AI_COMMAND = $AiCommand
$env:CODE_FLOW_LANGUAGE = $Language
$env:CODE_FLOW_MAX_COMPONENTS = [string]$MaxComponents
$env:CODE_FLOW_MAX_FILES_PER_COMPONENT = [string]$MaxFilesPerComponent
$env:CODE_FLOW_BATCH_SIZE = [string]$BatchSize

Write-Host "Code Flow Board"
Write-Host "TargetRoot: $resolvedTarget"
Write-Host "URL: http://127.0.0.1:$Port"
if ($AiCommand) {
    Write-Host "AI flow inference: enabled"
}

Push-Location $scaffoldRoot
try {
    npm run flow:dev
}
finally {
    Pop-Location
}
