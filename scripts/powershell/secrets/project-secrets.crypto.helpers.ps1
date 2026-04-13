function Get-PlainTextFromSecureString {
    param([Security.SecureString]$SecureValue)

    $valuePtr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureValue)
    try {
        return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($valuePtr)
    } finally {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($valuePtr)
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

function Protect-AesBytes {
    param(
        [byte[]]$PlainBytes,
        [byte[]]$Key,
        [byte[]]$Iv
    )

    $aes = [System.Security.Cryptography.Aes]::Create()
    try {
        $aes.KeySize = 256
        $aes.Mode = [System.Security.Cryptography.CipherMode]::CBC
        $aes.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7
        $aes.Key = $Key
        $aes.IV = $Iv
        $encryptor = $aes.CreateEncryptor()
        try {
            return $encryptor.TransformFinalBlock($PlainBytes, 0, $PlainBytes.Length)
        } finally {
            $encryptor.Dispose()
        }
    } finally {
        $aes.Dispose()
    }
}

function Unprotect-AesBytes {
    param(
        [byte[]]$CipherBytes,
        [byte[]]$Key,
        [byte[]]$Iv
    )

    $aes = [System.Security.Cryptography.Aes]::Create()
    try {
        $aes.KeySize = 256
        $aes.Mode = [System.Security.Cryptography.CipherMode]::CBC
        $aes.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7
        $aes.Key = $Key
        $aes.IV = $Iv
        $decryptor = $aes.CreateDecryptor()
        try {
            return $decryptor.TransformFinalBlock($CipherBytes, 0, $CipherBytes.Length)
        } finally {
            $decryptor.Dispose()
        }
    } finally {
        $aes.Dispose()
    }
}

function Get-Format3CanonicalPayload {
    param(
        [string]$Profile,
        [string]$CreatedAt,
        [string]$CipherName,
        [string]$IvBase64,
        [string]$KdfName,
        [int]$Iterations,
        [string]$SaltBase64,
        [string]$PayloadBase64
    )

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("format=3")
    $lines.Add("profile=$Profile")
    $lines.Add("createdAt=$CreatedAt")
    $lines.Add("cipher=$CipherName")
    $lines.Add("iv=$IvBase64")
    $lines.Add("kdf=$KdfName")
    $lines.Add("iterations=$Iterations")
    $lines.Add("salt=$SaltBase64")
    $lines.Add("payload=$PayloadBase64")
    return ($lines -join "`n")
}
