[CmdletBinding()]
param(
    [string]$Source = (Join-Path (Split-Path -Parent $PSScriptRoot) ".local\project.secrets.env"),
    [string]$Output = (Join-Path (Split-Path -Parent $PSScriptRoot) "handoff\project-secrets.enc.json")
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

if (-not (Test-Path $Source)) {
    throw "Secrets source file not found: $Source"
}

$plainSecrets = [ordered]@{}
Get-Content -LiteralPath $Source | ForEach-Object {
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
    $plainSecrets[$key] = $value
}

if ($plainSecrets.Count -eq 0) {
    throw "No secrets were found in $Source"
}

$securePassphrase = Read-Host "Enter export passphrase" -AsSecureString
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
$encryptedSecrets = [ordered]@{}

foreach ($entry in $plainSecrets.GetEnumerator()) {
    $secureValue = ConvertTo-SecureString -String $entry.Value -AsPlainText -Force
    $cipherText = ConvertFrom-SecureString -SecureString $secureValue -Key $keyBytes
    $encryptedSecrets[$entry.Key] = $cipherText
}

$outputDir = Split-Path -Parent $Output
New-Item -ItemType Directory -Force -Path $outputDir | Out-Null

$bundle = [ordered]@{
    format = 1
    createdAt = (Get-Date).ToString("o")
    source = (Resolve-Path -LiteralPath $Source).Path
    secrets = $encryptedSecrets
}

$bundle | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $Output -Encoding UTF8

Write-Host "Encrypted project secrets written to: $Output"
Write-Host "Share the passphrase separately from the encrypted bundle."
