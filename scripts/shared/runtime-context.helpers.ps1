function Get-RuntimeContext {
    [CmdletBinding()]
    param(
        [string]$Agent = "unknown"
    )

    $platform = "unknown"

    if (Get-Variable -Name IsWindows -ErrorAction SilentlyContinue) {
        if ($IsWindows) {
            $platform = "windows"
        } elseif ($IsLinux) {
            $platform = "linux"
        } elseif ($IsMacOS) {
            $platform = "macos"
        }
    }

    if ($platform -eq "unknown") {
        try {
            $osDescription = [System.Runtime.InteropServices.RuntimeInformation]::OSDescription
            if ($osDescription -match "(?i)windows") {
                $platform = "windows"
            } elseif ($osDescription -match "(?i)linux") {
                $platform = "linux"
            } elseif ($osDescription -match "(?i)darwin|mac|osx") {
                $platform = "macos"
            }
        } catch {
        }
    }

    $isWsl = $false
    if ($platform -eq "linux") {
        if ($env:WSL_DISTRO_NAME) {
            $isWsl = $true
        } elseif (Test-Path "/proc/version") {
            try {
                $procVersion = Get-Content -LiteralPath "/proc/version" -Raw
                if ($procVersion -match "(?i)microsoft|wsl") {
                    $isWsl = $true
                }
            } catch {
            }
        }
    }

    $shell = if ($PSVersionTable.PSEdition -eq "Core") {
        "pwsh"
    } elseif ($platform -eq "windows") {
        "powershell.exe"
    } else {
        "unknown"
    }

    $environmentPattern = if ($platform -eq "linux" -or $isWsl) {
        "powershell-bridged"
    } else {
        "powershell-bridged"
    }

    [pscustomobject]@{
        agent = $Agent
        platform = $platform
        isWsl = $isWsl
        shell = $shell
        environmentPattern = $environmentPattern
    }
}

function Write-RuntimeContextBanner {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [psobject]$Context
    )

    Write-Host "Runtime Context"
    Write-Host "Agent: $($Context.agent)"
    Write-Host "Platform: $($Context.platform)"
    Write-Host "WSL: $($Context.isWsl)"
    Write-Host "Shell: $($Context.shell)"
    Write-Host "Environment Pattern: $($Context.environmentPattern)"
}
