[CmdletBinding()]
param(
    [string]$Root = (Split-Path -Parent $PSScriptRoot),
    [int]$MaxLines = 500,
    [string[]]$SourceExtensions = @(".js", ".jsx", ".ts", ".tsx", ".css", ".scss", ".less", ".html", ".json", ".md", ".ps1", ".py"),
    [switch]$EmitJson
)

$ErrorActionPreference = "Stop"

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

$rootPath = (Resolve-Path -LiteralPath $Root).Path
$findings = @()

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

    if ($lineCount -gt $MaxLines) {
        $findings += (New-Finding -Rule "max-lines" -Severity "error" -Path $relativePath -Message "File has $lineCount lines. Limit is $MaxLines.")
    } elseif ($lineCount -gt 300) {
        $findings += (New-Finding -Rule "line-budget-warning" -Severity "warn" -Path $relativePath -Message "File has $lineCount lines. Consider splitting before it reaches $MaxLines.")
    }

    if ($normalizedExtension -in @(".jsx", ".tsx", ".js", ".ts")) {
        if ($content -match 'style\s*=\s*\{\{') {
            $findings += (New-Finding -Rule "inline-style" -Severity "error" -Path $relativePath -Message "Inline style object detected. Move styles to a colocated CSS file.")
        }

        if ($content -match '@import\s+["''][^"'']+\.css["'']') {
            $findings += (New-Finding -Rule "css-import-style" -Severity "warn" -Path $relativePath -Message "Global CSS import found in source file. Confirm this belongs in a top-level entry file.")
        }
    }

    if ($relativePath -match '(^|\\)utils(\\|/)?index\.(ts|tsx|js|jsx)$') {
        $exportCount = ([regex]::Matches($content, 'export\s+')).Count
        if ($exportCount -gt 15) {
            $findings += (New-Finding -Rule "large-utils-index" -Severity "warn" -Path $relativePath -Message "Utils barrel exports $exportCount items. This can become a catch-all entrypoint.")
        }
    }

    $graveyardReferenceAllowed = $relativePath -in @(
        "scripts\archive-to-graveyard.ps1",
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
