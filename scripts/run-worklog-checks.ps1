[CmdletBinding()]
param(
    [string]$Root = (Split-Path -Parent $PSScriptRoot),
    [Parameter(Mandatory = $true)]
    [string]$WorklogPath,
    [switch]$EmitJson
)

$ErrorActionPreference = "Stop"

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

function Get-SectionBody {
    param(
        [string]$Content,
        [string]$Heading
    )

    $pattern = "(?ms)^##\s+" + [regex]::Escape($Heading) + "\s*\r?\n(.*?)(?=^##\s+|\z)"
    $match = [regex]::Match($Content, $pattern)
    if (-not $match.Success) {
        return $null
    }
    $match.Groups[1].Value
}

function Test-SectionFilled {
    param([string]$Body)

    if ($null -eq $Body) {
        return $false
    }

    foreach ($line in ($Body -split "`r?`n")) {
        $t = $line.Trim()
        if (-not $t) { continue }
        if ($t -eq "-") { continue }
        if ($t -match '^\d+\.\s*$') { continue }
        if ($t -match '^[-*]\s*$') { continue }
        return $true
    }

    return $false
}

$rootPath = (Resolve-Path -LiteralPath $Root).Path
$resolvedPath = if ([System.IO.Path]::IsPathRooted($WorklogPath)) { $WorklogPath } else { Join-Path $rootPath $WorklogPath }
$findings = @()

if (-not (Test-Path -LiteralPath $resolvedPath)) {
    $findings += (New-Finding -Rule "worklog-file" -Severity "error" -Path $WorklogPath -Message "Worklog file not found.")
} else {
    $content = Get-Content -LiteralPath $resolvedPath -Raw
    $requiredSections = @(
        "Original Goal",
        "MVP Scope (This Session)",
        "Key Changes",
        "Validation",
        "Mistakes / Drift Signals Observed",
        "Prevention for Next Session",
        "Direction Check",
        "Next Tasks"
    )

    foreach ($section in $requiredSections) {
        $body = Get-SectionBody -Content $content -Heading $section
        if ($null -eq $body) {
            $findings += (New-Finding -Rule "required-section" -Severity "error" -Path $WorklogPath -Message "Missing required section: $section")
            continue
        }

        if (-not (Test-SectionFilled -Body $body)) {
            $findings += (New-Finding -Rule "required-value" -Severity "error" -Path $WorklogPath -Message "Section '$section' is empty or placeholder-only.")
        }
    }
}

$summary = [pscustomobject]@{
    root = $rootPath
    worklogPath = $resolvedPath
    errorCount = @($findings | Where-Object { $_.severity -eq "error" }).Count
    warnCount = @($findings | Where-Object { $_.severity -eq "warn" }).Count
    findings = @($findings)
}

if ($EmitJson) {
    $summary | ConvertTo-Json -Depth 5
    exit ([int]($summary.errorCount -gt 0))
}

Write-Host "Worklog Check"
Write-Host "Root: $($summary.root)"
Write-Host "Worklog: $($summary.worklogPath)"
Write-Host "Errors: $($summary.errorCount)"
Write-Host "Warnings: $($summary.warnCount)"
Write-Host ""

if ($summary.findings.Count -eq 0) {
    Write-Host "No findings."
    exit 0
}

foreach ($finding in $summary.findings) {
    Write-Host "[$($finding.severity.ToUpper())] [$($finding.rule)] $($finding.path)"
    Write-Host "  $($finding.message)"
}

exit ([int]($summary.errorCount -gt 0))
