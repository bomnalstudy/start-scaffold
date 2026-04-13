[CmdletBinding()]
param()

$scriptsRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$root = Split-Path -Parent $scriptsRoot
$localDir = Join-Path $root ".local"
$localSecretsDir = Join-Path $localDir "secrets"
$handoffDir = Join-Path $root "handoff"
$secureSecretsDir = Join-Path $root "secure-secrets"
$worklogDir = Join-Path $root "worklogs"
$graveyardDir = Join-Path $root ".graveyard"
$graveyardFilesDir = Join-Path $graveyardDir "files"
$graveyardNotesDir = Join-Path $graveyardDir "notes"
$projectName = [Environment]::GetEnvironmentVariable("PROJECT_NAME", "Process")
if ([string]::IsNullOrWhiteSpace($projectName)) {
    $projectName = [System.IO.Path]::GetFileName($root)
}
if ([string]::IsNullOrWhiteSpace($projectName)) {
    $projectName = "default"
}
$profile = $projectName.ToLowerInvariant()
$secretsPath = Join-Path $localSecretsDir "$profile.env"
$secretsExamplePath = Join-Path $root "templates\.env.local.example"
$journalExamplePath = Join-Path $root "templates\journal-entry.md"

New-Item -ItemType Directory -Force -Path $localDir | Out-Null
New-Item -ItemType Directory -Force -Path $localSecretsDir | Out-Null
New-Item -ItemType Directory -Force -Path $handoffDir | Out-Null
New-Item -ItemType Directory -Force -Path $secureSecretsDir | Out-Null
New-Item -ItemType Directory -Force -Path $worklogDir | Out-Null
New-Item -ItemType Directory -Force -Path $graveyardFilesDir | Out-Null
New-Item -ItemType Directory -Force -Path $graveyardNotesDir | Out-Null

if (-not (Test-Path $secretsPath)) {
    Copy-Item -LiteralPath $secretsExamplePath -Destination $secretsPath
    Write-Host "Created local secrets file: $secretsPath (profile: $profile)"
} else {
    Write-Host "Local secrets file already exists: $secretsPath (profile: $profile)"
}

$today = Get-Date -Format "yyyy-MM-dd"
$initialLogPath = Join-Path $worklogDir "$today-bootstrap.md"

if (-not (Test-Path $initialLogPath)) {
    Copy-Item -LiteralPath $journalExamplePath -Destination $initialLogPath
    Write-Host "Created initial worklog: $initialLogPath"
} else {
    Write-Host "Worklog already exists: $initialLogPath"
}

Write-Host ""
Write-Host "Next steps:"
Write-Host "1. Fill in .local/secrets/$profile.env"
Write-Host "2. Run .\scripts\powershell\secrets\export-project-secrets.ps1 -Profile $profile"
Write-Host "3. Run .\scripts\powershell\secrets\load-project-secrets.ps1 -Profile $profile"
Write-Host "4. Read AGENTS.md and docs\workflow.md"
Write-Host "5. Archive retired files with .\scripts\powershell\cleanup\archive-to-graveyard.ps1"
