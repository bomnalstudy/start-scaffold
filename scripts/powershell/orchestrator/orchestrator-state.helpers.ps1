Set-StrictMode -Version Latest

function ConvertTo-StateHashtable {
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
            $result[$key] = ConvertTo-StateHashtable -Value $Value[$key]
        }
        return $result
    }

    if ($Value -is [System.Collections.IEnumerable] -and -not ($Value -is [string])) {
        $items = @()
        foreach ($item in $Value) {
            $items += ,(ConvertTo-StateHashtable -Value $item)
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
            $result[$property.Name] = ConvertTo-StateHashtable -Value $property.Value
        }
        return $result
    }

    return $Value
}

function Read-StateJson {
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        throw "State file not found: $Path"
    }

    $raw = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
    if ([string]::IsNullOrWhiteSpace($raw)) {
        return @{}
    }

    $parsed = ConvertFrom-Json -InputObject $raw
    return (ConvertTo-StateHashtable -Value $parsed)
}

function Write-StateJson {
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        [Parameter(Mandatory)]
        [hashtable]$Value
    )

    $directory = Split-Path -Parent $Path
    if ($directory -and -not (Test-Path -LiteralPath $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    $json = $Value | ConvertTo-Json -Depth 20
    Set-Content -LiteralPath $Path -Value $json -Encoding UTF8
}

function Test-HasPathPrefix {
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        [Parameter(Mandatory)]
        [string]$Prefix
    )

    return ($Path -eq $Prefix -or $Path.StartsWith("$Prefix."))
}

function Set-NestedValue {
    param(
        [Parameter(Mandatory)]
        [hashtable]$Target,
        [Parameter(Mandatory)]
        [string]$Path,
        [Parameter(Mandatory)]
        $Value
    )

    $segments = $Path.Split(".")
    $cursor = $Target

    for ($index = 0; $index -lt $segments.Length - 1; $index++) {
        $segment = $segments[$index]
        if (-not $cursor.ContainsKey($segment) -or -not ($cursor[$segment] -is [System.Collections.IDictionary])) {
            $cursor[$segment] = @{}
        }
        $cursor = $cursor[$segment]
    }

    $cursor[$segments[-1]] = $Value
}

function Get-AllowedPatchPrefixes {
    param(
        [hashtable]$Contract,
        [string]$Owner
    )

    $prefixes = @()

    if ($Contract.ContainsKey("sharedValues")) {
        foreach ($sharedKey in $Contract.sharedValues.Keys) {
            $definition = $Contract.sharedValues[$sharedKey]
            if ($definition.owner -eq $Owner -or $Owner -eq "main-orchestrator") {
                $prefixes += $sharedKey
            }
        }
    }

    if ($Contract.ContainsKey("workerNamespaces") -and $Contract.workerNamespaces.ContainsKey($Owner)) {
        foreach ($namespace in $Contract.workerNamespaces[$Owner]) {
            $prefixes += $namespace
        }
    }

    return @($prefixes | Select-Object -Unique)
}

function Test-AllowedPatchKey {
    param(
        [string[]]$AllowedPrefixes,
        [string]$PatchPath
    )

    foreach ($prefix in $AllowedPrefixes) {
        if (Test-HasPathPrefix -Path $PatchPath -Prefix $prefix) {
            return $true
        }
    }

    return $false
}

function Get-TopLevelSharedKey {
    param(
        [Parameter(Mandatory)]
        [string]$PatchPath
    )

    return $PatchPath.Split(".")[0]
}

function Get-FieldPolicy {
    param(
        [Parameter(Mandatory)]
        [hashtable]$Contract,
        [Parameter(Mandatory)]
        [string]$PatchPath
    )

    $topLevelKey = Get-TopLevelSharedKey -PatchPath $PatchPath
    if (-not $Contract.ContainsKey("sharedValues")) {
        return $null
    }

    if (-not $Contract.sharedValues.ContainsKey($topLevelKey)) {
        return $null
    }

    return $Contract.sharedValues[$topLevelKey]
}

function Test-WriterAllowed {
    param(
        [hashtable]$FieldPolicy,
        [string]$Owner
    )

    if (-not $FieldPolicy.ContainsKey("allowedWriters")) {
        return $false
    }

    $writers = @($FieldPolicy.allowedWriters)
    return ($writers -contains $Owner)
}
