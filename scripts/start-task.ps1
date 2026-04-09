[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$TaskName,

    [ValidateSet("codex", "claude")]
    [string]$Agent = "codex",

    [ValidateSet("start", "implement", "bugfix", "review", "orchestration", "secrets", "token-audit")]
    [string]$Pack = "start"
)

$root = Split-Path -Parent $PSScriptRoot
$templatePath = Join-Path $root "templates\orchestration-plan.md"
$worklogTemplatePath = Join-Path $root "templates\journal-entry.md"
$tasksDir = Join-Path $root "worklogs\tasks"
$worklogsDir = Join-Path $root "worklogs"

if (-not (Test-Path -LiteralPath $templatePath)) {
    throw "Template not found: $templatePath"
}
if (-not (Test-Path -LiteralPath $worklogTemplatePath)) {
    throw "Worklog template not found: $worklogTemplatePath"
}

New-Item -ItemType Directory -Force -Path $tasksDir | Out-Null
New-Item -ItemType Directory -Force -Path $worklogsDir | Out-Null

$safeName = ($TaskName.ToLowerInvariant() -replace '[^a-z0-9\-_\s]', '') -replace '\s+', '-'
if (-not $safeName) {
    $safeName = "task"
}

$date = Get-Date -Format "yyyy-MM-dd"
$taskFile = Join-Path $tasksDir "$date-$safeName.md"
$worklogFile = Join-Path $worklogsDir "$date-$safeName-log.md"

if (-not (Test-Path -LiteralPath $taskFile)) {
    Copy-Item -LiteralPath $templatePath -Destination $taskFile
}
if (-not (Test-Path -LiteralPath $worklogFile)) {
    Copy-Item -LiteralPath $worklogTemplatePath -Destination $worklogFile
}

Write-Host "Task plan file: $taskFile"
Write-Host "Worklog file: $worklogFile"
Write-Host ""

Write-Host "Refreshing project context docs..."
$contextBuilder = Join-Path $PSScriptRoot "build-project-context.ps1"
try {
    & $contextBuilder -Root $root
} catch {
    throw "Failed to generate project context docs. $($_.Exception.Message)"
}
Write-Host ""

$contextPicker = Join-Path $PSScriptRoot "select-context-pack.ps1"
& $contextPicker -Agent $Agent -Pack $Pack

Write-Host ""
Write-Host "Running session-guard preflight for the task plan..."
$sessionGuardChecker = Join-Path $PSScriptRoot "run-session-guard-checks.ps1"
& $sessionGuardChecker -Root $root -PlanPath $taskFile -Mode preflight

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "Task created, but session-guard requirements are incomplete. Fill required sections and rerun checks."
    exit $LASTEXITCODE
}

Write-Host ""
Write-Host "Running token-ops check for the task plan..."
$tokenOpsChecker = Join-Path $PSScriptRoot "run-token-ops-checks.ps1"
& $tokenOpsChecker -Root $root -PlanPath $taskFile

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "Task created, but required fields are incomplete. Fill required sections and rerun checks."
    exit $LASTEXITCODE
}

Write-Host ""
Write-Host "Task is ready. Next:"
Write-Host "1. Fill/verify plan details in the task file."
Write-Host "2. Fill the worklog with key changes, prevention, and next tasks."
Write-Host "3. Run .\scripts\run-orchestration.ps1 -Pipeline all -PlanPath `"$taskFile`" -WorklogPath `"$worklogFile`""
