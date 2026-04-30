[CmdletBinding()]
param(
    [ValidateSet("session-guard", "code-rules", "token-ops", "worklog", "all")]
    [string]$Pipeline = "all",
    [string]$Root = (Split-Path -Parent $PSScriptRoot),
    [string]$PlanPath = "templates/orchestration-plan.md",
    [string]$WorklogPath = "",
    [switch]$SkipCodeFlowMap,
    [switch]$EmitJson
)

$ErrorActionPreference = "Stop"

function Invoke-Stage {
    param(
        [string]$Name,
        [scriptblock]$Action
    )

    Write-Host ""
    Write-Host "== $Name =="
    & $Action
}

function Invoke-Checker {
    param(
        [string]$CheckerFile,
        [string]$CheckerName,
        [hashtable]$CheckerArgs
    )

    $checkerPath = Join-Path $PSScriptRoot $CheckerFile
    & $checkerPath @CheckerArgs
    if ($LASTEXITCODE -ne 0) {
        Write-Host ""
        Write-Host "Pipeline failed at: $CheckerName"
        exit $LASTEXITCODE
    }
}

function Update-CodeFlowMap {
    if ($SkipCodeFlowMap -or $EmitJson) { return }
    $flowScript = Join-Path $PSScriptRoot "analyze-code-flow.ps1"
    if (-not (Test-Path -LiteralPath $flowScript)) {
        Write-Host ""
        Write-Host "Code flow map skipped: analyzer not found."
        return
    }
    Invoke-Stage -Name "Update Code Flow Map" -Action {
        & $flowScript -Root $Root
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Code flow map refresh failed. Pipeline checks already passed; rerun analyzer after fixing the script."
        }
    }
}

switch ($Pipeline) {
    "session-guard" {
        Invoke-Stage -Name "Intake" -Action {
            Write-Host "Pipeline: session-guard"
            Write-Host "Root: $Root"
            Write-Host "PlanPath: $PlanPath"
            if ($WorklogPath) {
                Write-Host "WorklogPath: $WorklogPath"
            }
            Write-Host "Goal: prevent drift by enforcing goal/mvp/stop conditions and direction checks"
        }

        Invoke-Stage -Name "Plan" -Action {
            Write-Host "Checks:"
            Write-Host "- required plan sections are filled"
            Write-Host "- MVP scope is minimal"
            Write-Host "- stop conditions are explicit"
            if ($WorklogPath) {
                Write-Host "- drift signals and prevention are logged"
            }
        }

        Invoke-Stage -Name "Verify" -Action {
            $checkerArgs = @{
                Root = $Root
                PlanPath = $PlanPath
                Mode = if ($WorklogPath) { "checkpoint" } else { "preflight" }
            }

            if ($WorklogPath) {
                $checkerArgs.WorklogPath = $WorklogPath
            }

            if ($EmitJson) {
                $checkerArgs.EmitJson = $true
            }

            Invoke-Checker -CheckerFile "run-session-guard-checks.ps1" -CheckerName "session-guard" -CheckerArgs $checkerArgs
        }

        Invoke-Stage -Name "Handoff" -Action {
            Write-Host "Next:"
            Write-Host "- continue only if original goal and MVP are still aligned"
            Write-Host "- stop and rescope when stop conditions are hit"
            Write-Host "- keep next tasks scoped to the same goal"
        }
    }
    "code-rules" {
        Invoke-Stage -Name "Intake" -Action {
            Write-Host "Pipeline: code-rules"
            Write-Host "Root: $Root"
            Write-Host "Goal: verify coding-rules.md and AGENTS.md baseline checks"
        }

        Invoke-Stage -Name "Plan" -Action {
            Write-Host "Checks:"
            Write-Host "- max lines per file"
            Write-Host "- staged file growth before commit"
            Write-Host "- inline style usage"
            Write-Host "- graveyard references"
            Write-Host "- large utils barrel files"
            Write-Host "- non-module css warnings"
        }

        Invoke-Stage -Name "Verify" -Action {
            $checkerArgs = @{
                Root = $Root
            }

            if ($EmitJson) {
                $checkerArgs.EmitJson = $true
            }

            Invoke-Checker -CheckerFile "run-code-rules-checks.ps1" -CheckerName "code-rules" -CheckerArgs $checkerArgs
        }

        Invoke-Stage -Name "Handoff" -Action {
            Write-Host "Next:"
            Write-Host "- fix errors first"
            Write-Host "- decide whether warnings should become project rules"
            Write-Host "- extend checks when a repeated failure pattern appears"
        }
    }
    "token-ops" {
        Invoke-Stage -Name "Intake" -Action {
            Write-Host "Pipeline: token-ops"
            Write-Host "Root: $Root"
            Write-Host "PlanPath: $PlanPath"
            Write-Host "Goal: verify required task fields for token-efficient scoped execution"
        }

        Invoke-Stage -Name "Plan" -Action {
            Write-Host "Checks:"
            Write-Host "- required sections exist"
            Write-Host "- required sections are not placeholder-only"
            Write-Host "- task is ready for minimal-scope execution"
        }

        Invoke-Stage -Name "Verify" -Action {
            $checkerArgs = @{
                Root = $Root
                PlanPath = $PlanPath
            }

            if ($EmitJson) {
                $checkerArgs.EmitJson = $true
            }

            Invoke-Checker -CheckerFile "run-token-ops-checks.ps1" -CheckerName "token-ops" -CheckerArgs $checkerArgs
        }

        Invoke-Stage -Name "Handoff" -Action {
            Write-Host "Next:"
            Write-Host "- keep only MVP scope in this run"
            Write-Host "- defer non-goals to next iteration"
            Write-Host "- stop once Done When is satisfied"
        }
    }
    "all" {
        Invoke-Stage -Name "Intake" -Action {
            Write-Host "Pipeline: all"
            Write-Host "Root: $Root"
            Write-Host "PlanPath: $PlanPath"
            Write-Host "Goal: enforce token-ops readiness and code-rules quality gate"
        }

        Invoke-Stage -Name "Plan" -Action {
            Write-Host "Checks:"
            Write-Host "- session guard (goal/mvp/stop)"
            Write-Host "- token-ops required fields"
            Write-Host "- code-rules baseline checks"
            if ($WorklogPath) {
                Write-Host "- worklog completion checks"
            }
        }

        Invoke-Stage -Name "Verify Session Guard" -Action {
            $sessionArgs = @{
                Root = $Root
                PlanPath = $PlanPath
                Mode = if ($WorklogPath) { "checkpoint" } else { "preflight" }
            }

            if ($WorklogPath) {
                $sessionArgs.WorklogPath = $WorklogPath
            }

            if ($EmitJson) {
                $sessionArgs.EmitJson = $true
            }

            Invoke-Checker -CheckerFile "run-session-guard-checks.ps1" -CheckerName "session-guard" -CheckerArgs $sessionArgs
        }

        Invoke-Stage -Name "Verify Token Ops" -Action {
            $tokenOpsArgs = @{
                Root = $Root
                PlanPath = $PlanPath
            }

            if ($EmitJson) {
                $tokenOpsArgs.EmitJson = $true
            }

            Invoke-Checker -CheckerFile "run-token-ops-checks.ps1" -CheckerName "token-ops" -CheckerArgs $tokenOpsArgs
        }

        Invoke-Stage -Name "Verify Code Rules" -Action {
            $codeArgs = @{
                Root = $Root
            }

            if ($EmitJson) {
                $codeArgs.EmitJson = $true
            }

            Invoke-Checker -CheckerFile "run-code-rules-checks.ps1" -CheckerName "code-rules" -CheckerArgs $codeArgs
        }

        if ($WorklogPath) {
            Invoke-Stage -Name "Verify Worklog" -Action {
                $worklogArgs = @{
                    Root = $Root
                    WorklogPath = $WorklogPath
                }

                if ($EmitJson) {
                    $worklogArgs.EmitJson = $true
                }

                Invoke-Checker -CheckerFile "run-worklog-checks.ps1" -CheckerName "worklog" -CheckerArgs $worklogArgs
            }
        }

        Invoke-Stage -Name "Handoff" -Action {
            Write-Host "Next:"
            Write-Host "- execute only MVP scope"
            Write-Host "- avoid non-goal changes"
            Write-Host "- stop when Done When is met"
        }
    }
    "worklog" {
        Invoke-Stage -Name "Intake" -Action {
            Write-Host "Pipeline: worklog"
            Write-Host "Root: $Root"
            Write-Host "WorklogPath: $WorklogPath"
            Write-Host "Goal: ensure key changes and next tasks are captured to prevent repeated mistakes"
        }

        Invoke-Stage -Name "Plan" -Action {
            Write-Host "Checks:"
            Write-Host "- required worklog sections exist"
            Write-Host "- key changes are documented"
            Write-Host "- prevention and next tasks are documented"
            Write-Host "- direction alignment is documented"
        }

        Invoke-Stage -Name "Verify" -Action {
            if (-not $WorklogPath) {
                throw "WorklogPath is required for worklog pipeline."
            }

            $checkerArgs = @{
                Root = $Root
                WorklogPath = $WorklogPath
            }

            if ($EmitJson) {
                $checkerArgs.EmitJson = $true
            }

            Invoke-Checker -CheckerFile "run-worklog-checks.ps1" -CheckerName "worklog" -CheckerArgs $checkerArgs
        }

        Invoke-Stage -Name "Handoff" -Action {
            Write-Host "Next:"
            Write-Host "- review mistakes/drift before next run"
            Write-Host "- use prevention notes to avoid repeat failures"
            Write-Host "- execute only next tasks tied to original goal"
        }
    }
}

Update-CodeFlowMap
