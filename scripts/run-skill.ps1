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

$ErrorActionPreference = "Stop"

function Resolve-Root {
    return (Split-Path -Parent $PSScriptRoot)
}

function Get-SafeTaskName {
    param([string]$Name)

    $safe = ($Name.ToLowerInvariant() -replace '[^a-z0-9\-_\s]', '') -replace '\s+', '-'
    if (-not $safe) {
        return "task"
    }
    return $safe
}

function Resolve-DefaultPaths {
    param(
        [string]$Root,
        [string]$TaskName
    )

    $date = Get-Date -Format "yyyy-MM-dd"
    $safe = Get-SafeTaskName -Name $TaskName
    return [pscustomobject]@{
        PlanPath = "worklogs/tasks/$date-$safe.md"
        WorklogPath = "worklogs/$date-$safe-log.md"
    }
}

function Write-PromptBlock {
    param(
        [string]$Agent,
        [string]$Stage,
        [string]$PlanPath,
        [string]$WorklogPath
    )

    Write-Host ""
    Write-Host "=== Skill Prompt Block ($Agent / $Stage) ==="
    Write-Host "Original Goal:"
    Write-Host "MVP Scope:"
    Write-Host "Non-Goal:"
    Write-Host "Done When:"
    Write-Host "Stop If:"
    Write-Host ""
    Write-Host "Plan Path: $PlanPath"
    if ($WorklogPath) {
        Write-Host "Worklog Path: $WorklogPath"
    }
    Write-Host ""
    Write-Host "Request style:"
    Write-Host "- minimum-goal MVP"
    Write-Host "- avoid non-goal changes"
    Write-Host "- stop when Done When is met"
}

$root = Resolve-Root
$startTaskScript = Join-Path $PSScriptRoot "start-task.ps1"
$orchestrationScript = Join-Path $PSScriptRoot "run-orchestration.ps1"
$sessionGuardScript = Join-Path $PSScriptRoot "run-session-guard-checks.ps1"

if ($Stage -eq "start") {
    if ([string]::IsNullOrWhiteSpace($TaskName)) {
        throw "TaskName is required for Stage=start"
    }

    $defaults = Resolve-DefaultPaths -Root $root -TaskName $TaskName
    if ([string]::IsNullOrWhiteSpace($PlanPath)) { $PlanPath = $defaults.PlanPath }
    if ([string]::IsNullOrWhiteSpace($WorklogPath)) { $WorklogPath = $defaults.WorklogPath }

    if (-not $PrintPromptOnly) {
        & $startTaskScript -TaskName $TaskName -Agent $Agent -Pack $Pack
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    }

    Write-PromptBlock -Agent $Agent -Stage $Stage -PlanPath $PlanPath -WorklogPath $WorklogPath
    exit 0
}

if ([string]::IsNullOrWhiteSpace($PlanPath) -or [string]::IsNullOrWhiteSpace($WorklogPath)) {
    throw "PlanPath and WorklogPath are required for Stage=$Stage"
}

if ($Stage -eq "checkpoint") {
    if (-not $PrintPromptOnly) {
        & $orchestrationScript -Pipeline all -PlanPath $PlanPath -WorklogPath $WorklogPath
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    }
    Write-PromptBlock -Agent $Agent -Stage $Stage -PlanPath $PlanPath -WorklogPath $WorklogPath
    exit 0
}

if ($Stage -eq "close") {
    if (-not $PrintPromptOnly) {
        & $sessionGuardScript -PlanPath $PlanPath -WorklogPath $WorklogPath -Mode close
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    }
    Write-PromptBlock -Agent $Agent -Stage $Stage -PlanPath $PlanPath -WorklogPath $WorklogPath
    exit 0
}
