function Get-RelativePath {
    param(
        [string]$BasePath,
        [string]$TargetPath
    )

    $baseFull = [System.IO.Path]::GetFullPath($BasePath)
    $targetFull = [System.IO.Path]::GetFullPath($TargetPath)
    $separator = [System.IO.Path]::DirectorySeparatorChar

    if (-not $baseFull.EndsWith([string]$separator)) {
        $baseFull += [string]$separator
    }

    if ($targetFull.StartsWith($baseFull, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $targetFull.Substring($baseFull.Length).TrimStart($separator)
    }

    return $targetFull
}

function New-Finding {
    param(
        [string]$Rule,
        [string]$Severity,
        [string]$Path,
        [string]$Message
    )

    [pscustomobject]@{
        rule = $Rule
        severity = $Severity
        path = $Path
        message = $Message
    }
}

function Test-LineLevelSensitiveLogSignal {
    param(
        [string]$Content,
        [string]$LogPattern,
        [string]$SensitivePattern
    )

    $lines = $Content -split "`r?`n"
    foreach ($line in $lines) {
        if ($line -match $LogPattern -and $line -match $SensitivePattern) {
            return $true
        }
    }

    return $false
}

function Test-PowerShellSensitiveLogSignal {
    param(
        [string]$Content
    )

    $lines = $Content -split "`r?`n"
    $logPattern = '(?i)Write-Host|Write-Output'
    $sensitiveVariablePattern = '(?i)\$[{(]?[A-Za-z0-9_]*(token|secret|password|authorization|api[_-]?key|client[_-]?secret|passphrase)[A-Za-z0-9_]*'
    $safeSuffixPattern = '(?i)(Path|Dir|File|Profile)'

    foreach ($line in $lines) {
        if ($line -notmatch $logPattern) {
            continue
        }

        if ($line -match $sensitiveVariablePattern) {
            if ($line -match $safeSuffixPattern) {
                continue
            }

            return $true
        }
    }

    return $false
}

function Test-LineLevelLogPattern {
    param(
        [string]$Content,
        [string]$LogPattern,
        [string]$TargetPattern
    )

    $lines = $Content -split "`r?`n"
    foreach ($line in $lines) {
        if ($line -match $LogPattern -and $line -match $TargetPattern) {
            return $true
        }
    }

    return $false
}

function Test-PlaceholderWorklogPattern {
    param(
        [string]$Content
    )

    $placeholderSignals = 0
    foreach ($signal in @(
        "## Date`r`n`r`nYYYY-MM-DD",
        "## Original Goal`r`n`r`n-",
        "## Project / Task`r`n`r`n-",
        "## MVP Scope`r`n`r`n-",
        "## Done When`r`n`r`n-"
    )) {
        if ($Content.Contains($signal)) {
            $placeholderSignals++
        }
    }

    return ($placeholderSignals -ge 3)
}
