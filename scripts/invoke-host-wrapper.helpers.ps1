Set-StrictMode -Version Latest

function ConvertTo-NormalizedHashtable {
    param(
        [Parameter(Mandatory)]
        $Value
    )

    if ($null -eq $Value) {
        return $null
    }

    if ($Value -is [System.Collections.IDictionary]) {
        $result = @{}
        foreach ($key in $Value.Keys) {
            $result[$key] = ConvertTo-NormalizedHashtable -Value $Value[$key]
        }
        return $result
    }

    if ($Value -is [System.Collections.IEnumerable] -and -not ($Value -is [string])) {
        $items = @()
        foreach ($item in $Value) {
            $items += ,(ConvertTo-NormalizedHashtable -Value $item)
        }
        return $items
    }

    $properties = @()
    if ($Value.PSObject) {
        $properties = @($Value.PSObject.Properties)
    }

    if ($properties.Count -gt 0 -and -not ($Value -is [string])) {
        $result = @{}
        foreach ($property in $properties) {
            $result[$property.Name] = ConvertTo-NormalizedHashtable -Value $property.Value
        }
        return $result
    }

    return $Value
}

function Resolve-HostTarget {
    param(
        [Parameter(Mandatory)]
        [string]$HostKey
    )

    $normalized = $HostKey.Trim().ToLowerInvariant()

    switch ($normalized) {
        "codex" { return @{ Key = "codex"; Family = "openai"; Adapter = "skill-codex.ps1" } }
        "openai" { return @{ Key = "codex"; Family = "openai"; Adapter = "skill-codex.ps1" } }
        "claude" { return @{ Key = "claude"; Family = "anthropic"; Adapter = "skill-claude.ps1" } }
        "anthropic" { return @{ Key = "claude"; Family = "anthropic"; Adapter = "skill-claude.ps1" } }
        "local" { return @{ Key = "local"; Family = "local"; Adapter = "" } }
        default {
            throw "Unsupported host key '$HostKey'. Supported keys: codex, openai, claude, anthropic, local."
        }
    }
}

function Read-NormalizedPayload {
    param(
        [string]$PayloadJson,
        [string]$PayloadPath
    )

    if ($PayloadJson -and $PayloadPath) {
        throw "Use either PayloadJson or PayloadPath, not both."
    }

    if ($PayloadPath) {
        if (-not (Test-Path -LiteralPath $PayloadPath)) {
            throw "Payload file not found: $PayloadPath"
        }

        $raw = Get-Content -LiteralPath $PayloadPath -Raw -Encoding UTF8
        if ([string]::IsNullOrWhiteSpace($raw)) {
            return @{}
        }

        $parsed = ConvertFrom-Json -InputObject $raw
        return (ConvertTo-NormalizedHashtable -Value $parsed)
    }

    if ($PayloadJson) {
        $parsed = ConvertFrom-Json -InputObject $PayloadJson
        return (ConvertTo-NormalizedHashtable -Value $parsed)
    }

    return @{}
}

function New-InvocationResult {
    param(
        [bool]$Success,
        [hashtable]$HostInfo,
        [string]$Action,
        [hashtable]$Payload,
        [string]$RunId,
        [int]$Attempt,
        [string]$Status,
        [hashtable]$Data,
        [hashtable]$ErrorData
    )

    return [ordered]@{
        success = $Success
        status = $Status
        action = $Action
        runId = $RunId
        attempt = $Attempt
        host = [ordered]@{
            key = $HostInfo.Key
            family = $HostInfo.Family
            adapter = $HostInfo.Adapter
        }
        payload = $Payload
        data = if ($Data) { $Data } else { @{} }
        error = if ($ErrorData) { $ErrorData } else { $null }
        timestamp = (Get-Date).ToString("o")
    }
}

function Write-OrchestratorDebugLog {
    param(
        [Parameter(Mandatory)]
        [string]$LogPath,
        [Parameter(Mandatory)]
        [hashtable]$Entry
    )

    $directory = Split-Path -Parent $LogPath
    if ($directory -and -not (Test-Path -LiteralPath $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    $line = ($Entry | ConvertTo-Json -Depth 10 -Compress)
    Add-Content -LiteralPath $LogPath -Value $line -Encoding UTF8
}
