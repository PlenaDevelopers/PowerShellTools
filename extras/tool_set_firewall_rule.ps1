<#
    Copyright: (c) Flex IT - 2026
    Function: Criar Regra de Firewall
    Description: Script Powershell do pacote PowerTool para execution automated em Windows 10 e Windows 11.
#>

#Script para criar regras de entrada e sada no Firewall do Windows
param (
    [string]$regra_nome = 'Firebird',
    [string]$regra_porta = "3050",
    [string]$regra_protocolo = "1", # 0 = UDP, 1 = TCP, 2 = TCP and UDP
    [string]$regra_direcao = "2",   # 0 = sada, 1 = entrada, 2 = sada e entrada
    [string]$regra_rede = "5"       # 0 = pblica, 1 = privada, 2 = dGeneric Companyo, 3 = privada + pblica, 4 = privada + dGeneric Companyo, 5 = privada + pblica + dGeneric Companyo
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


function RemoverRegrasExistentes {
    param (
        [string]$nomePrefixo
    )
    $regras = Get-NetFirewallRule | Where-Object { $_.Name -like "$nomePrefixo*" }
    if ($regras) {
        $regras | Remove-NetFirewallRule -Confirm:$false
    }
}

# Perfil de rede: Domain, Private, Public
$perfis = @()
if ($regra_rede -eq "0") { $perfis += "Public" }
if ($regra_rede -eq "1") { $perfis += "Private" }
if ($regra_rede -eq "2") { $perfis += "Domain" }
if ($regra_rede -eq "3") { $perfis += "Public", "Private" }
if ($regra_rede -eq "4") { $perfis += "Private", "Domain" }
if ($regra_rede -eq "5") { $perfis += "Public", "Private", "Domain" }

# Mapeamento dos protocolos
$protocolos = @()
if ($regra_protocolo -eq "0") { $protocolos += "UDP" }
if ($regra_protocolo -eq "1") { $protocolos += "TCP" }
if ($regra_protocolo -eq "2") { $protocolos += "UDP", "TCP" }

# Remover regras existentes
$prefixoRegra = "$regra_nome-*"
RemoverRegrasExistentes -nomePrefixo $prefixoRegra

# Criar regras de firewall de acordo com a direo especificada
if ($regra_direcao -eq "0" -or $regra_direcao -eq "2") {
    # Criar regra de sada
    foreach ($protocolo in $protocolos) {
        $nomeRegraOut = "$regra_nome-$protocolo-Outbound"
        $paramsRegraOut = @{
            Name        = $nomeRegraOut
            DisplayName = "$regra_nome ($protocolo) (Saida)"
            Action      = "Allow"
            Direction   = "Outbound"
            Protocol    = $protocolo
            Profile     = $perfis
        }
        if ($protocolo -in "UDP", "TCP") {
            $paramsRegraOut["LocalPort"] = $regra_porta
        }
        $null = New-NetFirewallRule @paramsRegraOut
    }
}

if ($regra_direcao -eq "1" -or $regra_direcao -eq "2") {
    # Criar regra de entrada
    foreach ($protocolo in $protocolos) {
        $nomeRegraIn = "$regra_nome-$protocolo-Inbound"
        $paramsRegraIn = @{
            Name        = $nomeRegraIn
            DisplayName = "$regra_nome ($protocolo) (Entrada)"
            Action      = "Allow"
            Direction   = "Inbound"
            Protocol    = $protocolo
            Profile     = $perfis
        }
        if ($protocolo -in "UDP", "TCP") {
            $paramsRegraIn["LocalPort"] = $regra_porta
        }
        $null = New-NetFirewallRule @paramsRegraIn
    }
}
