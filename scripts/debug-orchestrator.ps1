[CmdletBinding()]
param(
    [string]$Root = (Split-Path -Parent $PSScriptRoot),
    [string]$TaskName = "debug-orchestrator",
    [switch]$KeepFiles
)

$ErrorActionPreference = "Stop"

function Write-Step {
    param([string]$Message)
    Write-Host ""
    Write-Host "== $Message =="
}

function Test-ExitCode {
    param(
        [int]$Actual,
        [int]$Expected,
        [string]$Label
    )

    if ($Actual -ne $Expected) {
        throw "$Label expected exit code $Expected but got $Actual"
    }

    Write-Host "[PASS] $Label (exit=$Actual)"
}

function Set-Section {
    param(
        [string]$Content,
        [string]$Heading,
        [string[]]$Lines
    )

    $replacementBody = ($Lines -join [Environment]::NewLine)
    $replacement = "## $Heading`r`n$replacementBody`r`n"
    $pattern = "(?ms)^##\s+" + [regex]::Escape($Heading) + "\s*\r?\n(.*?)(?=^##\s+|\z)"
    return [regex]::Replace($Content, $pattern, $replacement, 1)
}

$rootPath = (Resolve-Path -LiteralPath $Root).Path
$date = Get-Date -Format "yyyy-MM-dd"
$safeName = ($TaskName.ToLowerInvariant() -replace '[^a-z0-9\-_\s]', '') -replace '\s+', '-'
if (-not $safeName) { $safeName = "debug-orchestrator" }

$taskPath = Join-Path $rootPath "worklogs\tasks\$date-$safeName.md"
$worklogPath = Join-Path $rootPath "worklogs\$date-$safeName-log.md"
$startTaskPath = Join-Path $PSScriptRoot "start-task.ps1"
$guardPath = Join-Path $PSScriptRoot "run-session-guard-checks.ps1"

if (Test-Path -LiteralPath $taskPath) {
    Remove-Item -LiteralPath $taskPath -Force
}
if (Test-Path -LiteralPath $worklogPath) {
    Remove-Item -LiteralPath $worklogPath -Force
}

Write-Step "Case 1: start-task auto gate affects workflow"
& $startTaskPath -TaskName $TaskName -Agent codex -Pack start
$startExit = $LASTEXITCODE
Test-ExitCode -Actual $startExit -Expected 1 -Label "start-task blocks on empty plan via session-guard"

if (-not (Test-Path -LiteralPath $taskPath)) {
    throw "Task file not generated: $taskPath"
}
if (-not (Test-Path -LiteralPath $worklogPath)) {
    throw "Worklog file not generated: $worklogPath"
}
Write-Host "[PASS] task/worklog files generated"

Write-Step "Case 2: fill minimal plan -> preflight should pass"
$taskContent = Get-Content -LiteralPath $taskPath -Raw
$taskContent = Set-Section -Content $taskContent -Heading "Original Goal" -Lines @(
    "- Keep session focused on one minimal deliverable."
)
$taskContent = Set-Section -Content $taskContent -Heading "MVP Scope" -Lines @(
    "- Add session guard checks."
    "- Run preflight and checkpoint validation."
    "- Document debug method."
)
$taskContent = Set-Section -Content $taskContent -Heading "Non-Goal" -Lines @(
    "- No architecture rewrite."
)
$taskContent = Set-Section -Content $taskContent -Heading "Done When" -Lines @(
    "- Guard catches missing required sections."
    "- Guard passes on filled minimal inputs."
)
$taskContent = Set-Section -Content $taskContent -Heading "Stop If" -Lines @(
    "- Scope expands beyond this task."
    "- Validation requires unrelated files."
)
Set-Content -LiteralPath $taskPath -Value $taskContent -Encoding UTF8

& $guardPath -PlanPath $taskPath -Mode preflight
$preflightExit = $LASTEXITCODE
Test-ExitCode -Actual $preflightExit -Expected 0 -Label "session-guard preflight passes on minimal filled plan"

Write-Step "Case 3: checkpoint with empty worklog should fail"
& $guardPath -PlanPath $taskPath -WorklogPath $worklogPath -Mode checkpoint
$checkpointFailExit = $LASTEXITCODE
Test-ExitCode -Actual $checkpointFailExit -Expected 1 -Label "session-guard checkpoint blocks empty worklog"

Write-Step "Case 4: fill required worklog sections -> checkpoint should pass"
$worklogContent = Get-Content -LiteralPath $worklogPath -Raw
$worklogContent = Set-Section -Content $worklogContent -Heading "Original Goal" -Lines @(
    "- Keep objective fixed."
)
$worklogContent = Set-Section -Content $worklogContent -Heading "MVP Scope (This Session)" -Lines @(
    "- Validate guard behavior."
)
$worklogContent = Set-Section -Content $worklogContent -Heading "Key Changes" -Lines @(
    "- Added gate and verified pass/fail cases."
)
$worklogContent = Set-Section -Content $worklogContent -Heading "Validation" -Lines @(
    "- Ran session guard in preflight/checkpoint modes."
)
$worklogContent = Set-Section -Content $worklogContent -Heading "Mistakes / Drift Signals Observed" -Lines @(
    "- Empty plan/worklog immediately caused gate failure."
)
$worklogContent = Set-Section -Content $worklogContent -Heading "Prevention for Next Session" -Lines @(
    "- Fill plan before coding."
    "- Fill worklog before close."
)
$worklogContent = Set-Section -Content $worklogContent -Heading "Direction Check" -Lines @(
    "- This still matches original goal and we can stop now."
    "- Remaining expansion moves to next session."
)
$worklogContent = Set-Section -Content $worklogContent -Heading "Next Tasks" -Lines @(
    "1. Run all pipeline in real task."
    "2. Tune warning thresholds if needed."
)
Set-Content -LiteralPath $worklogPath -Value $worklogContent -Encoding UTF8

& $guardPath -PlanPath $taskPath -WorklogPath $worklogPath -Mode checkpoint
$checkpointPassExit = $LASTEXITCODE
Test-ExitCode -Actual $checkpointPassExit -Expected 0 -Label "session-guard checkpoint passes on filled worklog"

Write-Step "Case 5: close mode validates stop rationale"
& $guardPath -PlanPath $taskPath -WorklogPath $worklogPath -Mode close
$closeExit = $LASTEXITCODE
Test-ExitCode -Actual $closeExit -Expected 0 -Label "session-guard close passes with stop rationale"

Write-Step "Result"
Write-Host "All orchestrator debug cases passed."
Write-Host "Task file: $taskPath"
Write-Host "Worklog file: $worklogPath"

if (-not $KeepFiles) {
    Remove-Item -LiteralPath $taskPath -Force
    Remove-Item -LiteralPath $worklogPath -Force
    Write-Host "Debug files removed. Use -KeepFiles to inspect retained samples."
}
