[CmdletBinding()]
param(
    [string]$Root = (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))),
    [string]$SourcePath = "templates/project-context.source.json",
    [string]$OutputPath = "docs/project-context.md",
    [string]$CompactOutputPath = "docs/project-context.compact.md"
)

$ErrorActionPreference = "Stop"

function Resolve-InRoot {
    param(
        [string]$BaseRoot,
        [string]$PathValue
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return $PathValue
    }

    return (Join-Path $BaseRoot $PathValue)
}

function Get-DetectedServerCandidates {
    param([string]$BaseRoot)

    $patterns = @(
        "server.ts", "server.js", "main.py", "app.py",
        "*api*server*.ts", "*api*server*.js",
        "src/server/index.ts", "src/server/index.js",
        "src/api/index.ts", "src/api/index.js"
    )

    $candidates = @()
    foreach ($pattern in $patterns) {
        $matches = Get-ChildItem -Path $BaseRoot -Recurse -File -Filter $pattern -ErrorAction SilentlyContinue
        foreach ($m in $matches) {
            $relative = $m.FullName.Substring($BaseRoot.Length).TrimStart('\', '/')
            $candidates += $relative
        }
    }

    $candidates | Sort-Object -Unique
}

function Get-PackageScriptLines {
    param([string]$BaseRoot)

    $pkgPath = Join-Path $BaseRoot "package.json"
    if (-not (Test-Path -LiteralPath $pkgPath)) {
        return @()
    }

    try {
        $pkg = Get-Content -LiteralPath $pkgPath -Raw | ConvertFrom-Json
        if ($null -eq $pkg.scripts) {
            return @()
        }

        $lines = @()
        foreach ($prop in $pkg.scripts.PSObject.Properties) {
            $lines += ('- `{0}`: {1}' -f $prop.Name, $prop.Value)
        }
        return $lines
    } catch {
        return @("- Failed to parse package.json scripts.")
    }
}

$rootPath = (Resolve-Path -LiteralPath $Root).Path
$resolvedSourcePath = Resolve-InRoot -BaseRoot $rootPath -PathValue $SourcePath
$resolvedOutputPath = Resolve-InRoot -BaseRoot $rootPath -PathValue $OutputPath
$resolvedCompactOutputPath = Resolve-InRoot -BaseRoot $rootPath -PathValue $CompactOutputPath

if (-not (Test-Path -LiteralPath $resolvedSourcePath)) {
    throw "Source context file not found: $resolvedSourcePath"
}

$source = Get-Content -LiteralPath $resolvedSourcePath -Raw | ConvertFrom-Json
$detectedServers = Get-DetectedServerCandidates -BaseRoot $rootPath
$scriptLines = Get-PackageScriptLines -BaseRoot $rootPath
$generatedAt = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$doc = New-Object System.Collections.Generic.List[string]
$doc.Add("# Project Context")
$doc.Add("")
$doc.Add("_Generated automatically by `scripts/powershell/context/build-project-context.ps1` at $generatedAt._")
$doc.Add("")
$doc.Add("## Project")
$doc.Add("")
$doc.Add("- Name: $($source.project.name)")
$doc.Add("- Summary: $($source.project.summary)")
$doc.Add("")
$doc.Add("## Server Guide")
$doc.Add("")

foreach ($server in $source.servers) {
    $doc.Add("### $($server.name)")
    $doc.Add("")
    $doc.Add("- When to use: $($server.when_to_use)")
    $doc.Add(('- Start command: `{0}`' -f $server.start_command))
    $doc.Add("- Healthcheck: $($server.healthcheck)")
    $doc.Add("- Notes: $($server.notes)")
    $doc.Add("")
}

$doc.Add("## Data Routes")
$doc.Add("")
foreach ($route in $source.data_routes) {
    $doc.Add("### $($route.concern)")
    $doc.Add("")
    $doc.Add(('- Root file: `{0}`' -f $route.root_file))
    if ($route.entry_points -and $route.entry_points.Count -gt 0) {
        $doc.Add("- Entry points:")
        foreach ($entry in $route.entry_points) {
            $doc.Add(('  - `{0}`' -f $entry))
        }
    } else {
        $doc.Add("- Entry points: none")
    }
    $doc.Add("- Notes: $($route.notes)")
    $doc.Add("")
}

$doc.Add("## Critical Files")
$doc.Add("")
foreach ($file in $source.critical_files) {
    $doc.Add(('- `{0}`: {1}' -f $file.path, $file.role))
}
$doc.Add("")

$doc.Add("## Session Defaults")
$doc.Add("")
$doc.Add("- Preferred agent: $($source.session_defaults.preferred_agent)")
$doc.Add("- Default context pack: $($source.session_defaults.default_context_pack)")
$doc.Add("- Must confirm before scope expansion: $($source.session_defaults.must_confirm_before_expand_scope)")
$doc.Add("")

$doc.Add("## Auto-Detected Hints")
$doc.Add("")
$doc.Add("### Server Candidate Files")
if ($detectedServers.Count -eq 0) {
    $doc.Add("- none detected")
} else {
    foreach ($c in $detectedServers) {
        $doc.Add(('- `{0}`' -f $c))
    }
}
$doc.Add("")
$doc.Add("### Package Scripts")
if ($scriptLines.Count -eq 0) {
    $doc.Add("- none detected")
} else {
    foreach ($line in $scriptLines) {
        $doc.Add($line)
    }
}
$doc.Add("")
$doc.Add("## Compact Hand-off Note")
$doc.Add("")
$doc.Add("- If you start a new chat, read `docs/project-context.compact.md` first.")
$doc.Add("- Keep this file updated whenever server/data roots change.")

$compact = New-Object System.Collections.Generic.List[string]
$compact.Add("# Project Context Compact")
$compact.Add("")
$compact.Add("_Generated automatically by `scripts/powershell/context/build-project-context.ps1` at $generatedAt._")
$compact.Add("")
$compact.Add("## Always Remember")
$compact.Add("")
$compact.Add("- Project: $($source.project.name)")
$compact.Add("- Summary: $($source.project.summary)")
$compact.Add("- Preferred agent: $($source.session_defaults.preferred_agent)")
$compact.Add("- Default context pack: $($source.session_defaults.default_context_pack)")
$compact.Add("")
$compact.Add("## Which Server To Open")
$compact.Add("")
foreach ($server in $source.servers) {
    $compact.Add(('- {0}: {1} / `{2}`' -f $server.name, $server.when_to_use, $server.start_command))
}
$compact.Add("")
$compact.Add("## Data Root Reminders")
$compact.Add("")
foreach ($route in $source.data_routes) {
    $compact.Add(('- {0}: `{1}`' -f $route.concern, $route.root_file))
}
$compact.Add("")
$compact.Add("## Critical Files")
$compact.Add("")
foreach ($file in $source.critical_files) {
    $compact.Add(('- `{0}`' -f $file.path))
}
$compact.Add("")
$compact.Add("## Scope Guard")
$compact.Add("")
$compact.Add("- Stay within MVP scope.")
$compact.Add("- Do not expand scope without explicit confirmation.")
$compact.Add("- Re-check `Original Goal` before each major edit.")

New-Item -ItemType Directory -Force -Path (Split-Path -Parent $resolvedOutputPath) | Out-Null
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $resolvedCompactOutputPath) | Out-Null

Set-Content -LiteralPath $resolvedOutputPath -Value $doc -Encoding UTF8
Set-Content -LiteralPath $resolvedCompactOutputPath -Value $compact -Encoding UTF8

Write-Host "Generated: $resolvedOutputPath"
Write-Host "Generated: $resolvedCompactOutputPath"
