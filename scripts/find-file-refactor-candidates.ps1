[CmdletBinding()]
param(
    [string]$Root = (Split-Path -Parent $PSScriptRoot),
    [switch]$ApplyHighConfidenceArchive,
    [switch]$EmitJson
)

$ErrorActionPreference = "Stop"

function New-Candidate {
    param(
        [string]$Type,
        [string]$Confidence,
        [string]$Path,
        [string]$Reason,
        [string[]]$Evidence = @()
    )

    [pscustomobject]@{
        type = $Type
        confidence = $Confidence
        path = $Path
        reason = $Reason
        evidence = @($Evidence)
    }
}

function Get-RelativePath {
    param(
        [string]$BasePath,
        [string]$TargetPath
    )

    $baseFull = [System.IO.Path]::GetFullPath($BasePath)
    $targetFull = [System.IO.Path]::GetFullPath($TargetPath)
    if (-not $baseFull.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
        $baseFull += [System.IO.Path]::DirectorySeparatorChar
    }

    $baseUri = [System.Uri]::new($baseFull)
    $targetUri = [System.Uri]::new($targetFull)
    return [System.Uri]::UnescapeDataString($baseUri.MakeRelativeUri($targetUri).ToString()).Replace('/', [System.IO.Path]::DirectorySeparatorChar)
}

function Get-TextHash {
    param([string]$Path)

    $content = Get-Content -LiteralPath $Path -Raw
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($content)
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        return ([System.BitConverter]::ToString($sha.ComputeHash($bytes))).Replace("-", "").ToLowerInvariant()
    } finally {
        $sha.Dispose()
    }
}

$rootPath = (Resolve-Path -LiteralPath $Root).Path
$candidates = New-Object System.Collections.Generic.List[object]
$archiveScript = Join-Path $rootPath "scripts/archive-to-graveyard.ps1"
$cleanupRoots = @(
    (Join-Path $rootPath "skills"),
    (Join-Path $rootPath "scripts"),
    (Join-Path $rootPath "templates"),
    (Join-Path $rootPath "harness")
)

# High confidence: deprecated alias skill files
$deprecatedSkillFiles = Get-ChildItem -LiteralPath (Join-Path $rootPath "skills") -Recurse -Filter SKILL.md -File | Where-Object {
    (Get-Content -LiteralPath $_.FullName -Raw) -match 'Deprecated compatibility alias'
}

foreach ($file in $deprecatedSkillFiles) {
    $relative = Get-RelativePath -BasePath $rootPath -TargetPath $file.FullName
    $candidates.Add((New-Candidate -Type "deprecated-alias-skill" -Confidence "high" -Path $relative -Reason "Deprecated compatibility alias with a shared replacement exists." -Evidence @("Marked as deprecated compatibility alias.")))
}

# High confidence: empty folders in managed roots
foreach ($cleanupRoot in $cleanupRoots) {
    if (-not (Test-Path -LiteralPath $cleanupRoot)) { continue }
    $directories = Get-ChildItem -LiteralPath $cleanupRoot -Recurse -Directory | Sort-Object FullName -Descending
    foreach ($directory in $directories) {
        $children = Get-ChildItem -LiteralPath $directory.FullName -Force
        if ($children.Count -eq 0) {
            $relative = Get-RelativePath -BasePath $rootPath -TargetPath $directory.FullName
            $candidates.Add((New-Candidate -Type "empty-folder" -Confidence "high" -Path $relative -Reason "Empty folder left behind after refactor or rename."))
        }
    }
}

# Medium confidence: small duplicate-content files
$hashGroups = @{}
$hashableFiles = Get-ChildItem -LiteralPath $rootPath -Recurse -File | Where-Object {
    $_.FullName -notmatch '\\\.git\\' -and
    $_.FullName -notmatch '\\\.graveyard\\' -and
    $_.FullName -notmatch '\\worklogs\\' -and
    $_.Length -le 8192 -and
    $_.Extension.ToLowerInvariant() -in @(".ps1", ".md", ".ts", ".tsx", ".js", ".jsx", ".json", ".yaml", ".yml")
}

foreach ($file in $hashableFiles) {
    try {
        $hash = Get-TextHash -Path $file.FullName
        if (-not $hashGroups.ContainsKey($hash)) {
            $hashGroups[$hash] = New-Object System.Collections.Generic.List[string]
        }
        $hashGroups[$hash].Add($file.FullName)
    } catch {
        continue
    }
}

foreach ($hash in $hashGroups.Keys) {
    $group = $hashGroups[$hash]
    if ($group.Count -lt 2) { continue }

    $relativePaths = $group | ForEach-Object { Get-RelativePath -BasePath $rootPath -TargetPath $_ }
    foreach ($relative in $relativePaths) {
        $candidates.Add((New-Candidate -Type "duplicate-content" -Confidence "medium" -Path $relative -Reason "Small file has identical content to another tracked file." -Evidence $relativePaths))
    }
}

$applied = New-Object System.Collections.Generic.List[object]

if ($ApplyHighConfidenceArchive) {
    $candidateSnapshot = foreach ($candidate in $candidates) { $candidate }
    $highConfidence = @($candidateSnapshot) | Where-Object { $_.confidence -eq "high" } | Sort-Object -Property path -Unique
    foreach ($candidate in $highConfidence) {
        $fullPath = Join-Path $rootPath $candidate.path
        if (-not (Test-Path -LiteralPath $fullPath)) { continue }

        if ($candidate.type -eq "deprecated-alias-skill") {
            & $archiveScript -Path $fullPath -Reason $candidate.reason
            $applied.Add([pscustomobject]@{
                type = $candidate.type
                action = "archived"
                path = $candidate.path
            })
            continue
        }

        if ($candidate.type -eq "empty-folder") {
            Remove-Item -LiteralPath $fullPath -Force -Recurse
            $applied.Add([pscustomobject]@{
                type = $candidate.type
                action = "removed-empty-folder"
                path = $candidate.path
            })
        }
    }
}

$candidateArray = foreach ($candidate in $candidates) { $candidate }
$sortedCandidates = @($candidateArray) | Sort-Object -Property confidence, path
$appliedArray = foreach ($item in $applied) { $item }

$summary = [pscustomobject]@{
    root = $rootPath
    candidateCount = @($candidateArray).Count
    candidates = @($sortedCandidates)
    applied = @($appliedArray)
}

if ($EmitJson) {
    $summary | ConvertTo-Json -Depth 6
    exit 0
}

Write-Host "Code Refactor Candidate Scan"
Write-Host "Root: $rootPath"
Write-Host "Candidates: $($summary.candidateCount)"
Write-Host "Applied: $($summary.applied.Count)"
Write-Host ""

if ($summary.candidates.Count -eq 0) {
    Write-Host "No candidates."
    exit 0
}

foreach ($candidate in $summary.candidates) {
    Write-Host "[$($candidate.confidence.ToUpper())] [$($candidate.type)] $($candidate.path)"
    Write-Host "  $($candidate.reason)"
    foreach ($item in $candidate.evidence) {
        Write-Host "  - $item"
    }
}
