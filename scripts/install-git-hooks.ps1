[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$hooksPath = Join-Path $root ".githooks"

if (-not (Test-Path -LiteralPath (Join-Path $root ".git"))) {
    throw "Not a git repository: $root"
}

git config core.hooksPath ".githooks"
if ($LASTEXITCODE -ne 0) {
    throw "Failed to set core.hooksPath"
}

Write-Host "Installed git hooks path: $hooksPath"
Write-Host "pre-commit and pre-push checks are now active."
