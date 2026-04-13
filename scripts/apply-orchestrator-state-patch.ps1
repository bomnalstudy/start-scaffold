[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$ContractPath,

    [Parameter(Mandatory)]
    [string]$StatePath,

    [Parameter(Mandatory)]
    [string]$PatchPath,

    [Parameter(Mandatory)]
    [string]$Owner,

    [string]$DebugLogPath = "",
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

. (Join-Path $PSScriptRoot "powershell\orchestrator\orchestrator-state.helpers.ps1")
. (Join-Path $PSScriptRoot "powershell\orchestrator\invoke-host-wrapper.helpers.ps1")

$contract = Read-StateJson -Path $ContractPath
$state = Read-StateJson -Path $StatePath
$patchDocument = Read-StateJson -Path $PatchPath

if (-not $patchDocument.ContainsKey("snapshotVersion")) {
    throw "Patch must include snapshotVersion."
}

if (-not $patchDocument.ContainsKey("changes")) {
    throw "Patch must include changes."
}

$currentSnapshotVersion = if ($state.ContainsKey("snapshotVersion")) { [string]$state.snapshotVersion } else { "" }
$patchSnapshotVersion = [string]$patchDocument.snapshotVersion
$runId = if ($patchDocument.ContainsKey("runId")) { [string]$patchDocument.runId } else { "run-" + (Get-Date -Format "yyyyMMdd-HHmmss") }
$artifactVersion = if ($state.ContainsKey("artifactVersion")) { [string]$state.artifactVersion } else { "v1" }

function Add-StateDebugEntry {
    param(
        [string]$Status,
        [string]$Message,
        [string]$ErrorCode = "",
        [string[]]$PatchKeys = @()
    )

    if (-not $DebugLogPath) {
        return
    }

    $entry = [ordered]@{
        timestamp = (Get-Date).ToString("o")
        runId = $runId
        stage = "apply-state-patch"
        owner = $Owner
        action = "apply-patch"
        host = if ($state.ContainsKey("hostTarget")) { [string]$state.hostTarget } else { "unknown" }
        status = $Status
        snapshotVersion = $patchSnapshotVersion
        artifactVersion = $artifactVersion
        message = $Message
        patchKeys = $PatchKeys
        inputRefs = @()
        scenarioId = ""
        errorCode = if ($ErrorCode) { $ErrorCode } else { $null }
        details = @{
            currentSnapshotVersion = $currentSnapshotVersion
            dryRun = [bool]$DryRun
        }
    }

    Write-OrchestratorDebugLog -LogPath $DebugLogPath -Entry $entry
}

$changes = ConvertTo-StateHashtable -Value $patchDocument.changes
$patchKeys = @($changes.Keys)

if ($patchSnapshotVersion -ne $currentSnapshotVersion) {
    Add-StateDebugEntry -Status "rejected-stale-snapshot" -Message "Patch rejected because the snapshot version is stale." -ErrorCode "stale_snapshot" -PatchKeys $patchKeys

    [ordered]@{
        success = $false
        status = "rejected-stale-snapshot"
        runId = $runId
        owner = $Owner
        snapshotVersion = $patchSnapshotVersion
        currentSnapshotVersion = $currentSnapshotVersion
        patchKeys = $patchKeys
        error = @{
            code = "stale_snapshot"
            message = "Patch snapshotVersion '$patchSnapshotVersion' does not match current snapshotVersion '$currentSnapshotVersion'."
        }
    } | ConvertTo-Json -Depth 10

    exit 1
}

$allowedPrefixes = @(Get-AllowedPatchPrefixes -Contract $contract -Owner $Owner)
if (@($allowedPrefixes).Count -eq 0) {
    throw "No allowed patch prefixes resolved for owner '$Owner'."
}

foreach ($patchKey in $patchKeys) {
    $fieldPolicy = Get-FieldPolicy -Contract $contract -PatchPath $patchKey
    if ($null -eq $fieldPolicy) {
        Add-StateDebugEntry -Status "rejected-unknown-field-policy" -Message "Patch rejected because the target field is not declared in the state contract." -ErrorCode "unknown_field_policy" -PatchKeys $patchKeys

        [ordered]@{
            success = $false
            status = "rejected-unknown-field-policy"
            runId = $runId
            owner = $Owner
            patchKey = $patchKey
            error = @{
                code = "unknown_field_policy"
                message = "Patch key '$patchKey' does not map to a declared shared field policy."
            }
        } | ConvertTo-Json -Depth 10

        exit 1
    }

    if (-not [bool]$fieldPolicy.mutable) {
        Add-StateDebugEntry -Status "rejected-immutable-field" -Message "Patch rejected because the target field is immutable." -ErrorCode "immutable_field" -PatchKeys $patchKeys

        [ordered]@{
            success = $false
            status = "rejected-immutable-field"
            runId = $runId
            owner = $Owner
            patchKey = $patchKey
            error = @{
                code = "immutable_field"
                message = "Patch key '$patchKey' targets an immutable shared field."
            }
        } | ConvertTo-Json -Depth 10

        exit 1
    }

    if (-not (Test-WriterAllowed -FieldPolicy $fieldPolicy -Owner $Owner)) {
        Add-StateDebugEntry -Status "rejected-writer-policy" -Message "Patch rejected because the writer is not allowed for the target field." -ErrorCode "writer_not_allowed" -PatchKeys $patchKeys

        [ordered]@{
            success = $false
            status = "rejected-writer-policy"
            runId = $runId
            owner = $Owner
            patchKey = $patchKey
            error = @{
                code = "writer_not_allowed"
                message = "Owner '$Owner' is not allowed to write patch key '$patchKey'."
            }
        } | ConvertTo-Json -Depth 10

        exit 1
    }

    if (-not (Test-AllowedPatchKey -AllowedPrefixes $allowedPrefixes -PatchPath $patchKey)) {
        Add-StateDebugEntry -Status "rejected-owner-scope" -Message "Patch rejected because it writes outside the owner's allowed namespace." -ErrorCode "owner_scope_violation" -PatchKeys $patchKeys

        [ordered]@{
            success = $false
            status = "rejected-owner-scope"
            runId = $runId
            owner = $Owner
            patchKey = $patchKey
            allowedPrefixes = $allowedPrefixes
            error = @{
                code = "owner_scope_violation"
                message = "Patch key '$patchKey' is outside the allowed prefixes for owner '$Owner'."
            }
        } | ConvertTo-Json -Depth 10

        exit 1
    }
}

$nextState = ConvertTo-StateHashtable -Value $state
foreach ($patchKey in $patchKeys) {
    Set-NestedValue -Target $nextState -Path $patchKey -Value $changes[$patchKey]
}

$nextVersionNumber = 1
if ($currentSnapshotVersion -match '^v(\d+)$') {
    $nextVersionNumber = [int]$Matches[1] + 1
}
$nextState["snapshotVersion"] = "v$nextVersionNumber"
$nextState["lastUpdatedBy"] = $Owner
$nextState["lastRunId"] = $runId

if ($DryRun) {
    Add-StateDebugEntry -Status "dry-run" -Message "State patch validation passed in dry-run mode." -PatchKeys $patchKeys

    [ordered]@{
        success = $true
        status = "dry-run"
        runId = $runId
        owner = $Owner
        patchKeys = $patchKeys
        currentSnapshotVersion = $currentSnapshotVersion
        nextSnapshotVersion = $nextState.snapshotVersion
        applied = $false
    } | ConvertTo-Json -Depth 10

    exit 0
}

Write-StateJson -Path $StatePath -Value $nextState
Add-StateDebugEntry -Status "applied" -Message "State patch applied successfully." -PatchKeys $patchKeys

[ordered]@{
    success = $true
    status = "applied"
    runId = $runId
    owner = $Owner
    patchKeys = $patchKeys
    currentSnapshotVersion = $currentSnapshotVersion
    nextSnapshotVersion = $nextState.snapshotVersion
    applied = $true
} | ConvertTo-Json -Depth 10
exit 0
