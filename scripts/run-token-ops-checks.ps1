[CmdletBinding()]
param(
    [string]$Root = (Split-Path -Parent $PSScriptRoot),
    [string]$PlanPath = "templates/orchestration-plan.md",
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

    return $match.Groups[1].Value
}

function Test-SectionFilled {
    param([string]$Body)

    if ($null -eq $Body) {
        return $false
    }

    $lines = $Body -split "`r?`n"
    foreach ($line in $lines) {
        $t = $line.Trim()
        if (-not $t) {
            continue
        }

        if ($t -eq "-") {
            continue
        }

        if ($t -match '^-+\s*$') {
            continue
        }

        if ($t -match '^[-*]\s*$') {
            continue
        }

        return $true
    }

    return $false
}

$rootPath = (Resolve-Path -LiteralPath $Root).Path
$resolvedPlanPath = if ([System.IO.Path]::IsPathRooted($PlanPath)) { $PlanPath } else { Join-Path $rootPath $PlanPath }
$findings = @()

if (-not (Test-Path -LiteralPath $resolvedPlanPath)) {
    $findings += (New-Finding -Rule "plan-file" -Severity "error" -Path $PlanPath -Message "Plan file not found.")
} else {
    $content = Get-Content -LiteralPath $resolvedPlanPath -Raw
    $requiredSections = @(
        "Original Goal",
        "MVP Scope",
        "Non-Goal",
        "Done When",
        "Stop If"
    )

    foreach ($section in $requiredSections) {
        $body = Get-SectionBody -Content $content -Heading $section
        if ($null -eq $body) {
            $findings += (New-Finding -Rule "required-section" -Severity "error" -Path $PlanPath -Message "Missing required section: $section")
            continue
        }

        if (-not (Test-SectionFilled -Body $body)) {
            $findings += (New-Finding -Rule "required-value" -Severity "error" -Path $PlanPath -Message "Section '$section' is empty or placeholder-only.")
        }
    }
}

$summary = [pscustomobject]@{
    root = $rootPath
    planPath = $resolvedPlanPath
    errorCount = @($findings | Where-Object { $_.severity -eq "error" }).Count
    warnCount = @($findings | Where-Object { $_.severity -eq "warn" }).Count
    findings = @($findings)
}

if ($EmitJson) {
    $summary | ConvertTo-Json -Depth 5
    exit ([int]($summary.errorCount -gt 0))
}

Write-Host "Token Ops Check"
Write-Host "Root: $($summary.root)"
Write-Host "Plan: $($summary.planPath)"
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
