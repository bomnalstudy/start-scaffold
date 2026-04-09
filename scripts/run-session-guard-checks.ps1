[CmdletBinding()]
param(
    [string]$Root = (Split-Path -Parent $PSScriptRoot),
    [string]$PlanPath = "templates/orchestration-plan.md",
    [string]$WorklogPath = "",
    [ValidateSet("preflight", "checkpoint", "close")]
    [string]$Mode = "checkpoint",
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

function Get-MeaningfulLines {
    param([string]$Body)

    if ($null -eq $Body) {
        return @()
    }

    $output = @()
    foreach ($line in ($Body -split "`r?`n")) {
        $t = $line.Trim()
        if (-not $t) { continue }
        if ($t -eq "-") { continue }
        if ($t -match '^[-*]\s*$') { continue }
        if ($t -match '^\d+\.\s*$') { continue }
        $output += $t
    }

    return $output
}

function Get-BulletLineCount {
    param([string[]]$Lines)

    $count = 0
    foreach ($line in $Lines) {
        if ($line -match '^[-*]\s+' -or $line -match '^\d+\.\s+') {
            $count++
        }
    }
    return $count
}

function Resolve-RelativeOrAbsolutePath {
    param(
        [string]$RootPath,
        [string]$Path
    )

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return ""
    }

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return $Path
    }

    return (Join-Path $RootPath $Path)
}

$rootPath = (Resolve-Path -LiteralPath $Root).Path
$resolvedPlanPath = Resolve-RelativeOrAbsolutePath -RootPath $rootPath -Path $PlanPath
$resolvedWorklogPath = Resolve-RelativeOrAbsolutePath -RootPath $rootPath -Path $WorklogPath
$findings = @()

if (-not (Test-Path -LiteralPath $resolvedPlanPath)) {
    $findings += (New-Finding -Rule "plan-file" -Severity "error" -Path $PlanPath -Message "Plan file not found.")
} else {
    $planContent = Get-Content -LiteralPath $resolvedPlanPath -Raw
    $requiredPlanSections = @(
        "Original Goal",
        "MVP Scope",
        "Non-Goal",
        "Done When",
        "Stop If"
    )

    $sectionLines = @{}
    foreach ($section in $requiredPlanSections) {
        $body = Get-SectionBody -Content $planContent -Heading $section
        $lines = Get-MeaningfulLines -Body $body
        $sectionLines[$section] = $lines

        if ($null -eq $body) {
            $findings += (New-Finding -Rule "required-section" -Severity "error" -Path $PlanPath -Message "Missing required section: $section")
            continue
        }

        if ($lines.Count -eq 0) {
            $findings += (New-Finding -Rule "required-value" -Severity "error" -Path $PlanPath -Message "Section '$section' is empty or placeholder-only.")
        }
    }

    if ($sectionLines.ContainsKey("MVP Scope")) {
        $mvpBulletCount = Get-BulletLineCount -Lines $sectionLines["MVP Scope"]
        if ($mvpBulletCount -gt 5) {
            $findings += (New-Finding -Rule "mvp-too-wide" -Severity "warn" -Path $PlanPath -Message "MVP Scope has $mvpBulletCount bullet items. Keep it within 3-5 items to avoid drift.")
        }
    }

    if ($sectionLines.ContainsKey("Done When")) {
        $doneWhenBulletCount = Get-BulletLineCount -Lines $sectionLines["Done When"]
        if ($doneWhenBulletCount -gt 5) {
            $findings += (New-Finding -Rule "done-when-too-wide" -Severity "warn" -Path $PlanPath -Message "Done When has $doneWhenBulletCount bullet items. Consider narrowing completion criteria.")
        }
    }

    if ($sectionLines.ContainsKey("Stop If")) {
        $stopIfBulletCount = Get-BulletLineCount -Lines $sectionLines["Stop If"]
        if ($stopIfBulletCount -lt 2) {
            $findings += (New-Finding -Rule "weak-stop-condition" -Severity "warn" -Path $PlanPath -Message "Stop If should list at least 2 concrete stop conditions.")
        }
    }
}

if ($Mode -ne "preflight") {
    if (-not $resolvedWorklogPath) {
        $findings += (New-Finding -Rule "worklog-required" -Severity "error" -Path $WorklogPath -Message "WorklogPath is required in checkpoint/close mode.")
    } elseif (-not (Test-Path -LiteralPath $resolvedWorklogPath)) {
        $findings += (New-Finding -Rule "worklog-file" -Severity "error" -Path $WorklogPath -Message "Worklog file not found.")
    } else {
        $worklogContent = Get-Content -LiteralPath $resolvedWorklogPath -Raw
        $requiredWorklogSections = @(
            "Mistakes / Drift Signals Observed",
            "Prevention for Next Session",
            "Direction Check",
            "Next Tasks"
        )

        foreach ($section in $requiredWorklogSections) {
            $body = Get-SectionBody -Content $worklogContent -Heading $section
            $lines = Get-MeaningfulLines -Body $body

            if ($null -eq $body) {
                $findings += (New-Finding -Rule "required-section" -Severity "error" -Path $WorklogPath -Message "Missing required section: $section")
                continue
            }

            if ($lines.Count -eq 0) {
                $findings += (New-Finding -Rule "required-value" -Severity "error" -Path $WorklogPath -Message "Section '$section' is empty or placeholder-only.")
            }
        }

        if ($Mode -eq "close") {
            $directionBody = Get-SectionBody -Content $worklogContent -Heading "Direction Check"
            $directionText = ((Get-MeaningfulLines -Body $directionBody) -join " ").ToLowerInvariant()
            if ($directionText -notmatch 'stop|halt|defer|next') {
                $findings += (New-Finding -Rule "close-stop-rationale" -Severity "warn" -Path $WorklogPath -Message "Direction Check should explain why we can stop now and what moves to next session.")
            }
        }
    }
}

$summary = [pscustomobject]@{
    root = $rootPath
    planPath = $resolvedPlanPath
    worklogPath = $resolvedWorklogPath
    mode = $Mode
    errorCount = @($findings | Where-Object { $_.severity -eq "error" }).Count
    warnCount = @($findings | Where-Object { $_.severity -eq "warn" }).Count
    findings = @($findings)
}

if ($EmitJson) {
    $summary | ConvertTo-Json -Depth 5
    exit ([int]($summary.errorCount -gt 0))
}

Write-Host "Session Guard Check"
Write-Host "Root: $($summary.root)"
Write-Host "Plan: $($summary.planPath)"
if ($summary.worklogPath) {
    Write-Host "Worklog: $($summary.worklogPath)"
}
Write-Host "Mode: $($summary.mode)"
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
