<#
    Copyright: (c) Flex IT - 2026
    Function: Escanear Rede
    Description: Script Powershell do pacote PowerTool para execution automated em Windows 10 e Windows 11.
#>

param (
    [string]$ipInicial,
    [string]$ipFinal,
    [string]$ocultarAusentes = "1"
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


function Testar-Host {
    param ($ip)
    try {
        $nome = [System.Net.Dns]::GetHostEntry($ip).HostName
    } catch {
        $nome = $null
    }
    return $nome
}

function Validar-IP {
    param ($ip)
    return [System.Net.IPAddress]::TryParse($ip, [ref]$null)
}

function Obter-RedeLocal {
    $netIP = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -ne "127.0.0.1" -and $_.PrefixOrigin -eq "Dhcp" }
    
    if (-not $netIP) {
        Write-Host "Erro: Nao foi possivel obter o endereco IP da rede local."
        return $null
    }

    $enderecoIP = $netIP.IPAddress
    $prefixo = $netIP.PrefixLength

    # Calcular a faixa de IP com base no prefixo
    $subnet = [System.Net.IPAddress]::Parse($enderecoIP)
    $bytes = $subnet.GetAddressBytes()
    $numHosts = [math]::Pow(2, (32 - $prefixo)) - 2

    # Definir o IP inicial e final da faixa
    $ipInicial = $enderecoIP -replace '\.\d+$','.1'    # Usar o primeiro IP
    $ipFinal = $enderecoIP -replace '\.\d+$','.254'    # Usar o ultimo IP

    return @{ ipInicial = $ipInicial; ipFinal = $ipFinal }
}

function IPtoInteger {
    param ($ip)
    $bytes = [System.Net.IPAddress]::Parse($ip).GetAddressBytes()
    [Array]::Reverse($bytes)
    return [BitConverter]::ToUInt32($bytes, 0)
}

function IntegerToIP {
    param ($int)
    $bytes = [BitConverter]::GetBytes($int)
    [Array]::Reverse($bytes)
    return [System.Net.IPAddress]::Parse(($bytes -join '.'))
}

function Escanear-Rede {
    param (
        [string]$ipInicial,
        [string]$ipFinal,
        [bool]$ocultarAusentes
    )

    # Se nao fornecer IPs, pegar a rede local
    if (-not $ipInicial -or -not $ipFinal) {
        $faixaIP = Obter-RedeLocal
        if ($faixaIP -eq $null) { return }
        $ipInicial = $faixaIP.ipInicial
        $ipFinal = $faixaIP.ipFinal
    }

    # Validar IPs fornecidos
    if (-not (Validar-IP $ipInicial)) {
        Write-Host "Erro: IP Inicial '$ipInicial' e invalido."
        return
    }

    if (-not (Validar-IP $ipFinal)) {
        Write-Host "Erro: IP Final '$ipFinal' e invalido."
        return
    }

    # Converter IPs para inteiros para comparacao
    $currentIPInt = IPtoInteger $ipInicial
    $endIPInt = IPtoInteger $ipFinal

    Write-Host "Iniciando o scan de $ipInicial ate $ipFinal..."

    while ($currentIPInt -le $endIPInt) {
        $currentIP = IntegerToIP $currentIPInt
        $hostname = Testar-Host $currentIP

        if ($hostname -or $ocultarAusentes -eq $false) {
            Write-Host "$currentIP | $hostname"
        }

        # Incrementar o IP
        $currentIPInt++
    }
}

# Verificar os valores de entrada
Write-Host "IP Inicial: $ipInicial"
Write-Host "IP Final: $ipFinal"

# Chamada da funcao
Escanear-Rede -ipInicial $ipInicial -ipFinal $ipFinal -ocultarAusentes ($ocultarAusentes -eq "1")
