<#
    Copyright: (c) Flex IT - 2026
    Function: Restaurar Aparencia
    Description: Script Powershell do pacote PowerTool para execution automated em Windows 10 e Windows 11.
#>

# PowerTool: local presentation without external dependencies
function Initialize-PowerToolConsole {
    Set-Variable -Name ConfirmPreference -Value 'None' -Scope Global
    Set-Variable -Name WhatIfPreference -Value $false -Scope Global
    Set-Variable -Name ProgressPreference -Value 'SilentlyContinue' -Scope Global

    if (-not $global:PowerToolTranscriptActive) {
        try {
            $baseDir = $PSScriptRoot
            if ([string]::IsNullOrWhiteSpace($baseDir)) {
                if ($PSCommandPath) { $baseDir = Split-Path -Parent $PSCommandPath }
                elseif ($MyInvocation.MyCommand.Path) { $baseDir = Split-Path -Parent $MyInvocation.MyCommand.Path }
                else { $baseDir = (Get-Location).Path }
            }
            $logDir = Join-Path -Path $baseDir -ChildPath 'logs'
            if (-not (Test-Path -LiteralPath $logDir)) {
                New-Item -Path $logDir -ItemType Directory -Force -Confirm:$false | Out-Null
            }
            $scriptBase = if ($PSCommandPath) { [System.IO.Path]::GetFileNameWithoutExtension($PSCommandPath) } else { 'PowerTool' }
            $safeScriptBase = $scriptBase -replace '[^A-Za-z0-9_.-]', '_'
            $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
            $logPath = Join-Path -Path $logDir -ChildPath ("PowerTool_{0}_{1}_{2}.log" -f $timestamp, $safeScriptBase, $PID)
            Start-Transcript -Path $logPath -Force -Confirm:$false | Out-Null
            $global:PowerToolTranscriptActive = $true
            $global:PowerToolTranscriptPath = $logPath
            $global:PowerToolTranscriptOwner = $PSCommandPath
        }
        catch {
            $global:PowerToolTranscriptActive = $false
        }
    }
    try {
        $larguraDesejada = 124
        if ($Host.Name -match 'ConsoleHost') {
            $raw = $Host.UI.RawUI
            $buffer = $raw.BufferSize
            if ($buffer.Width -lt $larguraDesejada) {
                $buffer.Width = $larguraDesejada
                $raw.BufferSize = $buffer
            }
            $window = $raw.WindowSize
            $maxWidth = $raw.MaxPhysicalWindowSize.Width
            if ($maxWidth -ge $larguraDesejada -and $window.Width -ne $larguraDesejada) {
                $window.Width = $larguraDesejada
                $raw.WindowSize = $window
            }
            elseif ($window.Width -lt $larguraDesejada -and $maxWidth -gt 0) {
                $window.Width = [Math]::Min($larguraDesejada, $maxWidth)
                $raw.WindowSize = $window
            }
        }
    }
    catch { }
}
function Stop-PowerToolTranscript {
    try {
        if ($global:PowerToolTranscriptActive -and ($global:PowerToolTranscriptOwner -eq $PSCommandPath -or [string]::IsNullOrWhiteSpace($global:PowerToolTranscriptOwner))) {
            Stop-Transcript -Confirm:$false | Out-Null
            $global:PowerToolTranscriptActive = $false
        }
    }
    catch { }
}


function Get-PowerToolWidth {
    try {
        $width = $Host.UI.RawUI.WindowSize.Width - 4
        if ($width -lt 80) { return 120 }
        return [Math]::Min([Math]::Max($width, 96), 160)
    }
    catch { return 120 }
}

function Write-PowerToolBorder {
    param(
        [string]$Left,
        [string]$Right,
        [string]$Color = 'Cyan'
    )
    $width = Get-PowerToolWidth
    Write-Host ($Left + ('-' * $width) + $Right) -ForegroundColor $Color
}

function Write-PowerToolLine {
    param(
        [string]$Campo,
        [string]$Valor,
        [string]$CorValor = 'White',
        [string]$CorBorda = 'Cyan'
    )
    $width = Get-PowerToolWidth
    $labelWidth = 30
    $valueWidth = $width - $labelWidth - 3
    if ($valueWidth -lt 20) { $valueWidth = 20 }
    if ($null -eq $Valor) { $Valor = '' }
    $texto = [string]$Valor
    if ($texto.Length -gt $valueWidth) { $texto = $texto.Substring(0, $valueWidth - 3) + '...' }
    Write-Host ("|{0,-30} : {1}|" -f $Campo, $texto.PadRight($valueWidth)) -ForegroundColor $CorValor
}

function Write-PowerToolHeader {
    param(
        [string]$Script = $MyInvocation.MyCommand.Name,
        [string]$Titulo = 'Process',
        [string]$CopyRight = 'Flex IT'
    )
    Initialize-PowerToolConsole
    $anoAtual = (Get-Date).Year
    Write-PowerToolBorder '+' '+' 'Yellow'
    Write-PowerToolLine 'Operation' $Titulo 'Yellow' 'Yellow'
    Write-PowerToolLine 'Production' $anoAtual 'Yellow' 'Yellow'
    Write-PowerToolLine 'Copyright' $CopyRight 'Yellow' 'Yellow'
    Write-PowerToolLine 'Script' $Script 'White' 'Yellow'
    Write-PowerToolBorder '+' '+' 'Cyan'
}

function Write-PowerToolFooter {
    param(
        [string]$Titulo = 'Process',
        [string]$Status = 'Finished'
    )
    Write-PowerToolBorder '+' '+' 'Cyan'
    Write-PowerToolLine $Titulo $Status 'Green' 'Yellow'
    Write-PowerToolBorder '+' '+' 'Yellow'
    Stop-PowerToolTranscript
}

Initialize-PowerToolConsole


# Header
#----------------------------------------------------------------------------------------------
# Get the current script directory
$scriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path -Parent

# Get the current script name
$scriptName = [System.IO.Path]::GetFileName($MyInvocation.MyCommand.Path)


# Show local header
Write-PowerToolHeader -Script $scriptName -Titulo "Restaurar personalizacoes do Windows"
#----------------------------------------------------------------------------------------------

# Start actions
#----------------------------------------------------------------------------------------------
# Restaurar o papel de parede padrao do Windows
function Restore-Wallpaper {
    $defaultWallpaper = Join-Path $env:SystemRoot "Web\Wallpaper\Windows\img0.jpg"
    Write-PowerToolLine "Wallpaper" $defaultWallpaper "White"
    # Definir o papel de parede usando SystemParametersInfo
    $SPI_SETDESKWALLPAPER = 0x0014
    $UpdateIniFile = 0x01
    $SendWinIniChange = 0x02

    # Definir o papel de parede usando P/Invoke
    $null=Add-Type @"
        using System;
        using System.Runtime.InteropServices;
        public class WallpaperHelper {
            [DllImport("user32.dll", CharSet = CharSet.Auto)]
            public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
        }
"@

    # Chamar a funcao SystemParametersInfo para definir o wallpaper
   [void][WallpaperHelper]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $defaultWallpaper, $UpdateIniFile -bor $SendWinIniChange)
}

# Reverter para o tema padrao do Windows
function Restore-Theme {
    $defaultThemePath = Join-Path $env:SystemRoot "resources\themes\aero.theme"
    Write-PowerToolLine "Tema" $defaultThemePath "White"
    $chave="HKCU:\Software\Microsoft\Windows\CurrentVersion\themes"
    Write-PowerToolLine "Chave" $chave "White"
    $valor="CurrentTheme"
    Write-PowerToolLine "Alterar valor" $valor "White"
    $null=Set-ItemProperty -Path $chave -Name $valor -Value $defaultThemePath -Force

    # Atualizar as configuracoes de usuario
    RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters
}

# Reverter cores de destaque para o padrao
function Restore-Colors {
    $chave="HKCU:\Software\Microsoft\Windows\CurrentVersion\themes\Personalize"
    Write-PowerToolLine "Chave" $chave "White"
    $valor="ColorPrevalence"
    Write-PowerToolLine "Alterar valor" $valor "White"
    $null=Set-ItemProperty -Path $chave -Name $valor -Value 0

    $chave="HKCU:\Software\Microsoft\Windows\CurrentVersion\themes\Personalize"
    Write-PowerToolLine "Chave" $chave "White"
    $valor="AppsUseLightTheme"
    Write-PowerToolLine "Alterar valor" $valor "White"
    $null=Set-ItemProperty -Path $chave -Name $valor -Value 1

    $chave="HKCU:\Software\Microsoft\Windows\CurrentVersion\themes\Personalize"
    Write-PowerToolLine "Chave" $chave "White"
    $valor="SystemUsesLightTheme"
    Write-PowerToolLine "Alterar valor" $valor "White"
    $null=Set-ItemProperty -Path $chave -Name $valor -Value 1

    $chave="HKCU:\Software\Microsoft\Windows\DWM"
    Write-PowerToolLine "Chave" $chave "White"
    $valor="AccentColor"
    Write-PowerToolLine "Alterar valor" $valor "White"
    $null=Set-ItemProperty -Path $chave -Name $valor -Value 0xFF000000

    # Atualizar as configuracoes de usuario
    RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters
}

# Restaurar fonte padrao do sistema
function Restore-Font {
    $chave="HKCU:\Control Panel\Desktop"
    Write-PowerToolLine "Chave" $chave "White"
    $valor="FontSmoothing"
    Write-PowerToolLine "Remover" $valor "White"
    $null=Remove-ItemProperty -Confirm:$false -Path $chave -Name $valor -ErrorAction SilentlyContinue

    $valor="FontSmoothingType"
    Write-PowerToolLine "Remover" $valor "White"
    $null=Remove-ItemProperty -Confirm:$false -Path $chave -Name $valor -ErrorAction SilentlyContinue

    $valor="FontSmoothingGamma"
    Write-PowerToolLine "Remover" $valor "White"
    $null=Remove-ItemProperty -Confirm:$false -Path $chave -Name $valor -ErrorAction SilentlyContinue

    $valor="FontSmoothingOrientation"
    Write-PowerToolLine "Remover" $valor "White"
    $null=Remove-ItemProperty -Confirm:$false -Path $chave -Name $valor -ErrorAction SilentlyContinue

    # Atualizar as configuracoes de usuario
    RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters
}

# Execution das funcoes
Restore-Wallpaper
Restore-Theme
Restore-Colors
Restore-Font
#----------------------------------------------------------------------------------------------

# Rodape
#----------------------------------------------------------------------------------------------
# Get the current script directory
$CurrentScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path -Parent


# Exibir rodape local
Write-PowerToolFooter
#----------------------------------------------------------------------------------------------