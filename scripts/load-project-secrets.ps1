[CmdletBinding()]
param(
    [string]$Profile = "",
    [string]$Path = ""
)

function Get-DefaultProfile {
    $name = [Environment]::GetEnvironmentVariable("PROJECT_NAME", "Process")
    if ([string]::IsNullOrWhiteSpace($name)) {
        $name = [System.IO.Path]::GetFileName((Split-Path -Parent $PSScriptRoot))
    }
    if ([string]::IsNullOrWhiteSpace($name)) {
        return "default"
    }
    return $name.ToLowerInvariant()
}

$root = Split-Path -Parent $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($Profile)) {
    $Profile = Get-DefaultProfile
}

if ([string]::IsNullOrWhiteSpace($Path)) {
    $Path = Join-Path $root ".local\secrets\$Profile.env"
}

if (-not (Test-Path -LiteralPath $Path)) {
    throw "Secrets file not found: $Path (profile: $Profile)"
}

$loadedKeys = New-Object System.Collections.Generic.List[string]

Get-Content -LiteralPath $Path | ForEach-Object {
    $line = $_.Trim()

    if (-not $line -or $line.StartsWith("#")) {
        return
    }

    $separatorIndex = $line.IndexOf("=")
    if ($separatorIndex -lt 1) {
        return
    }

    $key = $line.Substring(0, $separatorIndex).Trim()
    $value = $line.Substring($separatorIndex + 1)

    [Environment]::SetEnvironmentVariable($key, $value, "Process")
    $loadedKeys.Add($key)
}

Write-Host "Loaded $($loadedKeys.Count) variables into the current PowerShell session."
if ($loadedKeys.Count -gt 0) {
    Write-Host ($loadedKeys -join ", ")
}
Write-Host "Profile: $Profile"
