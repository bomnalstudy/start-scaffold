 . (Join-Path $PSScriptRoot "project-secrets.crypto.helpers.ps1")

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

function Read-ImportPassphrase {
    param([string]$Passphrase)

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

    return $Passphrase
}

function Get-BundleFormat {
    param([object]$Bundle)

    $format = 1
    if ($Bundle.PSObject.Properties.Name -contains "format") {
        try {
            $format = [int]$Bundle.format
        } catch {
            throw "Invalid bundle format."
        }
    }
    return $format
}

function Get-ImportKeyBytes {
    param(
        [object]$Bundle,
        [string]$Passphrase
    )

    $format = Get-BundleFormat -Bundle $Bundle

    if ($format -eq 1) {
        return Get-KeyFromPassphraseLegacy -Passphrase $Passphrase
    }

    if ($format -eq 2) {
        if (-not $Bundle.kdf -or -not $Bundle.auth) {
            throw "Bundle is missing kdf/auth metadata."
        }
        if ([string]::IsNullOrWhiteSpace([string]$Bundle.kdf.salt)) {
            throw "Bundle is missing kdf salt."
        }
        if (-not $Bundle.kdf.iterations) {
            throw "Bundle is missing kdf iterations."
        }
        if ([string]::IsNullOrWhiteSpace([string]$Bundle.auth.tag)) {
            throw "Bundle is missing auth tag."
        }

        $saltBytes = [Convert]::FromBase64String([string]$Bundle.kdf.salt)
        $iterations = [int]$Bundle.kdf.iterations
        $derived = Get-DerivedKeys -Passphrase $Passphrase -SaltBytes $saltBytes -Iterations $iterations

        $payload = Get-CanonicalPayload -Format "2" -Profile ([string]$Bundle.profile) -CreatedAt ([string]$Bundle.createdAt) -SecretsObject $Bundle.secrets
        $computedTag = Get-HmacTag -AuthKey $derived.AuthKey -Payload $payload

        $expectedTagBytes = [Convert]::FromBase64String([string]$Bundle.auth.tag)
        $actualTagBytes = [Convert]::FromBase64String($computedTag)
        if (-not (Test-FixedTimeEquals -A $expectedTagBytes -B $actualTagBytes)) {
            throw "Bundle integrity verification failed. Wrong passphrase or modified file. If the passphrase is forgotten, discard this vault and create a new one on the next export."
        }

        return $derived.EncryptionKey
    }

    throw "Unsupported bundle format: $format"
}

function Get-Format3Lines {
    param(
        [object]$Bundle,
        [string]$Passphrase
    )

    if (-not $Bundle.cipher -or -not $Bundle.kdf -or -not $Bundle.auth) {
        throw "Bundle is missing cipher/kdf/auth metadata."
    }
    if ([string]::IsNullOrWhiteSpace([string]$Bundle.payload)) {
        throw "Bundle is missing payload."
    }
    if ([string]::IsNullOrWhiteSpace([string]$Bundle.cipher.iv)) {
        throw "Bundle is missing cipher iv."
    }
    if ([string]::IsNullOrWhiteSpace([string]$Bundle.kdf.salt)) {
        throw "Bundle is missing kdf salt."
    }
    if (-not $Bundle.kdf.iterations) {
        throw "Bundle is missing kdf iterations."
    }
    if ([string]::IsNullOrWhiteSpace([string]$Bundle.auth.tag)) {
        throw "Bundle is missing auth tag."
    }

    $cipherName = [string]$Bundle.cipher.name
    $kdfName = [string]$Bundle.kdf.name
    if ($cipherName -ne "aes-256-cbc") {
        throw "Unsupported format 3 cipher: $cipherName"
    }
    if ($kdfName -ne "pbkdf2-sha256") {
        throw "Unsupported format 3 kdf: $kdfName"
    }

    $saltBase64 = [string]$Bundle.kdf.salt
    $iterations = [int]$Bundle.kdf.iterations
    $payloadBase64 = [string]$Bundle.payload
    $ivBase64 = [string]$Bundle.cipher.iv
    $createdAt = [string]$Bundle.createdAt
    $profile = [string]$Bundle.profile

    $saltBytes = [Convert]::FromBase64String($saltBase64)
    $derived = Get-DerivedKeys -Passphrase $Passphrase -SaltBytes $saltBytes -Iterations $iterations
    $canonical = Get-Format3CanonicalPayload -Profile $profile -CreatedAt $createdAt -CipherName $cipherName -IvBase64 $ivBase64 -KdfName $kdfName -Iterations $iterations -SaltBase64 $saltBase64 -PayloadBase64 $payloadBase64
    $computedTag = Get-HmacTag -AuthKey $derived.AuthKey -Payload $canonical

    $expectedTagBytes = [Convert]::FromBase64String([string]$Bundle.auth.tag)
    $actualTagBytes = [Convert]::FromBase64String($computedTag)
    if (-not (Test-FixedTimeEquals -A $expectedTagBytes -B $actualTagBytes)) {
        throw "Bundle integrity verification failed. Wrong passphrase or modified file. If the passphrase is forgotten, discard this vault and create a new one on the next export."
    }

    $ivBytes = [Convert]::FromBase64String($ivBase64)
    $cipherBytes = [Convert]::FromBase64String($payloadBase64)
    $plainBytes = Unprotect-AesBytes -CipherBytes $cipherBytes -Key $derived.EncryptionKey -Iv $ivBytes
    $plainText = [System.Text.Encoding]::UTF8.GetString($plainBytes)
    $plainText = $plainText -replace "`r",""

    $lines = New-Object System.Collections.Generic.List[string]
    foreach ($line in ($plainText -split "`n")) {
        if ($line -eq "" -and $lines.Count -gt 0) {
            continue
        }
        if ($line -ne "") {
            $lines.Add($line)
        }
    }
    return $lines
}
