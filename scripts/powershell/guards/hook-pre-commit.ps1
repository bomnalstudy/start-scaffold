[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

function Fail {
    param([string]$Message)
    Write-Host ""
    Write-Host "[BLOCKED] pre-commit: $Message"
    exit 1
}

function Get-LineCount {
    param([string]$AbsolutePath)

    if (-not (Test-Path -LiteralPath $AbsolutePath)) {
        return 0
    }

    return (Get-Content -LiteralPath $AbsolutePath).Count
}

function Get-StagedAddedLineCount {
    param([string]$RepoRelativePath)

    $diff = git diff --cached --no-color --unified=0 -- "$RepoRelativePath"
    if ($LASTEXITCODE -ne 0) {
        Fail "Failed to read staged diff for $RepoRelativePath."
    }

    $addedLines = 0
    foreach ($line in ($diff -split "`r?`n")) {
        if ($line.StartsWith("+") -and -not $line.StartsWith("+++")) {
            $addedLines++
        }
    }

    return $addedLines
}

function Test-PlaceholderWorklog {
    param(
        [string]$RepoRelativePath,
        [string]$AbsolutePath
    )

    if ($RepoRelativePath -notlike "worklogs/*.md" -and $RepoRelativePath -notlike "worklogs/tasks/*.md") {
        return $false
    }

    if (-not (Test-Path -LiteralPath $AbsolutePath)) {
        return $false
    }

    $content = Get-Content -LiteralPath $AbsolutePath -Raw
    if ([string]::IsNullOrWhiteSpace($content)) {
        return $true
    }

    $placeholderSignals = @(
        "## Date`r`n`r`nYYYY-MM-DD",
        "## Original Goal`r`n`r`n-",
        "## Project / Task`r`n`r`n-",
        "## MVP Scope`r`n`r`n-",
        "## Done When`r`n`r`n-"
    )

    $matchedSignals = 0
    foreach ($signal in $placeholderSignals) {
        if ($content.Contains($signal)) {
            $matchedSignals++
        }
    }

    return ($matchedSignals -ge 3)
}

$stagedFiles = git diff --cached --name-only --diff-filter=ACM
if ($LASTEXITCODE -ne 0) {
    Fail "Failed to read staged files."
}

if (-not $stagedFiles) {
    exit 0
}

$blockedPaths = @()
$cleanupPaths = @()
$scanTargets = New-Object System.Collections.Generic.List[string]
$repoRoot = Split-Path -Parent $PSScriptRoot
$cleanupAllowlist = @(
    "scripts/debug-orchestrator.ps1",
    "scripts/bash/debug-orchestrator.sh",
    "scripts/powershell/orchestrator/debug-orchestrator.ps1"
)
$lineCheckedExtensions = @(".js", ".jsx", ".ts", ".tsx", ".css", ".scss", ".less", ".html", ".json", ".md", ".ps1", ".py")
$maxLines = 500
$growthGuardThreshold = 300
$growthGuardAddedLines = 40

foreach ($f in $stagedFiles) {
    $n = $f.Replace('\', '/')
    $absolutePath = Join-Path $repoRoot $f

    $looksTemporary = (
        $n -match '(^|/)(tmp|temp|scratch|playground|debug)(/|$)' -or
        $n -match '(^|/)(tmp-|temp-|scratch-|playground-|debug-)' -or
        $n -match '\.(tmp|bak|orig|rej)$'
    )
    if ($looksTemporary -and $n -notin $cleanupAllowlist) {
        $cleanupPaths += $n
        continue
    }

    if (Test-PlaceholderWorklog -RepoRelativePath $n -AbsolutePath $absolutePath) {
        $cleanupPaths += $n
        continue
    }

    $extension = [System.IO.Path]::GetExtension($n).ToLowerInvariant()
    if ($lineCheckedExtensions -contains $extension) {
        $lineCount = Get-LineCount -AbsolutePath $absolutePath
        if ($lineCount -gt $maxLines) {
            Fail "$n has $lineCount lines. Limit is $maxLines. Split the file before commit."
        }

        if ($lineCount -gt $growthGuardThreshold) {
            $addedLines = Get-StagedAddedLineCount -RepoRelativePath $n
            if ($addedLines -ge $growthGuardAddedLines) {
                Fail "$n has $lineCount lines and this commit adds $addedLines lines. Split or reduce the file before commit."
            }
        }
    }

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

if ($cleanupPaths.Count -gt 0) {
    Fail ("Temporary or placeholder files are staged: " + ($cleanupPaths -join ", ") + ". Clean them up or move retired files to .graveyard first.")
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
