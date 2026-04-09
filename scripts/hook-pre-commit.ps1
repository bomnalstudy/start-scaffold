[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

function Fail {
    param([string]$Message)
    Write-Host ""
    Write-Host "[BLOCKED] pre-commit: $Message"
    exit 1
}

$stagedFiles = git diff --cached --name-only --diff-filter=ACM
if ($LASTEXITCODE -ne 0) {
    Fail "Failed to read staged files."
}

if (-not $stagedFiles) {
    exit 0
}

$blockedPaths = @()
$scanTargets = New-Object System.Collections.Generic.List[string]

foreach ($f in $stagedFiles) {
    $n = $f.Replace('\', '/')

    if ($n -like ".local/*") {
        $blockedPaths += $n
        continue
    }

    if ($n -match '(^|/)\.env($|\.|/)') {
        $allowed = $false
        if ($n -eq "templates/.env.local.example") { $allowed = $true }
        if ($n -match '\.example$') { $allowed = $true }
        if (-not $allowed) {
            $blockedPaths += $n
        }
    }

    $skipScan = $false
    if ($n -like "secure-secrets/*.vault.json") { $skipScan = $true }
    if ($n -eq "templates/.env.local.example") { $skipScan = $true }
    if (-not $skipScan) {
        $scanTargets.Add($n)
    }
}

if ($blockedPaths.Count -gt 0) {
    Fail ("Plain local env/secrets path is staged: " + ($blockedPaths -join ", "))
}

$secretLikePattern = '(?i)\b(api[_-]?key|secret|token|password|private[_-]?key|client[_-]?secret)\b\s*[:=]\s*["'']?[A-Za-z0-9_\-\/\+=]{12,}'
$providerPattern = '(?i)(OPENAI_API_KEY|ANTHROPIC_API_KEY|GITHUB_TOKEN|LINEAR_API_KEY|NOTION_API_KEY)\s*='
$hardTokenPrefixPattern = '(?i)(sk-[A-Za-z0-9]{16,}|ghp_[A-Za-z0-9]{20,}|xox[baprs]-[A-Za-z0-9-]{10,})'
$ignorePattern = '(?i)(example|placeholder|YOUR_|<REDACTED>|changeme)'

foreach ($target in $scanTargets) {
    $diff = git diff --cached --no-color --unified=0 -- "$target"
    if ($LASTEXITCODE -ne 0) {
        Fail "Failed to read staged diff for $target."
    }

    $lineNo = 0
    foreach ($line in ($diff -split "`r?`n")) {
        $lineNo++
        if (-not $line.StartsWith("+")) { continue }
        if ($line.StartsWith("+++")) { continue }
        if ($line -match $ignorePattern) { continue }

        if ($line -match $providerPattern -or $line -match $hardTokenPrefixPattern -or $line -match $secretLikePattern) {
            Fail ("Potential secret detected in $target (line $lineNo). Remove or redact before commit.")
        }
    }
}

exit 0
