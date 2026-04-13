[CmdletBinding()]
param(
    [ValidateSet("codex", "claude")]
    [string]$Agent = "codex",

    [ValidateSet("start", "checkpoint", "close")]
    [string]$Stage = "start",

    [string]$TaskName = "",

    [ValidateSet("start", "implement", "bugfix", "review", "orchestration", "secrets", "token-audit")]
    [string]$Pack = "start",

    [string]$PlanPath = "",
    [string]$WorklogPath = "",
    [switch]$PrintPromptOnly
)

$scriptsRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$runtimeHelpers = Join-Path $scriptsRoot "shared\runtime-context.helpers.ps1"
. $runtimeHelpers

$runtimeContext = Get-RuntimeContext -Agent $Agent
Write-RuntimeContextBanner -Context $runtimeContext
Write-Host ""

$runner = Join-Path $PSScriptRoot "run-skill.ps1"
& $runner -Agent $Agent -Stage $Stage -TaskName $TaskName -Pack $Pack -PlanPath $PlanPath -WorklogPath $WorklogPath -PrintPromptOnly:$PrintPromptOnly
exit $LASTEXITCODE
