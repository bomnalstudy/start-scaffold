[CmdletBinding()]
param(
    [ValidateSet("host-wrapper-dry-run", "stale-snapshot-reject", "all")]
    [string]$Scenario = "all",

    [string]$Root = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Write-HarnessResult {
    param(
        [string]$ScenarioName,
        [string]$Step,
        [string]$Expected,
        [string]$Actual,
        [bool]$Passed
    )

    $status = if ($Passed) { "PASS" } else { "FAIL" }
    Write-Host "[$status] Scenario=$ScenarioName Step=$Step"
    if (-not $Passed) {
        Write-Host "  Expected: $Expected"
        Write-Host "  Actual:   $Actual"
    }
}

function Assert-Equal {
    param(
        [string]$ScenarioName,
        [string]$Step,
        $Expected,
        $Actual
    )

    $passed = ($Expected -eq $Actual)
    Write-HarnessResult -ScenarioName $ScenarioName -Step $Step -Expected "$Expected" -Actual "$Actual" -Passed $passed
    if (-not $passed) {
        throw "Harness assertion failed for $ScenarioName at $Step"
    }
}

function Invoke-HostWrapperDryRunScenario {
    $scenarioName = "harness.host-wrapper-dry-run.v1.yaml"
    $payloadPath = Join-Path $Root "tmp-harness-host-payload.json"

    try {
        @'
{"runId":"demo-run","stage":"plan"}
'@ | Set-Content -Path $payloadPath -Encoding UTF8

        $raw = & (Join-Path $PSScriptRoot "invoke-host-wrapper.ps1") -HostKey codex -Action sync-state -PayloadPath $payloadPath -DryRun
        $result = $raw | ConvertFrom-Json

        Assert-Equal -ScenarioName $scenarioName -Step "success" -Expected $true -Actual ([bool]$result.success)
        Assert-Equal -ScenarioName $scenarioName -Step "status" -Expected "dry-run" -Actual ([string]$result.status)
        Assert-Equal -ScenarioName $scenarioName -Step "host.key" -Expected "codex" -Actual ([string]$result.host.key)
        Assert-Equal -ScenarioName $scenarioName -Step "payload.meta.normalizedHost" -Expected "codex" -Actual ([string]$result.payload.meta.normalizedHost)
    }
    finally {
        if (Test-Path -LiteralPath $payloadPath) {
            Remove-Item -LiteralPath $payloadPath -Force
        }
    }
}

function Invoke-StaleSnapshotRejectScenario {
    $scenarioName = "harness.stale-snapshot-reject.v1.yaml"
    $statePath = Join-Path $Root "tmp-harness-state.json"
    $patchPath = Join-Path $Root "tmp-harness-patch.json"
    $contractPath = Join-Path $Root "templates\orchestrator-state-contract.example.json"

    try {
        @'
{
  "snapshotVersion": "v2",
  "artifactVersion": "v1",
  "runId": "run-20260413-150000",
  "hostTarget": "codex",
  "inputRefs": {
    "userRequest": "docs/scaffold-roadmap.md"
  },
  "stageStatus": {
    "plan": "ready",
    "execute": "pending"
  },
  "workerOutputs": {
    "prompt-orchestrator": {}
  }
}
'@ | Set-Content -Path $statePath -Encoding UTF8

        Copy-Item -LiteralPath (Join-Path $Root "templates\orchestrator-state-patch.example.json") -Destination $patchPath -Force

        $raw = & (Join-Path $PSScriptRoot "apply-orchestrator-state-patch.ps1") -ContractPath $contractPath -StatePath $statePath -PatchPath $patchPath -Owner prompt-orchestrator
        $result = $raw | ConvertFrom-Json

        Assert-Equal -ScenarioName $scenarioName -Step "success" -Expected $false -Actual ([bool]$result.success)
        Assert-Equal -ScenarioName $scenarioName -Step "status" -Expected "rejected-stale-snapshot" -Actual ([string]$result.status)
        Assert-Equal -ScenarioName $scenarioName -Step "error.code" -Expected "stale_snapshot" -Actual ([string]$result.error.code)
        Assert-Equal -ScenarioName $scenarioName -Step "currentSnapshotVersion" -Expected "v2" -Actual ([string]$result.currentSnapshotVersion)
    }
    finally {
        if (Test-Path -LiteralPath $statePath) {
            Remove-Item -LiteralPath $statePath -Force
        }
        if (Test-Path -LiteralPath $patchPath) {
            Remove-Item -LiteralPath $patchPath -Force
        }
    }
}

switch ($Scenario) {
    "host-wrapper-dry-run" {
        Invoke-HostWrapperDryRunScenario
    }
    "stale-snapshot-reject" {
        Invoke-StaleSnapshotRejectScenario
    }
    "all" {
        Invoke-HostWrapperDryRunScenario
        Invoke-StaleSnapshotRejectScenario
    }
}

Write-Host "Harness checks passed."
