[CmdletBinding()]
param(
    [string]$Root = (Split-Path -Parent $PSScriptRoot),
    [int]$MaxLines = 500,
    [string[]]$SourceExtensions = @(".js", ".jsx", ".ts", ".tsx", ".css", ".scss", ".less", ".html", ".json", ".md", ".ps1", ".py"),
[switch]$EmitJson
)

$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "run-code-rules.helpers.ps1")
. (Join-Path $PSScriptRoot "run-code-rules.security.ps1")

$rootPath = (Resolve-Path -LiteralPath $Root).Path
$findings = @()
$temporaryFileAllowlist = @(
    "scripts\debug-orchestrator.ps1"
)

$excludedDirectories = @(".graveyard", ".local", "handoff", "node_modules", "dist", "build")

$files = Get-ChildItem -Path $rootPath -Recurse -File | Where-Object {
    $relative = Get-RelativePath -BasePath $rootPath -TargetPath $_.FullName

    foreach ($excludedDir in $excludedDirectories) {
        if ($relative -like "$excludedDir*" -or $relative -like "*\$excludedDir\*") {
            return $false
        }
    }

    $SourceExtensions -contains $_.Extension.ToLowerInvariant()
}

foreach ($file in $files) {
    $relativePath = Get-RelativePath -BasePath $rootPath -TargetPath $file.FullName
    $content = Get-Content -LiteralPath $file.FullName -Raw
    $normalizedExtension = $file.Extension.ToLowerInvariant()
    $lineCount = (Get-Content -LiteralPath $file.FullName).Count
    $normalizedRelativePath = $relativePath.Replace('/', '\')

    if ($lineCount -gt $MaxLines) {
        $findings += (New-Finding -Rule "max-lines" -Severity "error" -Path $relativePath -Message "File has $lineCount lines. Limit is $MaxLines.")
    } elseif ($lineCount -gt 300) {
        $findings += (New-Finding -Rule "line-budget-warning" -Severity "warn" -Path $relativePath -Message "File has $lineCount lines. Consider splitting before it reaches $MaxLines.")
    }

    $looksTemporary = (
        $normalizedRelativePath -match '(^|\\)(tmp|temp|scratch|playground|debug)(\\|$)' -or
        $normalizedRelativePath -match '(^|\\)(tmp-|temp-|scratch-|playground-|debug-)' -or
        $normalizedRelativePath -match '\.(tmp|bak|orig|rej)$'
    )
    if ($looksTemporary -and $normalizedRelativePath -notin $temporaryFileAllowlist) {
        $findings += (New-Finding -Rule "temporary-file" -Severity "warn" -Path $relativePath -Message "Suspicious temporary/debug file name detected. Clean it up or archive it before closing the task.")
    }

    if (($normalizedRelativePath -like "worklogs\*.md" -or $normalizedRelativePath -like "worklogs\tasks\*.md")) {
        if (Test-PlaceholderWorklogPattern -Content $content) {
            $findings += (New-Finding -Rule "placeholder-worklog" -Severity "error" -Path $relativePath -Message "Worklog/task file still looks like an untouched template. Fill it in or remove it.")
        }
    }

    if ($normalizedExtension -in @(".jsx", ".tsx", ".js", ".ts")) {
        if ($content -match 'style\s*=\s*\{\{') {
            $findings += (New-Finding -Rule "inline-style" -Severity "error" -Path $relativePath -Message "Inline style object detected. Move styles to a colocated CSS file.")
        }

        if ($content -match '@import\s+["''][^"'']+\.css["'']') {
            $findings += (New-Finding -Rule "css-import-style" -Severity "warn" -Path $relativePath -Message "Global CSS import found in source file. Confirm this belongs in a top-level entry file.")
        }

        $hasJsxLikeMarkup = ($content -match '<[A-Z][A-Za-z0-9]*' -or $content -match '<div\b' -or $content -match '<section\b')
        $hasFetchLogic = ($content -match '\bfetch\(' -or $content -match '\baxios\.' -or $content -match '\buseQuery\(')
        $hasHeavyState = ($content -match '\buseReducer\(' -or $content -match '\bcreateContext\(' -or $content -match '\buseState\(')
        if ($hasJsxLikeMarkup -and $hasFetchLogic) {
            $findings += (New-Finding -Rule "ui-data-mix" -Severity "warn" -Path $relativePath -Message "UI rendering and data-fetching logic appear mixed in one file. Consider splitting view and data concerns.")
        }
        if ($hasJsxLikeMarkup -and $hasHeavyState -and $lineCount -gt 200) {
            $findings += (New-Finding -Rule "ui-state-mix" -Severity "warn" -Path $relativePath -Message "Large UI file appears to mix rendering and state orchestration. Consider splitting into view and hook/state files.")
        }

        $findings += @(Get-SecurityFindings -RelativePath $relativePath -NormalizedExtension $normalizedExtension -Content $content)
    }

    if ($relativePath -match '(^|\\)utils(\\|/)?index\.(ts|tsx|js|jsx)$') {
        $exportCount = ([regex]::Matches($content, 'export\s+')).Count
        if ($exportCount -gt 15) {
            $findings += (New-Finding -Rule "large-utils-index" -Severity "warn" -Path $relativePath -Message "Utils barrel exports $exportCount items. This can become a catch-all entrypoint.")
        }
    }

    if ($normalizedExtension -eq ".ps1") {
        $functionCount = ([regex]::Matches($content, '(^|\n)\s*function\s+[A-Za-z0-9_-]+', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)).Count
        $hasParamBlock = $content -match '(?s)\[CmdletBinding\(\)\].*?param\('
        if ($functionCount -ge 8 -and $lineCount -gt 220) {
            $findings += (New-Finding -Rule "large-powershell-script" -Severity "warn" -Path $relativePath -Message "Large PowerShell script with many functions detected. Consider splitting helpers from the entry script.")
        }
        if ($hasParamBlock -and $functionCount -ge 6 -and $content -match 'Write-Host' -and $lineCount -gt 180) {
            $findings += (New-Finding -Rule "script-flow-mix" -Severity "warn" -Path $relativePath -Message "Script appears to mix entrypoint flow, reporting, and helper logic in one file. Consider separating reusable logic.")
        }

        $findings += @(Get-SecurityFindings -RelativePath $relativePath -NormalizedExtension $normalizedExtension -Content $content)
    }

    if ($normalizedRelativePath -match 'orchestrator|harness') {
        $hasConfig = ($content -match 'config' -or $content -match 'PlanPath' -or $content -match 'WorklogPath')
        $hasDispatch = ($content -match 'Invoke-' -or $content -match 'switch\s*\(')
        $hasReporting = ($content -match 'Write-Host' -or $content -match 'Write-Step')
        if ($hasConfig -and $hasDispatch -and $hasReporting -and $lineCount -gt 180) {
            $findings += (New-Finding -Rule "orchestrator-responsibility-mix" -Severity "warn" -Path $relativePath -Message "Orchestrator-related file appears to mix config, dispatch, and reporting concerns. Consider splitting the responsibilities.")
        }
    }

    $graveyardReferenceAllowed = $relativePath -in @(
        "scripts\archive-to-graveyard.ps1",
        "scripts\find-code-refactor-candidates.ps1",
        "scripts\find-file-refactor-candidates.ps1",
        "scripts\run-code-rules-checks.ps1"
    )

    if (-not $graveyardReferenceAllowed -and $normalizedExtension -in @(".jsx", ".tsx", ".js", ".ts", ".ps1", ".py") -and $content -match '\.graveyard[\\/]') {
        $findings += (New-Finding -Rule "graveyard-reference" -Severity "error" -Path $relativePath -Message "Active file appears to reference .graveyard content.")
    }

    if ($normalizedExtension -eq ".css" -and $relativePath -notmatch '\.module\.css$') {
        $findings += (New-Finding -Rule "css-module-preferred" -Severity "warn" -Path $relativePath -Message "Plain .css file found. Prefer colocated CSS Modules unless this is intentional global style.")
    }
}

$summary = [pscustomobject]@{
    root = $rootPath
    scannedFiles = $files.Count
    errorCount = @($findings | Where-Object { $_.severity -eq "error" }).Count
    warnCount = @($findings | Where-Object { $_.severity -eq "warn" }).Count
    findings = @($findings)
}

if ($EmitJson) {
    $summary | ConvertTo-Json -Depth 5
    exit ([int]($summary.errorCount -gt 0))
}

Write-Host "Code Rules Check"
Write-Host "Root: $($summary.root)"
Write-Host "Scanned Files: $($summary.scannedFiles)"
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
