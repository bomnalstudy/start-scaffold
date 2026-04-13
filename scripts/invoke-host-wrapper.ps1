[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$HostKey,

    [Parameter(Mandatory)]
    [string]$Action,

    [string]$PayloadJson = "",
    [string]$PayloadPath = "",
    [string]$RunId = "",
    [int]$TimeoutSeconds = 30,
    [int]$RetryCount = 0,
    [string]$SnapshotVersion = "v1",
    [string]$ArtifactVersion = "v1",
    [string]$Owner = "main-orchestrator",
    [string]$DebugLogPath = "",
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

. (Join-Path $PSScriptRoot "powershell\orchestrator\invoke-host-wrapper.helpers.ps1")

if (-not $RunId) {
    $RunId = "run-" + (Get-Date -Format "yyyyMMdd-HHmmss")
}

if ($TimeoutSeconds -lt 1) {
    throw "TimeoutSeconds must be at least 1."
}

if ($RetryCount -lt 0) {
    throw "RetryCount must be 0 or greater."
}

$hostTarget = Resolve-HostTarget -HostKey $HostKey
$payload = Read-NormalizedPayload -PayloadJson $PayloadJson -PayloadPath $PayloadPath

if (-not $payload.ContainsKey("action")) {
    $payload["action"] = $Action
}

if (-not $payload.ContainsKey("meta")) {
    $payload["meta"] = @{}
}

$payload["meta"]["requestedHost"] = $HostKey
$payload["meta"]["normalizedHost"] = $hostTarget.Key
$payload["meta"]["timeoutSeconds"] = $TimeoutSeconds
$payload["meta"]["retryCount"] = $RetryCount

function Add-DebugEntry {
    param(
        [string]$Status,
        [string]$Message,
        [string]$ErrorCode = "",
        [hashtable]$Details = $null
    )

    if (-not $DebugLogPath) {
        return
    }

    $entry = [ordered]@{
        timestamp = (Get-Date).ToString("o")
        runId = $RunId
        stage = "invoke-host"
        owner = $Owner
        action = $Action
        host = $hostTarget.Key
        status = $Status
        snapshotVersion = $SnapshotVersion
        artifactVersion = $ArtifactVersion
        message = $Message
        patchKeys = @()
        inputRefs = @()
        scenarioId = ""
        errorCode = if ($ErrorCode) { $ErrorCode } else { $null }
        details = if ($Details) { $Details } else { @{} }
    }

    Write-OrchestratorDebugLog -LogPath $DebugLogPath -Entry $entry
}

if ($DryRun) {
    Add-DebugEntry -Status "dry-run" -Message "Host wrapper dry run completed." -Details @{
        adapter = $hostTarget.Adapter
    }

    $result = New-InvocationResult `
        -Success $true `
        -HostInfo $hostTarget `
        -Action $Action `
        -Payload $payload `
        -RunId $RunId `
        -Attempt 0 `
        -Status "dry-run" `
        -Data @{
            message = "Host wrapper dry run completed. This is the normalized invocation contract."
        } `
        -ErrorData $null

    $result | ConvertTo-Json -Depth 10
    exit 0
}

if (-not $hostTarget.Adapter) {
    Add-DebugEntry -Status "not-implemented" -Message "No concrete adapter is registered for the selected host." -ErrorCode "host_adapter_missing"

    $result = New-InvocationResult `
        -Success $false `
        -HostInfo $hostTarget `
        -Action $Action `
        -Payload $payload `
        -RunId $RunId `
        -Attempt 1 `
        -Status "not-implemented" `
        -Data @{} `
        -ErrorData @{
            code = "host_adapter_missing"
            message = "No concrete adapter is registered yet for host '$($hostTarget.Key)'. Use -DryRun until the runtime adapter is implemented."
        }

    $result | ConvertTo-Json -Depth 10
    exit 1
}

$adapterPath = Join-Path $PSScriptRoot $hostTarget.Adapter
Add-DebugEntry -Status "adapter-pending" -Message "Host wrapper normalization succeeded but adapter handoff is still pending." -ErrorCode "adapter_pending" -Details @{
    adapterPath = $adapterPath
}

$result = New-InvocationResult `
    -Success $false `
    -HostInfo $hostTarget `
    -Action $Action `
    -Payload $payload `
    -RunId $RunId `
    -Attempt 1 `
    -Status "adapter-pending" `
    -Data @{
        adapterPath = $adapterPath
    } `
    -ErrorData @{
        code = "adapter_pending"
        message = "Host wrapper normalization succeeded, but the runtime adapter handoff is still pending for action '$Action'."
    }

$result | ConvertTo-Json -Depth 10
exit 1
