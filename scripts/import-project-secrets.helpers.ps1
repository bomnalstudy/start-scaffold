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

function Get-ImportKeyBytes {
    param(
        [object]$Bundle,
        [string]$Passphrase
    )

    $format = 1
    if ($Bundle.PSObject.Properties.Name -contains "format") {
        try {
            $format = [int]$Bundle.format
        } catch {
            throw "Invalid bundle format."
        }
    }

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
