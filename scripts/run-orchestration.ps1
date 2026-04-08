[CmdletBinding()]
param(
    [ValidateSet("code-rules")]
    [string]$Pipeline = "code-rules",

    [string]$Root = (Split-Path -Parent $PSScriptRoot),
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

switch ($Pipeline) {
    "code-rules" {
        Invoke-Stage -Name "Intake" -Action {
            Write-Host "Pipeline: code-rules"
            Write-Host "Root: $Root"
            Write-Host "Goal: verify coding-rules.md and AGENTS.md baseline checks"
        }

        Invoke-Stage -Name "Plan" -Action {
            Write-Host "Checks:"
            Write-Host "- max lines per file"
            Write-Host "- inline style usage"
            Write-Host "- graveyard references"
            Write-Host "- large utils barrel files"
            Write-Host "- non-module css warnings"
        }

        Invoke-Stage -Name "Verify" -Action {
            $checkerPath = Join-Path $PSScriptRoot "run-code-rules-checks.ps1"
            $checkerArgs = @{
                Root = $Root
            }

            if ($EmitJson) {
                $checkerArgs.EmitJson = $true
            }

            & $checkerPath @checkerArgs
            if ($LASTEXITCODE -ne 0) {
                exit $LASTEXITCODE
            }
        }

        Invoke-Stage -Name "Handoff" -Action {
            Write-Host "Next:"
            Write-Host "- fix errors first"
            Write-Host "- decide whether warnings should become project rules"
            Write-Host "- extend checks when a repeated failure pattern appears"
        }
    }
}
