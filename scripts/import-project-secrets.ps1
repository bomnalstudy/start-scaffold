[CmdletBinding()]
param(
    [string]$Input = (Join-Path (Split-Path -Parent $PSScriptRoot) "handoff\project-secrets.enc.json"),
    [string]$Output = (Join-Path (Split-Path -Parent $PSScriptRoot) ".local\project.secrets.env")
)

function Get-KeyFromPassphrase {
    param([string]$Passphrase)

    $bytes = [System.Text.Encoding]::UTF8.GetBytes($Passphrase)
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        return $sha.ComputeHash($bytes)
    } finally {
        $sha.Dispose()
    }
}

if (-not (Test-Path $Input)) {
    throw "Encrypted secrets bundle not found: $Input"
}

$bundle = Get-Content -LiteralPath $Input -Raw | ConvertFrom-Json

if (-not $bundle.secrets) {
    throw "Bundle does not contain any secrets."
}

$securePassphrase = Read-Host "Enter import passphrase" -AsSecureString
$passphrasePtr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassphrase)

try {
    $passphrase = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($passphrasePtr)
} finally {
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($passphrasePtr)
}

if ([string]::IsNullOrWhiteSpace($passphrase)) {
    throw "Passphrase cannot be empty."
}

$keyBytes = Get-KeyFromPassphrase -Passphrase $passphrase
$lines = New-Object System.Collections.Generic.List[string]

foreach ($property in $bundle.secrets.PSObject.Properties) {
    try {
        $secureValue = ConvertTo-SecureString -String $property.Value -Key $keyBytes
        $credential = New-Object System.Management.Automation.PSCredential("user", $secureValue)
        $plainValue = $credential.GetNetworkCredential().Password
        $lines.Add("$($property.Name)=$plainValue")
    } catch {
        throw "Failed to decrypt secret '$($property.Name)'. Check the passphrase."
    }
}

$outputDir = Split-Path -Parent $Output
New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
Set-Content -LiteralPath $Output -Value $lines -Encoding UTF8

Write-Host "Restored local secrets file to: $Output"
Write-Host "Load it into your session with .\scripts\load-project-secrets.ps1"
