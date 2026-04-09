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

function Get-KeyFromPassphraseLegacy {
    param([string]$Passphrase)

    $bytes = [System.Text.Encoding]::UTF8.GetBytes($Passphrase)
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        return $sha.ComputeHash($bytes)
    } finally {
        $sha.Dispose()
    }
}

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
        [object]$SecretsObject
    )

    $secretsTable = @{}
    foreach ($property in $SecretsObject.PSObject.Properties) {
        $secretsTable[$property.Name] = [string]$property.Value
    }

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("format=$Format")
    $lines.Add("profile=$Profile")
    $lines.Add("createdAt=$CreatedAt")
    foreach ($key in ($secretsTable.Keys | Sort-Object)) {
        $lines.Add("$key=$($secretsTable[$key])")
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

function Test-FixedTimeEquals {
    param(
        [byte[]]$A,
        [byte[]]$B
    )

    if ($A.Length -ne $B.Length) {
        return $false
    }

    $diff = 0
    for ($i = 0; $i -lt $A.Length; $i++) {
        $diff = $diff -bor ($A[$i] -bxor $B[$i])
    }
    return ($diff -eq 0)
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

if (-not $bundle.secrets) {
    throw "Bundle does not contain any secrets."
}

if ([string]::IsNullOrWhiteSpace($Passphrase)) {
    $Passphrase = [Environment]::GetEnvironmentVariable("SECRETS_PASSPHRASE", "Process")
}
if ([string]::IsNullOrWhiteSpace($Passphrase)) {
    $securePassphrase = Read-Host "Enter import passphrase" -AsSecureString
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

$format = 1
if ($bundle.PSObject.Properties.Name -contains "format") {
    try {
        $format = [int]$bundle.format
    } catch {
        throw "Invalid bundle format."
    }
}

$keyBytes = $null
if ($format -eq 1) {
    $keyBytes = Get-KeyFromPassphraseLegacy -Passphrase $Passphrase
} elseif ($format -eq 2) {
    if (-not $bundle.kdf -or -not $bundle.auth) {
        throw "Bundle is missing kdf/auth metadata."
    }
    if ([string]::IsNullOrWhiteSpace([string]$bundle.kdf.salt)) {
        throw "Bundle is missing kdf salt."
    }
    if (-not $bundle.kdf.iterations) {
        throw "Bundle is missing kdf iterations."
    }
    if ([string]::IsNullOrWhiteSpace([string]$bundle.auth.tag)) {
        throw "Bundle is missing auth tag."
    }

    $saltBytes = [Convert]::FromBase64String([string]$bundle.kdf.salt)
    $iterations = [int]$bundle.kdf.iterations
    $derived = Get-DerivedKeys -Passphrase $Passphrase -SaltBytes $saltBytes -Iterations $iterations

    $payload = Get-CanonicalPayload -Format "2" -Profile ([string]$bundle.profile) -CreatedAt ([string]$bundle.createdAt) -SecretsObject $bundle.secrets
    $computedTag = Get-HmacTag -AuthKey $derived.AuthKey -Payload $payload

    $expectedTagBytes = [Convert]::FromBase64String([string]$bundle.auth.tag)
    $actualTagBytes = [Convert]::FromBase64String($computedTag)
    if (-not (Test-FixedTimeEquals -A $expectedTagBytes -B $actualTagBytes)) {
        throw "Bundle integrity verification failed. Wrong passphrase or modified file. If the passphrase is forgotten, discard this vault and create a new one on the next export."
    }

    $keyBytes = $derived.EncryptionKey
} else {
    throw "Unsupported bundle format: $format"
}

$lines = New-Object System.Collections.Generic.List[string]

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

$outputDir = Split-Path -Parent $Output
New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
Set-Content -LiteralPath $Output -Value $lines -Encoding UTF8

Write-Host "Restored local secrets file to: $Output"
Write-Host "Profile: $Profile"
Write-Host "Load it into your session with .\scripts\load-project-secrets.ps1 -Profile $Profile"
