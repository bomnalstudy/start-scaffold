[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

function Fail {
    param([string]$Message)
    Write-Host ""
    Write-Host "[BLOCKED] pre-push: $Message"
    exit 1
}

function Get-DefaultProfile {
    $name = [Environment]::GetEnvironmentVariable("PROJECT_NAME", "Process")
    if ([string]::IsNullOrWhiteSpace($name)) {
        $name = Split-Path -Leaf (Get-Location).Path
    }
    if ([string]::IsNullOrWhiteSpace($name)) {
        return "default"
    }
    return $name.ToLowerInvariant()
}

$root = (Get-Location).Path
$profile = Get-DefaultProfile
$localPath = Join-Path $root ".local\secrets\$profile.env"
$vaultPath = Join-Path $root "secure-secrets\$profile.vault.json"

if (-not (Test-Path -LiteralPath $localPath)) {
    exit 0
}

if (-not (Test-Path -LiteralPath $vaultPath)) {
    Fail "Missing encrypted vault for profile '$profile'. Run: .\scripts\export-project-secrets.ps1 -Profile $profile"
}

$localTime = (Get-Item -LiteralPath $localPath).LastWriteTimeUtc
$vaultTime = (Get-Item -LiteralPath $vaultPath).LastWriteTimeUtc

if ($localTime -gt $vaultTime.AddSeconds(1)) {
    Fail "Local secrets are newer than encrypted vault for profile '$profile'. Export and commit vault before push."
}

$status = git status --porcelain -- "secure-secrets/$profile.vault.json"
if ($LASTEXITCODE -ne 0) {
    Fail "Failed to inspect git status for encrypted vault."
}
if (-not [string]::IsNullOrWhiteSpace($status)) {
    Fail "Encrypted vault has uncommitted changes. Commit secure-secrets/$profile.vault.json before push."
}

exit 0
