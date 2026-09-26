$stylePath = Join-Path -Path $PSScriptRoot -ChildPath 'lib\PowerToolStyle.ps1'
if (Test-Path -LiteralPath $stylePath) { . $stylePath }
<#
    Copyright: (c) Flex IT - 2026
    Function: Start
    Description: PowerTool menu for running de routine scripts, standalone scripts, and framework utilities.
#>

function Initialize-PowerToolMenu {
    Set-Variable -Name ConfirmPreference -Value 'None' -Scope Global
    Set-Variable -Name WhatIfPreference -Value $false -Scope Global
    Set-Variable -Name ProgressPreference -Value 'SilentlyContinue' -Scope Global

    try {
        Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force -Confirm:$false
        Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser -Force -Confirm:$false
    }
    catch { }

    try {
        if ($Host.Name -match 'ConsoleHost') {
            $desiredWidth = 124
            $raw = $Host.UI.RawUI
            $buffer = $raw.BufferSize
            if ($buffer.Width -lt $desiredWidth) {
                $buffer.Width = $desiredWidth
                $raw.BufferSize = $buffer
            }
            $window = $raw.WindowSize
            $maxWidth = $raw.MaxPhysicalWindowSize.Width
            if ($maxWidth -gt 0 -and $window.Width -lt $desiredWidth) {
                $window.Width = [Math]::Min($desiredWidth, $maxWidth)
                $raw.WindowSize = $window
            }
        }
    }
    catch { }
}

function Test-PowerToolAdmin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-PowerToolLabel {
    param([System.IO.FileInfo]$Script)

    try {
        $header = Get-Content -LiteralPath $Script.FullName -TotalCount 20 -ErrorAction Stop
        $funcao = $header | Where-Object { $_ -match '^\s*(Funcao|Function)\s*:\s*(.+)$' } | Select-Object -First 1
        if ($funcao) {
            $label = ($funcao -replace '^\s*(Funcao|Function)\s*:\s*', '').Trim()
            $label = $label -replace '^(Script|Sc)\s+', ''
            return $label.Trim()
        }
    }
    catch { }

    return $Script.BaseName.Replace('_', ' ')
}

function Get-PowerToolRelativePath {
    param(
        [System.IO.FileInfo]$Script,
        [string]$BasePath
    )

    $baseFull = [System.IO.Path]::GetFullPath($BasePath).TrimEnd('\', '/')
    $scriptFull = [System.IO.Path]::GetFullPath($Script.FullName)
    if ($scriptFull.StartsWith($baseFull, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $scriptFull.Substring($baseFull.Length).TrimStart('\', '/')
    }
    return $Script.Name
}

function Invoke-PowerToolScript {
    param([System.IO.FileInfo]$Script)

    Clear-Host
    Write-Host "+------------------------------------------------------------------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host ("| Running: {0}" -f $Script.FullName) -ForegroundColor Cyan
    Write-Host "+------------------------------------------------------------------------------------------------------------------------+" -ForegroundColor Cyan

    $arguments = @(
        '-NoProfile',
        '-ExecutionPolicy', 'Bypass',
        '-File', ('"{0}"' -f $Script.FullName)
    ) -join ' '

    try {
        $process = Start-Process -FilePath 'powershell.exe' -ArgumentList $arguments -WorkingDirectory $Script.DirectoryName -Wait -PassThru
        Write-Host
        Write-Host ("Exit code: {0}" -f $process.ExitCode) -ForegroundColor Yellow
    }
    catch {
        Write-Host ("Failed to run script: {0}" -f $_.Exception.Message) -ForegroundColor Red
    }

    Write-Host
    Read-Host "Press ENTER to return to the menu"
}

function Show-PowerToolScriptMenu {
    param(
        [string]$Title,
        [System.IO.FileInfo[]]$Scripts,
        [string]$BasePath
    )

    while ($true) {
        Clear-Host
        Write-Host "+------------------------------------------------------------------------------------------------------------------------+" -ForegroundColor Yellow
        Write-Host ("| {0}" -f $Title) -ForegroundColor Yellow
        Write-Host "+------------------------------------------------------------------------------------------------------------------------+" -ForegroundColor Yellow

        if (-not $Scripts -or $Scripts.Count -eq 0) {
            Write-Host "No scripts found." -ForegroundColor Red
            Write-Host
            Read-Host "Press ENTER to return"
            return
        }

        $Scripts = @($Scripts) | Sort-Object @{ Expression = { Get-PowerToolLabel -Script $_ } }, Name

        for ($i = 0; $i -lt $Scripts.Count; $i++) {
            $script = $Scripts[$i]
            $label = (Get-PowerToolLabel -Script $script).ToUpperInvariant()
            $relative = Get-PowerToolRelativePath -Script $script -BasePath $BasePath
            Write-Host ("{0,3}. {1} ({2})" -f ($i + 1), $label, $relative) -ForegroundColor White
        }

        Write-Host
        Write-Host "  0. Back" -ForegroundColor DarkGray
        Write-Host
        $option = Read-Host "Choose an option"

        if ($option -eq '0') { return }
        $selected = 0
        if (-not [int]::TryParse($option, [ref]$selected)) { continue }
        if ($selected -lt 1 -or $selected -gt $Scripts.Count) { continue }

        Invoke-PowerToolScript -Script $Scripts[$selected - 1]
    }
}

function Show-PowerToolMainMenu {
    param([string]$RootPath)

    $extrasPath = Join-Path -Path $RootPath -ChildPath 'extras'
    $frameworkPath = Join-Path -Path $RootPath -ChildPath 'updates\framework'

    while ($true) {
        Clear-Host
        Write-Host "+------------------------------------------------------------------------------------------------------------------------+" -ForegroundColor Cyan
        Write-Host "| PowerTool - Execution Menu" -ForegroundColor Cyan
        Write-Host "+------------------------------------------------------------------------------------------------------------------------+" -ForegroundColor Cyan
        Write-Host "  1. Setup scripts" -ForegroundColor White
        Write-Host "  2. Scripts in extras" -ForegroundColor White
        Write-Host "  3. Scripts in updates/framework" -ForegroundColor White
        Write-Host "  0. Exit" -ForegroundColor DarkGray
        Write-Host

        $option = Read-Host "Choose an option"

        switch ($option) {
            '1' {
                $scripts = Get-ChildItem -LiteralPath $RootPath -Filter 'setup_*.ps1' -File
                Show-PowerToolScriptMenu -Title 'Setup scripts' -Scripts $scripts -BasePath $RootPath
            }
            '2' {
                $scripts = if (Test-Path -LiteralPath $extrasPath) {
                    Get-ChildItem -LiteralPath $extrasPath -Filter '*.ps1' -File -Recurse
                } else { @() }
                Show-PowerToolScriptMenu -Title 'Scripts in extras' -Scripts $scripts -BasePath $extrasPath
            }
            '3' {
                $scripts = if (Test-Path -LiteralPath $frameworkPath) {
                    Get-ChildItem -LiteralPath $frameworkPath -Filter '*.ps1' -File
                } else { @() }
                Show-PowerToolScriptMenu -Title 'Scripts in updates/framework' -Scripts $scripts -BasePath $frameworkPath
            }
            '0' { return }
            default { continue }
        }
    }
}

Initialize-PowerToolMenu

if (-not (Test-PowerToolAdmin)) {
    Start-Process -FilePath 'powershell.exe' -ArgumentList ('-NoProfile -ExecutionPolicy Bypass -File "{0}"' -f $MyInvocation.MyCommand.Path) -Verb RunAs
    exit
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location -LiteralPath $scriptDir
Show-PowerToolMainMenu -RootPath $scriptDir
