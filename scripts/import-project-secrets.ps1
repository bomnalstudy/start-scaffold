[CmdletBinding()]
param(
    [string]$Profile = "",
    [Alias("Input")]
    [string]$BundlePath = "",
    [string]$Output = "",
    [string]$Passphrase = ""
)

$ErrorActionPreference = "Stop"
$emptyMarker = "__EMPTY_STRING__"

. (Join-Path $PSScriptRoot "powershell\secrets\import-project-secrets.helpers.ps1")

$root = Split-Path -Parent $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($Profile)) {
    $Profile = Get-DefaultProfile
}
if ([string]::IsNullOrWhiteSpace($BundlePath)) {
    $BundlePath = Join-Path $root "secure-secrets\$Profile.vault.json"
}
if ([string]::IsNullOrWhiteSpace($Output)) {
    $Output = Join-Path $root ".local\secrets\$Profile.env"
}

if (-not (Test-Path -LiteralPath $BundlePath)) {
    throw "Encrypted secrets bundle not found: $BundlePath"
}

$bundle = Get-Content -LiteralPath $BundlePath -Raw | ConvertFrom-Json

$Passphrase = Read-ImportPassphrase -Passphrase $Passphrase
$format = Get-BundleFormat -Bundle $bundle
$lines = New-Object System.Collections.Generic.List[string]

if ($format -eq 3) {
    foreach ($line in (Get-Format3Lines -Bundle $bundle -Passphrase $Passphrase)) {
        $lines.Add($line)
    }
} else {
    if (-not $bundle.secrets) {
        throw "Bundle does not contain any secrets."
    }

    $keyBytes = Get-ImportKeyBytes -Bundle $bundle -Passphrase $Passphrase
    foreach ($property in $bundle.secrets.PSObject.Properties) {
        try {
            $cipherText = [string]$property.Value
            if ($cipherText.Trim() -eq $emptyMarker) {
                $plainValue = ""
            } else {
                $secureValue = ConvertTo-SecureString -String $cipherText -Key $keyBytes
                $credential = New-Object System.Management.Automation.PSCredential("user", $secureValue)
                $plainValue = $credential.GetNetworkCredential().Password
            }
            $lines.Add("$($property.Name)=$plainValue")
        } catch {
            throw "Failed to decrypt secret '$($property.Name)'. Check the passphrase."
        }
    }
}

$outputDir = Split-Path -Parent $Output
New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
Set-Content -LiteralPath $Output -Value $lines -Encoding UTF8

Write-Host "Restored local secrets file to: $Output"
Write-Host "Profile: $Profile"
Write-Host "Load it into your session with .\scripts\load-project-secrets.ps1 -Profile $Profile"
