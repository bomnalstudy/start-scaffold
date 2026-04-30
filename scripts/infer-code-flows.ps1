[CmdletBinding()]
param(
    [string]$Root = (Split-Path -Parent $PSScriptRoot),
    [string]$FlowPath = "docs/generated/code-flow.json",
    [Parameter(Mandatory = $true)]
    [string]$AiCommand,
    [string]$Language = "ko",
    [int]$MaxComponents = 0,
    [int]$MaxFilesPerComponent = 0,
    [int]$BatchSize = 4,
    [int]$TimeoutSeconds = 240
)

$ErrorActionPreference = "Stop"

$scaffoldRoot = Split-Path -Parent $PSScriptRoot
$rootPath = (Resolve-Path -LiteralPath $Root).Path
$scriptPath = Join-Path $scaffoldRoot "scripts/shared/infer_code_flows.py"

$python = Get-Command python -ErrorAction SilentlyContinue
if (-not $python) {
    $python = Get-Command python3 -ErrorAction SilentlyContinue
}
if (-not $python) {
    throw "Python is required to infer code flows."
}

$arguments = @(
    $scriptPath,
    "--root",
    $rootPath,
    "--flow-path",
    $FlowPath,
    "--language",
    $Language,
    "--max-components",
    $MaxComponents,
    "--max-files-per-component",
    $MaxFilesPerComponent,
    "--batch-size",
    $BatchSize,
    "--timeout",
    $TimeoutSeconds,
    "--ai-command",
    $AiCommand
)

& $python.Source @arguments
exit $LASTEXITCODE
