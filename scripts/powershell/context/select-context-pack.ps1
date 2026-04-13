[CmdletBinding()]
param(
    [ValidateSet("codex", "claude")]
    [string]$Agent = "codex",

    [ValidateSet("start", "implement", "bugfix", "review", "orchestration", "secrets", "token-audit")]
    [string]$Pack = "implement",

    [switch]$AsPromptBlock
)

$scriptsRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$root = Split-Path -Parent $scriptsRoot
$runtimeHelpers = Join-Path $scriptsRoot "shared\runtime-context.helpers.ps1"
. $runtimeHelpers

$configPath = Join-Path $root "docs\context-packs.json"

if (-not (Test-Path -LiteralPath $configPath)) {
    throw "Context pack config not found: $configPath"
}

$config = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json

$selected = New-Object System.Collections.Generic.List[string]

foreach ($p in $config.base) {
    $selected.Add([string]$p)
}

foreach ($p in $config.agent_adapters.$Agent) {
    $selected.Add([string]$p)
}

foreach ($p in $config.packs.$Pack) {
    $selected.Add([string]$p)
}

$deduped = New-Object System.Collections.Generic.List[string]
$seen = @{}
foreach ($p in $selected) {
    if (-not $seen.ContainsKey($p)) {
        $seen[$p] = $true
        $deduped.Add($p)
    }
}

$runtimeContext = Get-RuntimeContext -Agent $Agent

if ($AsPromptBlock) {
    Write-Host "Use the following context only:"
    Write-Host "- runtime.platform: $($runtimeContext.platform)"
    Write-Host "- runtime.isWsl: $($runtimeContext.isWsl)"
    Write-Host "- runtime.environmentPattern: $($runtimeContext.environmentPattern)"
    foreach ($p in $deduped) {
        Write-Host "- $p"
    }
    Write-Host ""
    Write-Host "Do not load unrelated docs unless blocked."
    exit 0
}

Write-Host "Context Pack Selection"
Write-Host "Agent: $Agent"
Write-Host "Pack: $Pack"
Write-Host "Platform: $($runtimeContext.platform)"
Write-Host "WSL: $($runtimeContext.isWsl)"
Write-Host "Environment Pattern: $($runtimeContext.environmentPattern)"
Write-Host ""
Write-Host "Open these files in order:"

$idx = 1
foreach ($p in $deduped) {
    Write-Host "$idx. $p"
    $idx++
}
