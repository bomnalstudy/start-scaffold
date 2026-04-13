[CmdletBinding()]
param(
    [string]$Profile = "",
    [string]$Source = "",
    [string]$Output = "",
    [string]$Passphrase = ""
)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "project-secrets.crypto.helpers.ps1")

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
if ([string]::IsNullOrWhiteSpace($Source)) {
    $Source = Join-Path $root ".local\secrets\$Profile.env"
}
if ([string]::IsNullOrWhiteSpace($Output)) {
    $Output = Join-Path $root "secure-secrets\$Profile.vault.json"
}

if (-not (Test-Path -LiteralPath $Source)) {
    throw "Secrets source file not found: $Source"
}

$plainSecrets = @{}
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

if ([string]::IsNullOrWhiteSpace($Passphrase)) {
    $Passphrase = [Environment]::GetEnvironmentVariable("SECRETS_PASSPHRASE", "Process")
}
if ([string]::IsNullOrWhiteSpace($Passphrase)) {
    $securePassphrase = Read-Host "Enter export passphrase" -AsSecureString
    $securePassphraseConfirm = Read-Host "Confirm export passphrase" -AsSecureString

    $Passphrase = Get-PlainTextFromSecureString -SecureValue $securePassphrase
    $confirmedPassphrase = Get-PlainTextFromSecureString -SecureValue $securePassphraseConfirm

    if ($Passphrase -ne $confirmedPassphrase) {
        throw "Passphrase confirmation did not match."
    }
}

if ([string]::IsNullOrWhiteSpace($Passphrase)) {
    throw "Passphrase cannot be empty."
}

$iterations = 210000
$saltBytes = New-Object byte[] 16
$rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
try {
    $rng.GetBytes($saltBytes)
} finally {
    $rng.Dispose()
}
$derived = Get-DerivedKeys -Passphrase $Passphrase -SaltBytes $saltBytes -Iterations $iterations
$ivBytes = New-Object byte[] 16
$rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
try {
    $rng.GetBytes($ivBytes)
} finally {
    $rng.Dispose()
}

$renderedLines = New-Object System.Collections.Generic.List[string]
foreach ($key in ($plainSecrets.Keys | Sort-Object)) {
    $renderedLines.Add("$key=$($plainSecrets[$key])")
}
$plainText = $renderedLines -join "`n"
if ($plainText.Length -gt 0) {
    $plainText += "`n"
}
$plainBytes = [System.Text.Encoding]::UTF8.GetBytes($plainText)
$cipherBytes = Protect-AesBytes -PlainBytes $plainBytes -Key $derived.EncryptionKey -Iv $ivBytes
$payloadBase64 = [Convert]::ToBase64String($cipherBytes)

$outputDir = Split-Path -Parent $Output
New-Item -ItemType Directory -Force -Path $outputDir | Out-Null

$format = 3
$createdAt = (Get-Date).ToString("o")
$cipherName = "aes-256-cbc"
$kdfName = "pbkdf2-sha256"
$saltBase64 = [Convert]::ToBase64String($saltBytes)
$ivBase64 = [Convert]::ToBase64String($ivBytes)
$payload = Get-Format3CanonicalPayload -Profile $Profile -CreatedAt $createdAt -CipherName $cipherName -IvBase64 $ivBase64 -KdfName $kdfName -Iterations $iterations -SaltBase64 $saltBase64 -PayloadBase64 $payloadBase64
$tag = Get-HmacTag -AuthKey $derived.AuthKey -Payload $payload

$bundle = [ordered]@{
    format = 3
    createdAt = $createdAt
    profile = $Profile
    cipher = [ordered]@{
        name = $cipherName
        iv = $ivBase64
    }
    kdf = [ordered]@{
        name = $kdfName
        iterations = $iterations
        salt = $saltBase64
    }
    auth = [ordered]@{
        name = "hmac-sha256"
        tag = $tag
    }
    payload = $payloadBase64
}

$bundle | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $Output -Encoding UTF8

Write-Host "Encrypted project secrets written to: $Output"
Write-Host "Profile: $Profile"
Write-Host "Share the passphrase separately from the encrypted bundle."
Write-Host "If you forget the passphrase, the current vault cannot be recovered. Create a new vault with a new passphrase on the next export."
