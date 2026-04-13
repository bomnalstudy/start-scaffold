function Get-SecurityFindings {
    param(
        [string]$RelativePath,
        [string]$NormalizedExtension,
        [string]$Content
    )

    $findings = @()

    if ($NormalizedExtension -in @(".jsx", ".tsx", ".js", ".ts")) {
        $hasSensitiveTerms = ($content -match '(?i)token|secret|password|authorization|api[_-]?key|client[_-]?secret')
        $hasBrowserStorage = ($content -match '(?i)localStorage\.(setItem|getItem)|sessionStorage\.(setItem|getItem)')
        $hasUnsafeHtmlSink = ($content -match 'dangerouslySetInnerHTML' -or $content -match 'innerHTML\s*=')
        $hasSensitiveLogSignal = Test-LineLevelSensitiveLogSignal `
            -Content $content `
            -LogPattern '(?i)console\.(log|debug|info|warn|error)\(|logger\.(debug|info|warn|error)\(' `
            -SensitivePattern '(?i)(token|secret|password|authorization|api[_-]?key|client[_-]?secret)[A-Za-z0-9._\-\]\[]*'

        if ($hasSensitiveTerms -and $hasBrowserStorage) {
            $findings += (New-Finding -Rule "browser-token-storage" -Severity "warn" -Path $RelativePath -Message "Sensitive/auth-related values appear near browser storage usage. Confirm this storage pattern is truly necessary and safe.")
        }

        if ($hasUnsafeHtmlSink) {
            $findings += (New-Finding -Rule "unsafe-html-sink" -Severity "warn" -Path $RelativePath -Message "Unsafe HTML sink detected. Confirm explicit sanitization and trusted content boundaries.")
        }

        if ($hasSensitiveLogSignal) {
            $findings += (New-Finding -Rule "sensitive-log-signal" -Severity "warn" -Path $RelativePath -Message "Sensitive/auth-related terms appear in a file that also logs values. Review for raw secret or token leakage in logs.")
        }

        $hasPiiLogSignal = Test-LineLevelLogPattern `
            -Content $content `
            -LogPattern '(?i)console\.(log|debug|info|warn|error)\(|logger\.(debug|info|warn|error)\(' `
            -TargetPattern '(?i)email|phone|user(id|name)?|session(id)?|ip(address)?'
        if ($hasPiiLogSignal) {
            $findings += (New-Finding -Rule "user-data-log-signal" -Severity "warn" -Path $RelativePath -Message "Potential user or session identifiers appear on a logging line. Confirm PII is masked, hashed, or unnecessary.")
        }

        $hasAuthEnumerationText = ($content -match '(?i)invalid user|account disabled|user does not exist|email not found|wrong password')
        $hasAuthContext = ($content -match '(?i)login|sign in|signin|authenticate|password reset|recovery')
        if ($hasAuthEnumerationText -and $hasAuthContext) {
            $findings += (New-Finding -Rule "auth-enumeration-message" -Severity "warn" -Path $RelativePath -Message "Authentication flow appears to contain account-enumerating error text. Prefer generic auth failure responses.")
        }

        if ($content -match '(?im)^\s*eval\s*\(' -or $content -match '(?im)^\s*new\s+Function\s*\(') {
            $findings += (New-Finding -Rule "dynamic-code-execution" -Severity "warn" -Path $RelativePath -Message "Dynamic code execution detected. Prefer explicit parsing, mapping, or allowlisted dispatch instead of eval-like behavior.")
        }

        if ($content -match '(?i)child_process\.(exec|execSync)\(' -or $content -match '(?i)spawn\s*\(.*shell\s*:\s*true') {
            $findings += (New-Finding -Rule "shell-command-risk" -Severity "warn" -Path $RelativePath -Message "Shell command execution pattern detected. Confirm arguments are structured and user-controlled input cannot reach a shell.")
        }
    }

    if ($NormalizedExtension -eq ".ps1") {
        $hasSensitiveLogSignal = Test-PowerShellSensitiveLogSignal -Content $content
        if ($hasSensitiveLogSignal) {
            $findings += (New-Finding -Rule "sensitive-log-signal" -Severity "warn" -Path $RelativePath -Message "Sensitive terms appear in a script that also prints output. Confirm that raw secret values are not echoed to the console.")
        }

        $hasPiiLogSignal = Test-LineLevelLogPattern `
            -Content $content `
            -LogPattern '(?i)Write-Host|Write-Output' `
            -TargetPattern '(?i)\$[{(]?[A-Za-z0-9_]*(email|phone|user(id|name)?|session(id)?|ip(address)?)[A-Za-z0-9_]*'
        if ($hasPiiLogSignal) {
            $findings += (New-Finding -Rule "user-data-log-signal" -Severity "warn" -Path $RelativePath -Message "Potential user or session identifiers appear in script output. Confirm user data is masked or omitted.")
        }

        if ($content -match '(?im)^\s*Invoke-Expression\b') {
            $findings += (New-Finding -Rule "dynamic-code-execution" -Severity "warn" -Path $RelativePath -Message "Invoke-Expression detected. Prefer explicit command mapping or structured argument passing to avoid command injection risk.")
        }
    }

    return @($findings)
}
