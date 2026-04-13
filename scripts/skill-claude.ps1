[CmdletBinding()]
param(
    [ValidateSet("start", "checkpoint", "close")]
    [string]$Stage = "start",
    [string]$TaskName = "",
    [ValidateSet("start", "implement", "bugfix", "review", "orchestration", "secrets", "token-audit")]
    [string]$Pack = "start",
    [string]$PlanPath = "",
    [string]$WorklogPath = "",
    [switch]$PrintPromptOnly
)

$runner = Join-Path $PSScriptRoot "skill-minimum-goal.ps1"
& $runner -Agent claude -Stage $Stage -TaskName $TaskName -Pack $Pack -PlanPath $PlanPath -WorklogPath $WorklogPath -PrintPromptOnly:$PrintPromptOnly
exit $LASTEXITCODE
