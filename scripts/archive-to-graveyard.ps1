[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Path,

    [string]$Reason = "Retired file"
)

$root = Split-Path -Parent $PSScriptRoot
$graveyardFilesDir = Join-Path $root ".graveyard\files"
$graveyardNotesDir = Join-Path $root ".graveyard\notes"

New-Item -ItemType Directory -Force -Path $graveyardFilesDir | Out-Null
New-Item -ItemType Directory -Force -Path $graveyardNotesDir | Out-Null

$resolvedPath = (Resolve-Path -LiteralPath $Path).Path

if (-not (Test-Path -LiteralPath $resolvedPath -PathType Leaf)) {
    throw "Only individual files can be archived: $Path"
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

    $baseUri = New-Object System.Uri($baseFull)
    $targetUri = New-Object System.Uri($targetFull)
    $relativeUri = $baseUri.MakeRelativeUri($targetUri)
    return [System.Uri]::UnescapeDataString($relativeUri.ToString()).Replace('/', [System.IO.Path]::DirectorySeparatorChar)
}

$relativePath = Get-RelativePath -BasePath $root -TargetPath $resolvedPath
$sanitizedRelativePath = $relativePath -replace '[:\\/]', '__'
$fileName = [System.IO.Path]::GetFileName($resolvedPath)
$extension = [System.IO.Path]::GetExtension($resolvedPath)
$fileNameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($resolvedPath)
$archiveBaseName = if ([string]::IsNullOrWhiteSpace($extension)) { $fileName } else { $fileName }
$archivePath = Join-Path $graveyardFilesDir $archiveBaseName
$noteBaseName = if ([string]::IsNullOrWhiteSpace($extension)) {
    $sanitizedRelativePath
} else {
    ($sanitizedRelativePath.Substring(0, $sanitizedRelativePath.Length - $extension.Length) + "__" + $extension.TrimStart('.'))
}
$notePath = Join-Path $graveyardNotesDir ($noteBaseName + ".md")

function Test-IsTextFile {
    param([string]$FilePath)

    try {
        $sample = Get-Content -LiteralPath $FilePath -Raw -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

function Get-CommentStyle {
    param([string]$Extension)

    $normalized = $Extension.ToLowerInvariant()

    switch ($normalized) {
        ".ps1" { return @{ Mode = "Line"; Prefix = "# " } }
        ".psm1" { return @{ Mode = "Line"; Prefix = "# " } }
        ".py" { return @{ Mode = "Line"; Prefix = "# " } }
        ".rb" { return @{ Mode = "Line"; Prefix = "# " } }
        ".sh" { return @{ Mode = "Line"; Prefix = "# " } }
        ".bash" { return @{ Mode = "Line"; Prefix = "# " } }
        ".yml" { return @{ Mode = "Line"; Prefix = "# " } }
        ".yaml" { return @{ Mode = "Line"; Prefix = "# " } }
        ".toml" { return @{ Mode = "Line"; Prefix = "# " } }
        ".ini" { return @{ Mode = "Line"; Prefix = "; " } }
        ".cfg" { return @{ Mode = "Line"; Prefix = "# " } }
        ".conf" { return @{ Mode = "Line"; Prefix = "# " } }
        ".env" { return @{ Mode = "Line"; Prefix = "# " } }
        ".properties" { return @{ Mode = "Line"; Prefix = "# " } }
        ".md" { return @{ Mode = "Line"; Prefix = "[//]: # ("; Suffix = ")" } }
        ".txt" { return @{ Mode = "Line"; Prefix = "# " } }
        ".js" { return @{ Mode = "Block"; Open = "/*"; Close = "*/" } }
        ".jsx" { return @{ Mode = "Block"; Open = "/*"; Close = "*/" } }
        ".ts" { return @{ Mode = "Block"; Open = "/*"; Close = "*/" } }
        ".tsx" { return @{ Mode = "Block"; Open = "/*"; Close = "*/" } }
        ".java" { return @{ Mode = "Block"; Open = "/*"; Close = "*/" } }
        ".c" { return @{ Mode = "Block"; Open = "/*"; Close = "*/" } }
        ".cpp" { return @{ Mode = "Block"; Open = "/*"; Close = "*/" } }
        ".cs" { return @{ Mode = "Block"; Open = "/*"; Close = "*/" } }
        ".css" { return @{ Mode = "Block"; Open = "/*"; Close = "*/" } }
        ".scss" { return @{ Mode = "Block"; Open = "/*"; Close = "*/" } }
        ".less" { return @{ Mode = "Block"; Open = "/*"; Close = "*/" } }
        ".html" { return @{ Mode = "Block"; Open = "<!--"; Close = "-->" } }
        ".xml" { return @{ Mode = "Block"; Open = "<!--"; Close = "-->" } }
        ".svg" { return @{ Mode = "Block"; Open = "<!--"; Close = "-->" } }
        ".json" { return @{ Mode = "Disabled"; Suffix = ".json.disabled" } }
        ".jsonc" { return @{ Mode = "Line"; Prefix = "// " } }
        default {
            if ([string]::IsNullOrWhiteSpace($normalized)) {
                return @{ Mode = "Disabled"; Suffix = ".disabled" }
            }

            return @{ Mode = "Block"; Open = "/*"; Close = "*/" }
        }
    }
}

function Convert-ToCommentedContent {
    param(
        [string]$Content,
        [string]$OriginalPath,
        [string]$Extension
    )

    $style = Get-CommentStyle -Extension $Extension
    $lines = New-Object System.Collections.Generic.List[string]

    if ($style.Mode -eq "Disabled") {
        throw "This file type should be archived as disabled, not commented."
    }

    if ($style.Mode -eq "Block") {
        $lines.Add($style.Open)
        $lines.Add("ARCHIVED FROM: $OriginalPath")
        $lines.Add("THIS FILE HAS BEEN RETIRED AND MUST NOT AFFECT THE CURRENT CODEBASE.")
        $lines.Add("")

        foreach ($line in ($Content -split "`r?`n")) {
            $safeLine = $line
            if ($style.Close -eq "*/") {
                $safeLine = $safeLine -replace '\*/', '* /'
            } elseif ($style.Close -eq "-->") {
                $safeLine = $safeLine -replace '-->', '- ->'
            }

            $lines.Add($safeLine)
        }

        $lines.Add($style.Close)
        return ($lines -join [Environment]::NewLine)
    }

    $prefix = $style.Prefix
    $suffix = if ($style.ContainsKey("Suffix")) { $style.Suffix } else { "" }

    $headerLines = @(
        "ARCHIVED FROM: $OriginalPath",
        "THIS FILE HAS BEEN RETIRED AND MUST NOT AFFECT THE CURRENT CODEBASE.",
        ""
    )

    foreach ($headerLine in $headerLines) {
        $lines.Add("$prefix$headerLine$suffix")
    }

    foreach ($line in ($Content -split "`r?`n")) {
        $safeLine = $line
        if ($suffix) {
            $safeLine = $safeLine -replace '\)', '\)'
        }

        $lines.Add("$prefix$safeLine$suffix")
    }

    return ($lines -join [Environment]::NewLine)
}

if (Test-IsTextFile -FilePath $resolvedPath) {
    $content = Get-Content -LiteralPath $resolvedPath -Raw
    $style = Get-CommentStyle -Extension $extension

    if ($style.Mode -eq "Disabled") {
        $disabledSuffix = if ($style.ContainsKey("Suffix")) { $style.Suffix } else { ".disabled" }
        $archiveFileName = if ([string]::IsNullOrWhiteSpace($extension)) {
            $fileName + $disabledSuffix
        } else {
            $fileNameWithoutExtension + $disabledSuffix
        }
        $archivePath = Join-Path $graveyardFilesDir $archiveFileName

        Set-Content -LiteralPath $archivePath -Value $content -Encoding UTF8
    } else {
        $commentedContent = Convert-ToCommentedContent -Content $content -OriginalPath $relativePath -Extension $extension
        Set-Content -LiteralPath $archivePath -Value $commentedContent -Encoding UTF8
    }
} else {
    if (-not ($archivePath.EndsWith(".disabled"))) {
        $archivePath = $archivePath + ".disabled"
    }

    Copy-Item -LiteralPath $resolvedPath -Destination $archivePath -Force
}

Remove-Item -LiteralPath $resolvedPath -Force

$noteLines = @(
    "# Graveyard Note",
    "",
    "- Original: $relativePath",
    "- Archived: $([System.IO.Path]::GetFileName($archivePath))",
    "- Reason: $Reason",
    "- Archived At: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
)

Set-Content -LiteralPath $notePath -Value $noteLines -Encoding UTF8

Write-Host "Archived retired file to: $archivePath"
Write-Host "Wrote note to: $notePath"
