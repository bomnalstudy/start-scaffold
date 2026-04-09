[CmdletBinding()]
param(
    [string]$Profile = "",
    [string]$Source = "",
    [string]$Output = "",
    [string]$Passphrase = ""
)

$ErrorActionPreference = "Stop"
$emptyMarker = "__EMPTY_STRING__"

function Get-DerivedKeys {
    param(
        [string]$Passphrase,
        [byte[]]$SaltBytes,
        [int]$Iterations
    )

    $kdf = [System.Security.Cryptography.Rfc2898DeriveBytes]::new(
        $Passphrase,
        $SaltBytes,
        $Iterations,
        [System.Security.Cryptography.HashAlgorithmName]::SHA256
    )
    try {
        $material = $kdf.GetBytes(64)
        return [pscustomobject]@{
            EncryptionKey = $material[0..31]
            AuthKey = $material[32..63]
        }
    } finally {
        $kdf.Dispose()
    }
}

function Get-CanonicalPayload {
    param(
        [string]$Format,
        [string]$Profile,
        [string]$CreatedAt,
        [hashtable]$Secrets
    )

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("format=$Format")
    $lines.Add("profile=$Profile")
    $lines.Add("createdAt=$CreatedAt")

    foreach ($key in ($Secrets.Keys | Sort-Object)) {
        $lines.Add("$key=$($Secrets[$key])")
    }

    return ($lines -join "`n")
}

function Get-HmacTag {
    param(
        [byte[]]$AuthKey,
        [string]$Payload
    )

    $hmac = [System.Security.Cryptography.HMACSHA256]::new($AuthKey)
    try {
        $payloadBytes = [System.Text.Encoding]::UTF8.GetBytes($Payload)
        $tagBytes = $hmac.ComputeHash($payloadBytes)
        return [Convert]::ToBase64String($tagBytes)
    } finally {
        $hmac.Dispose()
    }
}

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

if ([string]::IsNullOrWhiteSpace($Passphrase)) {
    $Passphrase = [Environment]::GetEnvironmentVariable("SECRETS_PASSPHRASE", "Process")
}
if ([string]::IsNullOrWhiteSpace($Passphrase)) {
    $securePassphrase = Read-Host "Enter export passphrase" -AsSecureString
    $passphrasePtr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassphrase)

    try {
        $Passphrase = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($passphrasePtr)
    } finally {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($passphrasePtr)
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
$encKeyBytes = $derived.EncryptionKey
$authKeyBytes = $derived.AuthKey
$encryptedSecrets = @{}

foreach ($entry in $plainSecrets.GetEnumerator()) {
    if ($null -eq $entry.Value -or $entry.Value -eq "") {
        $cipherText = $emptyMarker
    } else {
        $secureValue = ConvertTo-SecureString -String $entry.Value -AsPlainText -Force
        $cipherText = ConvertFrom-SecureString -SecureString $secureValue -Key $encKeyBytes
    }
    $encryptedSecrets[$entry.Key] = $cipherText
}

$outputDir = Split-Path -Parent $Output
New-Item -ItemType Directory -Force -Path $outputDir | Out-Null

$format = "2"
$createdAt = (Get-Date).ToString("o")
$payload = Get-CanonicalPayload -Format $format -Profile $Profile -CreatedAt $createdAt -Secrets $encryptedSecrets
$tag = Get-HmacTag -AuthKey $authKeyBytes -Payload $payload

$bundle = [ordered]@{
    format = 2
    createdAt = $createdAt
    profile = $Profile
    encryption = [ordered]@{
        name = "powershell-securestring-aes-cbc-256"
    }
    kdf = [ordered]@{
        name = "pbkdf2-sha256"
        iterations = $iterations
        salt = [Convert]::ToBase64String($saltBytes)
    }
    auth = [ordered]@{
        name = "hmac-sha256"
        tag = $tag
    }
    secrets = $encryptedSecrets
}

$bundle | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $Output -Encoding UTF8

Write-Host "Encrypted project secrets written to: $Output"
Write-Host "Profile: $Profile"
Write-Host "Share the passphrase separately from the encrypted bundle."
