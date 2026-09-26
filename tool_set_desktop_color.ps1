<#
    Copyright: (c) Flex IT - 2026
    Function: Definir Cor da Area de Trabalho
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
Write-PowerToolHeader -Script $scriptName -Titulo "Define a cor de fundo da 'Area de Trabalho'"
#----------------------------------------------------------------------------------------------

# Start actions
#----------------------------------------------------------------------------------------------
$code = @'
using System;
using System.Drawing;
using System.Runtime.InteropServices;
using Microsoft.Win32;

namespace CurrentUser
{
    public class Desktop
    {
        [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
        private static extern int SystemParametersInfo(int uAction, int uParm, string lpvParam, int fuWinIni);
        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        private static extern int SetSysColors(int cElements, int[] lpaElements, int[] lpRgbValues);
        public const int UpdateIniFile = 0x01;
        public const int SendWinIniChange = 0x02;
        public const int SetDesktopBackground = 0x0014;
        public const int COLOR_DESKTOP = 1;

        public static void SetBackground(byte r, byte g, byte b)
        {
            int[] elements = {COLOR_DESKTOP};

            System.Drawing.Color color = System.Drawing.Color.FromArgb(r, g, b);
            int[] colors = { System.Drawing.ColorTranslator.ToWin32(color) };

            SetSysColors(elements.Length, elements, colors);
            RegistryKey key = Registry.CurrentUser.OpenSubKey("Control Panel\\Colors", true);
            key.SetValue(@"Background", string.Format("{0} {1} {2}", color.R, color.G, color.B));
            key.Close();
        }
    }
}
'@

try {
    Add-Type -TypeDefinition $code -ReferencedAssemblies System.Drawing.dll 
} catch {
    # Ignora o erro se o tipo [CurrentUser.Desktop] ja estiver criado
} finally {
    [CurrentUser.Desktop]::SetBackground(74, 84, 89)
    # Informe a cor definida

}

Write-PowerToolLine "Cor de Fundo" "RGB (74, 84, 89)" "Green"
#----------------------------------------------------------------------------------------------

# Applying changes
#----------------------------------------------------------------------------------------------
rundll32.exe user32.dll, UpdatePerUserSystemParameters
#----------------------------------------------------------------------------------------------

# Rodape
#----------------------------------------------------------------------------------------------
# Get the current script directory
$CurrentScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path -Parent


# Exibir rodape local
Write-PowerToolFooter
#----------------------------------------------------------------------------------------------
