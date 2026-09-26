<#
    Copyright: (c) Flex IT - 2026
    Function: Reparar Servidor RDP
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

# =====================================================================
# Script para Diagnostico e Correcao do Erro: 
# "O pool de servidores nao corresponde aos agentes de conexao da Area de Trabalho Remota que estao nele."
# =====================================================================

# Funcao para verificar se o servico esta em execution
function Check-ServiceStatus {
    param (
        [string]$ServiceName
    )

    Write-Host "Verificando o status do servico: $ServiceName..." -ForegroundColor Cyan
    $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
    if ($service -and $service.Status -eq 'Running') {
        Write-Host "O servico $ServiceName esta em execution." -ForegroundColor Green
    } elseif ($service) {
        Write-Host "O servico $ServiceName esta parado. Iniciando o servico..." -ForegroundColor Yellow
        Start-Service -Confirm:$false -Name $ServiceName
        Write-Host "O servico $ServiceName foi iniciado." -ForegroundColor Green
    } else {
        Write-Host "O servico $ServiceName nao foi encontrado no servidor." -ForegroundColor Red
    }
}

# Verificar e iniciar servicos criticos para RDS
Write-Host "Etapa 1: Verificar servicos do Remote Desktop Services..." -ForegroundColor Cyan
Check-ServiceStatus -ServiceName "TermService"  # Remote Desktop Services
Check-ServiceStatus -ServiceName "Tssdis"      # Remote Desktop Connection Broker
Check-ServiceStatus -ServiceName "SessionEnv"  # Remote Desktop Configuration
Check-ServiceStatus -ServiceName "RDLicensing" # Remote Desktop Licensing (se aplicavel)

# Testar comunicacao entre os servidores
Write-Host "Etapa 2: Testar comunicacao entre servidores do pool..." -ForegroundColor Cyan
$servers = @("l-server-01.Generic Company.local.net")  # Substitua pelos nomes dos servidores adicionais, se necessario
foreach ($server in $servers) {
    Write-Host "Testando conexao com o servidor $server..." -ForegroundColor Cyan
    if (Test-Connection -ComputerName $server -Count 2 -Quiet) {
        Write-Host "Conexao com $server esta OK." -ForegroundColor Green
    } else {
        Write-Host "Nao foi possivel conectar ao servidor $server. Verifique a rede ou firewall." -ForegroundColor Red
    }
}

# Reiniciar os servicos RDS para aplicar alteracoes
Write-Host "Etapa 3: Reiniciar servicos relacionados ao RDS..." -ForegroundColor Cyan
$rdServices = @("TermService", "Tssdis", "SessionEnv", "RDLicensing")
foreach ($service in $rdServices) {
    Write-Host "Reiniciando o servico: $service..." -ForegroundColor Yellow
    Restart-Service -Name $service -Force -ErrorAction SilentlyContinue
    Write-Host "O servico $service foi reiniciado." -ForegroundColor Green
}

# Verificar a configuracao do DNS e resolucao de nomes
Write-Host "Etapa 4: Verificar resolucao de nomes DNS..." -ForegroundColor Cyan
foreach ($server in $servers) {
    Write-Host "Verificando o nome DNS do servidor $server..." -ForegroundColor Cyan
    try {
        $dnsResult = [System.Net.Dns]::GetHostAddresses($server)
        if ($dnsResult) {
            Write-Host "Resolucao de nomes para $server esta funcionando." -ForegroundColor Green
        }
    } catch {
        Write-Host "Erro ao resolver o nome DNS para $server. Verifique as configuracoes de DNS." -ForegroundColor Red
    }
}
