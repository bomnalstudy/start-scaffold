[CmdletBinding()]
param()

$root = Split-Path -Parent $PSScriptRoot
$localDir = Join-Path $root ".local"
$handoffDir = Join-Path $root "handoff"
$worklogDir = Join-Path $root "worklogs"
$graveyardDir = Join-Path $root ".graveyard"
$graveyardFilesDir = Join-Path $graveyardDir "files"
$graveyardNotesDir = Join-Path $graveyardDir "notes"
$secretsPath = Join-Path $localDir "project.secrets.env"
$secretsExamplePath = Join-Path $root "templates\.env.local.example"
$journalExamplePath = Join-Path $root "templates\journal-entry.md"

New-Item -ItemType Directory -Force -Path $localDir | Out-Null
New-Item -ItemType Directory -Force -Path $handoffDir | Out-Null
New-Item -ItemType Directory -Force -Path $worklogDir | Out-Null
New-Item -ItemType Directory -Force -Path $graveyardFilesDir | Out-Null
New-Item -ItemType Directory -Force -Path $graveyardNotesDir | Out-Null

if (-not (Test-Path $secretsPath)) {
    Copy-Item -LiteralPath $secretsExamplePath -Destination $secretsPath
    Write-Host "Created local secrets file: $secretsPath"
} else {
    Write-Host "Local secrets file already exists: $secretsPath"
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
Write-Host "1. Fill in .local/project.secrets.env"
Write-Host "2. Run .\scripts\load-project-secrets.ps1"
Write-Host "3. Read AGENTS.md and docs\workflow.md"
Write-Host "4. Archive retired files with .\scripts\archive-to-graveyard.ps1"
