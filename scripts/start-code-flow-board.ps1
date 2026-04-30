[CmdletBinding()]
param(
    [string]$TargetRoot = (Split-Path -Parent $PSScriptRoot),
    [int]$Port = 5179,
    [Parameter(Mandatory = $true)]
    [string]$AiCommand,
    [string]$DescriptionLanguage = "ko",
    [int]$DescriptionMaxComponents = 24
)

$ErrorActionPreference = "Stop"

$scaffoldRoot = Split-Path -Parent $PSScriptRoot
$resolvedTarget = (Resolve-Path -LiteralPath $TargetRoot).Path

$env:CODE_FLOW_ROOT = $resolvedTarget
$env:CODE_FLOW_PORT = [string]$Port
$env:CODE_FLOW_AI_COMMAND = $AiCommand
$env:CODE_FLOW_DESCRIPTION_LANG = $DescriptionLanguage
$env:CODE_FLOW_DESCRIPTION_MAX = [string]$DescriptionMaxComponents

Write-Host "Code Flow Board"
Write-Host "TargetRoot: $resolvedTarget"
Write-Host "URL: http://127.0.0.1:$Port"
if ($AiCommand) {
    Write-Host "AI descriptions: enabled"
}

Push-Location $scaffoldRoot
try {
    npm run flow:dev
}
finally {
    Pop-Location
}
