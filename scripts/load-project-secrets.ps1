[CmdletBinding()]
param(
    [string]$Path = (Join-Path (Split-Path -Parent $PSScriptRoot) ".local\project.secrets.env")
)

if (-not (Test-Path $Path)) {
    throw "Secrets file not found: $Path"
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
