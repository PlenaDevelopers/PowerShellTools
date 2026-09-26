<#
    Copyright: (c) PowerTool Team - 2026
    Function: Generic Workstation Setup
    Description: Generic starter script for a standard workstation setup without customer-specific data.
#>

$ErrorActionPreference = 'Continue'

$stylePath = Join-Path -Path $PSScriptRoot -ChildPath 'lib\PowerToolStyle.ps1'
if (Test-Path -LiteralPath $stylePath) {
    . $stylePath
}

Initialize-PowerToolConsole

function Test-PowerToolAdmin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Invoke-PowerToolStep {
    param(
        [Parameter(Mandatory)][string]$Title,
        [Parameter(Mandatory)][string]$ScriptName,
        [hashtable]$Arguments = @{}
    )

    $scriptPath = Join-Path -Path $PSScriptRoot -ChildPath $ScriptName
    Write-PowerToolStatus -Type Step -Message $Title

    if (-not (Test-Path -LiteralPath $scriptPath)) {
        Write-PowerToolStatus -Type Warning -Message "Skipped: $ScriptName was not found."
        return
    }

    try {
        & $scriptPath @Arguments
        Write-PowerToolStatus -Type Success -Message "$Title completed."
    }
    catch {
        Write-PowerToolStatus -Type Error -Message "$Title failed: $($_.Exception.Message)"
    }
}

if (-not (Test-PowerToolAdmin)) {
    Start-Process -FilePath 'powershell.exe' -ArgumentList ('-NoProfile -ExecutionPolicy Bypass -File "{0}"' -f $MyInvocation.MyCommand.Path) -Verb RunAs
    exit
}

Set-Location -LiteralPath $PSScriptRoot

Write-PowerToolSection -Title 'Generic Workstation Setup'
Write-PowerToolItem -Label 'Computer' -Value $env:COMPUTERNAME -Color White
Write-PowerToolItem -Label 'Script' -Value $MyInvocation.MyCommand.Path -Color Gray

$defaultWallpaper = Join-Path -Path $PSScriptRoot -ChildPath 'wallpaper\wallpaper_default.jpg'
$anyDeskPassword = 'ChangeMe!123'
$userDisplayName = 'Generic User'
$rdpItems = @(
    @{ file_name = 'Example Server.rdp'; server = '192.0.2.10' }
)

Write-PowerToolSection -Title 'Routine'
Invoke-PowerToolStep -Title 'System backup' -ScriptName 'tool_start_backup.ps1'
Invoke-PowerToolStep -Title 'Repair desktop' -ScriptName 'tool_repair_desktop.ps1'
Invoke-PowerToolStep -Title 'Clean temporary files' -ScriptName 'tool_remove_files_temporary.ps1'
Invoke-PowerToolStep -Title 'Set NTP server' -ScriptName 'tool_set_server_ntp.ps1'
Invoke-PowerToolStep -Title 'Remove live tiles' -ScriptName 'tool_remove_tiles_live.ps1'
Invoke-PowerToolStep -Title 'Set user display name' -ScriptName 'tool_set_user_name.ps1' -Arguments @{ nome = $userDisplayName }
Invoke-PowerToolStep -Title 'Set AnyDesk password' -ScriptName 'tool_set_anydesk_password.ps1' -Arguments @{ senha = $anyDeskPassword }

if (Test-Path -LiteralPath $defaultWallpaper) {
    Invoke-PowerToolStep -Title 'Set desktop wallpaper' -ScriptName 'tool_set_desktop_background.ps1' -Arguments @{ imagem = $defaultWallpaper }
    Invoke-PowerToolStep -Title 'Set logon background' -ScriptName 'tool_set_background_logon.ps1' -Arguments @{ imagem = $defaultWallpaper }
}
else {
    Write-PowerToolStatus -Type Warning -Message 'Default wallpaper not found; wallpaper steps skipped.'
}

foreach ($item in $rdpItems) {
    Invoke-PowerToolStep -Title "Create RDP file: $($item.file_name)" -ScriptName 'tool_set_file_rdp.ps1' -Arguments @{
        nome_arquivo_rdp = $item.file_name
        rdp_server = $item.server
    }
}

Write-PowerToolSection -Title 'Result'
Write-PowerToolStatus -Type Success -Message 'Generic workstation setup finished.'
