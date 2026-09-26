<#
    Copyright: (c) Flex IT - 2026
    Function: Habilitar Protocolo DHCP
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
Write-PowerToolHeader -Script $scriptName -Titulo "Habilitar o protocolo DHCP"
#----------------------------------------------------------------------------------------------

# Start actions
#----------------------------------------------------------------------------------------------
# Obtem todas as interfaces de rede
$networkInterfaces = Get-NetAdapter

$ipInfo = Get-NetIPAddress -AddressFamily IPv4

# Exibe os enderecos IP
foreach ($ip in $ipInfo) {
    if ($ip.InterfaceAlias -ne $null) {
        # Obtem a interface de rede pelo nome
        $interface = Get-NetAdapter | Where-Object { $_.InterfaceIndex -eq $ip.InterfaceIndex }

        # Verifica se a interface existe antes de reiniciar
        if ($interface -ne $null) {
            # Reinicia a interface de rede
            Set-NetIPInterface -InterfaceIndex $interface.InterfaceIndex -Dhcp Enabled
            Write-PowerToolLine "Task" "Reiniciar o adaptador" "cyan"
            Write-PowerToolBorder '|' '|' 'gray'

            Disable-NetAdapter -InterfaceAlias $interface.InterfaceAlias -Confirm:$false
            Restart-NetAdapter -InterfaceAlias $interface.InterfaceAlias -Confirm:$false
            Enable-NetAdapter -InterfaceAlias $interface.InterfaceAlias -Confirm:$false
            Write-PowerToolLine "Interface" "Reiniciada com success" "Green"
        }
        else {
            Write-PowerToolLine "Interface" "Nao tem um nome valido" "Gray"
        }
        Start-Sleep -Seconds 5
        Write-PowerToolLine "Interface ID" $($ip.InterfaceIndex) "Green"
        Write-PowerToolLine "Nome" $($ip.InterfaceAlias) "Green"
        Write-PowerToolLine "Descricao" $($ip.InterfaceDescription) "Green"
        Write-PowerToolLine "Endereco IP" $($ip.IPAddress) "Green"
        # Obtem o endereco MAC da interface de rede
        $macAddress = Get-NetAdapter | Where-Object { $_.InterfaceIndex -eq $ip.InterfaceIndex } | Select-Object -ExpandProperty MacAddress
        # Exibe o endereco MAC
        Write-PowerToolLine "Endereco MAC" $($macAddress) "Green"
        # Obtem informacoes da interface de rede para verificar o estado do DHCP
        $networkAdapter = Get-NetAdapter | Where-Object { $_.InterfaceIndex -eq $ip.InterfaceIndex }
    }

    if ($networkAdapter.Status -eq 'Up') {
        Write-PowerToolLine "Status" "Conectada" "Green"
    }
    else {
        Write-PowerToolLine "Status" "Desconectada" "Red"
    }

    if ($networkAdapter.Dhcp -eq 'Disabled') {
        Write-PowerToolLine "DHCP" "SIM" "Green"
    }
    else {
        Write-PowerToolLine "DHCP" "NAO" "Red"
    }
   
    Write-PowerToolBorder '|' '|' 'gray'
}


# Aguarda alguns segundos antes de reabilitar as interfaces
Start-Sleep -Seconds 5

foreach ($interface in $networkInterfaces) {
    # Reabilita a interface de rede
    Enable-NetAdapter -Confirm:$false -InterfaceAlias $interface.InterfaceAlias
}
#----------------------------------------------------------------------------------------------

# Applying changes
#----------------------------------------------------------------------------------------------
rundll32.exe user32.dll, UpdatePerUserSystemParameters
#----------------------------------------------------------------------------------------------

# Rodape
#----------------------------------------------------------------------------------------------
# Get the current script directory
$CurrentScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path -Parent


