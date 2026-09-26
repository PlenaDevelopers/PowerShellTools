<#
    Copyright: (c) Flex IT - 2026
    Function: Bloquear Alteracoes da Area de Trabalho
    Description: Script Powershell do pacote PowerTool para execution automated em Windows 10 e Windows 11.
#>

# Script para bloquear/desbloquear configuracoes de personalizacao
param (
    [string]$acao = "0" # "0" para desbloquear, "1" para bloquear
)


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


function Stop-PowerToolExplorer {
    $null = & taskkill.exe /F /IM explorer.exe 2>$null
}

# Funcao para definir valores no Registro
function Set-RegistryValue {
    param (
        [string]$regPath,
        [string]$regName,
        [int]$regValue
    )
    
    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }
    
    Set-ItemProperty -Path $regPath -Name $regName -Value $regValue
}

# Bloqueio ou desbloqueio de alteracao do papel de parede
Set-RegistryValue -regPath "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\ActiveDesktop" -regName "NoChangingWallPaper" -regValue $acao

# Bloqueio ou desbloqueio de alteracao de cores de destaque
$regPathAccentColor = "HKCU:\Software\Policies\Microsoft\Windows\Personalization"
$regNameAccentColor = "NoChangingAccentColor"

if ($acao -eq "1") {
    # Bloqueio: Define a chave que impede a alteracao de cores de destaque
    Set-RegistryValue -regPath $regPathAccentColor -regName $regNameAccentColor -regValue 1
    Write-PowerToolLine "Alteracao de Cores de Destaque" "Bloqueada" "Green"
} else {
    # Desbloqueio: Remove a chave que permite alteracao de cores de destaque
    if (Test-Path $regPathAccentColor) {
        Remove-ItemProperty -Confirm:$false -Path $regPathAccentColor -Name $regNameAccentColor -ErrorAction SilentlyContinue
        Write-PowerToolLine "Alteracao de Cores de Destaque" "Desbloqueada" "Green"
    }
}

# Bloqueio ou desbloqueio de alteracao da tela de fundo da tela de bloqueio
Set-RegistryValue -regPath "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" -regName "NoChangingLockScreen" -regValue $acao

# Bloqueio ou desbloqueio de alteracao de fontes
Set-RegistryValue -regPath "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -regName "NoChangeFont" -regValue $acao

# Verifica se o processo do Windows Explorer esta em execution
$explorerProcess = Get-Process -Name explorer -ErrorAction SilentlyContinue

# Se o processo nao estiver em execution, inicie-o
if (-not $explorerProcess) {
    Start-Process explorer
}

# Atualiza as configuracoes para refletir as mudancas
rundll32.exe user32.dll, UpdatePerUserSystemParameters

# Encerra o processo do Windows Explorer para aplicar as alteracoes imediatamente
Stop-PowerToolExplorer

# Aguarda alguns segundos antes de reiniciar o Windows Explorer
Start-Sleep -Seconds 2
