<#
    Copyright: (c) Flex IT - 2026
    Function: Criar Regra de Firewall do Firebird Alternativa
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

Write-PowerToolBorder '+' '+' 'Cyan'
Write-PowerToolLine " Operation" "Criar regras de firewall para o Firebird" "Yellow"
Write-PowerToolLine " Copyright" "2023 - PowerTool Team" "Yellow"
$computerName = (Get-ComputerInfo).CsName
Write-PowerToolLine " Computador" $computerName "White"
Write-PowerToolLine " Script" $MyInvocation.MyCommand.Path "White"
Write-PowerToolBorder '+' '+' 'Cyan'

Write-PowerToolBorder '|' '|' 'gray'
Write-PowerToolLine " Task" "Remover regras do Firewall" "cyan"
Write-PowerToolBorder '|' '|' 'gray'

# Palavra especifica que voce deseja buscar nas regras do firewall
$palavraChave = "Firebird"

# Obter todas as regras do firewall
$regras = Get-NetFirewallRule

# Filtrar regras que contenham a palavra-chave no nome ou no perfil de servico
$regrasFiltradas = $regras | Where-Object { $_.DisplayName -like "*$palavraChave*" -or $_.ServiceDisplayName -like "*$palavraChave*" }

# Remover as regras filtradas
foreach ($regra in $regrasFiltradas) {
    Remove-NetFirewallRule -Confirm:$false -Name $regra.Name
    Write-PowerToolLine " Regra Removida" $($regra.DisplayName) "cyan"
}

Write-PowerToolBorder '|' '|' 'gray'
Write-PowerToolLine " Task" "Adicionar regras no Firewall" "cyan"
Write-PowerToolBorder '|' '|' 'gray'

# Nome da regra
$nomeRegra = "Firebird"

# Porta do servico Firebird (por padrao, e a porta UDP 3050)
$portaSNMP = 3050

# Perfil de rede: Domain, Private, Public
$perfis = "Domain", "Private", "Public"

# Criar regras de entrada para cada perfil
foreach ($perfil in $perfis) {
    $paramsEntrada = @{
        Name        = "$nomeRegra-In-$perfil"
        DisplayName = "Permitir Firebird (Entrada) - $perfil"
        Direction   = "Inbound"
        Action      = "Allow"
        Protocol    = "UDP"
        LocalPort   = $portaSNMP
        Profile     = $perfil
    }

    $null = New-NetFirewallRule @paramsEntrada
    Write-PowerToolLine " Regra Adicionada (Entrada)" "DisplayName: $($paramsEntrada['DisplayName'])" "Green"
}

# Criar regras de saida para cada perfil
foreach ($perfil in $perfis) {
    $paramsSaida = @{
        Name        = "$nomeRegra-Out-$perfil"
        DisplayName = "Permitir Firebird (Saida) - $perfil"
        Direction   = "Outbound"
        Action      = "Allow"
        Protocol    = "UDP"
        LocalPort   = $portaSNMP
        Profile     = $perfil
    }

    $null = New-NetFirewallRule @paramsSaida
    Write-PowerToolLine " Regra Adicionada (Saida)" "DisplayName: $($paramsSaida['DisplayName'])" "Green"
}

rundll32.exe user32.dll, UpdatePerUserSystemParameters

#Final do Script
Write-PowerToolBorder '+' '+' 'Cyan'

Write-Host "|" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Process")   -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-86} " -f "Finished") -NoNewline -ForegroundColor Cyan
Write-Host "|" -ForegroundColor Cyan

