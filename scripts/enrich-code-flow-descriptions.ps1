[CmdletBinding()]
param(
    [string]$Root = (Split-Path -Parent $PSScriptRoot),
    [string]$FlowPath = "docs/generated/code-flow.json",
    [string]$Language = "ko",
    [int]$MaxComponents = 24,
    [Parameter(Mandatory = $true)]
    [string]$AiCommand,
    [int]$Timeout = 120
)

$ErrorActionPreference = "Stop"

$scaffoldRoot = Split-Path -Parent $PSScriptRoot
$rootPath = (Resolve-Path -LiteralPath $Root).Path
$scriptPath = Join-Path $scaffoldRoot "scripts/shared/enrich_code_flow_descriptions.py"

$python = Get-Command python -ErrorAction SilentlyContinue
if (-not $python) {
    $python = Get-Command python3 -ErrorAction SilentlyContinue
}
if (-not $python) {
    throw "Python is required to enrich code flow descriptions."
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
    "--timeout",
    $Timeout
)

$arguments += "--ai-command"
$arguments += $AiCommand

& $python.Source @arguments
exit $LASTEXITCODE
