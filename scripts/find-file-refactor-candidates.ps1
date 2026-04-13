[CmdletBinding()]
param(
    [string]$Root = (Split-Path -Parent $PSScriptRoot),
    [switch]$ApplyHighConfidenceArchive,
    [switch]$EmitJson
)

$finder = Join-Path $PSScriptRoot "find-code-refactor-candidates.ps1"
& $finder -Root $Root -ApplyHighConfidenceArchive:$ApplyHighConfidenceArchive -EmitJson:$EmitJson
exit $LASTEXITCODE
