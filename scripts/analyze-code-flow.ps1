[CmdletBinding()]
param(
    [string]$Root = (Split-Path -Parent $PSScriptRoot),
    [string]$OutputDir = "docs/generated",
    [switch]$EmitJson,
    [int]$MaxComponents = 24,
    [int]$MaxDependencies = 40
)

$ErrorActionPreference = "Stop"

$scaffoldRoot = Split-Path -Parent $PSScriptRoot
$rootPath = (Resolve-Path -LiteralPath $Root).Path
$scriptPath = Join-Path $scaffoldRoot "scripts/shared/analyze_code_flow.py"

$python = Get-Command python -ErrorAction SilentlyContinue
if (-not $python) {
    $python = Get-Command python3 -ErrorAction SilentlyContinue
}
if (-not $python) {
    throw "Python is required to run code flow analysis."
}

$arguments = @(
    $scriptPath,
    "--root",
    $rootPath,
    "--output-dir",
    $OutputDir,
    "--max-components",
    $MaxComponents,
    "--max-dependencies",
    $MaxDependencies
)

if ($EmitJson) {
    $arguments += "--emit-json"
}

& $python.Source @arguments
exit $LASTEXITCODE
