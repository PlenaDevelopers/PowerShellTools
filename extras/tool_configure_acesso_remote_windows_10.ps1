<#
    Copyright: (c) Flex IT - 2026
    Function: Configurar Access Remoto Windows 10
    Description: Habilita Area de Trabalho Remota, NLA, firewall e servico RDP no Windows 10.
#>

[CmdletBinding()]
param(
    [switch]$SemNLA
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

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

function Assert-Admin {
    $principal = [Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent())
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "Execute este script como Administrador."
    }
}

function Enable-RemoteDesktopFirewallGroup {
    foreach ($displayGroup in @("Remote Desktop", "Area de Trabalho Remota", "Área de Trabalho Remota")) {
        try {
            Enable-NetFirewallRule -DisplayGroup $displayGroup -ErrorAction Stop
            Write-PowerToolLine "Firewall grupo" $displayGroup "Green"
        }
        catch { }
    }
}

function Ensure-FirewallPortRule {
    param(
        [string]$DisplayName,
        [ValidateSet("TCP", "UDP")]
        [string]$Protocol
    )

    $rule = Get-NetFirewallRule -DisplayName $DisplayName -ErrorAction SilentlyContinue
    if ($rule) {
        $rule | Set-NetFirewallRule -Enabled True -Action Allow -Profile Any -Confirm:$false
        Write-PowerToolLine $DisplayName "Ja existente / habilitada" "Green"
        return
    }

    New-NetFirewallRule `
        -DisplayName $DisplayName `
        -Direction Inbound `
        -Protocol $Protocol `
        -LocalPort 3389 `
        -Action Allow `
        -Profile Any | Out-Null
    Write-PowerToolLine $DisplayName "Criada" "Green"
}

try {
    Assert-Admin

    $scriptName = if ($PSCommandPath) { [System.IO.Path]::GetFileName($PSCommandPath) } else { $MyInvocation.MyCommand.Name }
    Write-PowerToolHeader -Script $scriptName -Titulo "Configurar Access Remoto Windows 10"

    Write-PowerToolLine "RDP" "Habilitando Area de Trabalho Remota" "Yellow"
    Set-ItemProperty `
        -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" `
        -Name "fDenyTSConnections" `
        -Value 0
    Write-PowerToolLine "RDP" "Conexoes remotas habilitadas" "Green"

    $nlaValue = if ($SemNLA) { 0 } else { 1 }
    Set-ItemProperty `
        -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" `
        -Name "UserAuthentication" `
        -Value $nlaValue
    $nlaStatus = if ($SemNLA) { "Desabilitado por parametro" } else { "Habilitado" }
    Write-PowerToolLine "NLA" $nlaStatus "Green"

    Write-PowerToolLine "Firewall" "Habilitando perfis e regras RDP" "Yellow"
    Set-NetFirewallProfile -Profile Domain,Private,Public -Enabled True
    Enable-RemoteDesktopFirewallGroup
    Ensure-FirewallPortRule -DisplayName "RDP TCP 3389" -Protocol TCP
    Ensure-FirewallPortRule -DisplayName "RDP UDP 3389" -Protocol UDP

    Write-PowerToolLine "Servico" "Configurando TermService" "Yellow"
    Set-Service -Name TermService -StartupType Automatic
    Start-Service -Name TermService -ErrorAction SilentlyContinue
    $termService = Get-Service -Name TermService
    Write-PowerToolLine "TermService" ($termService.Status.ToString()) "Green"

    $computerName = hostname
    Write-PowerToolLine "Computador" $computerName "White"

    $ipList = Get-NetIPAddress -AddressFamily IPv4 |
        Where-Object { $_.IPAddress -notlike "169.254.*" -and $_.IPAddress -ne "127.0.0.1" } |
        Select-Object -ExpandProperty IPAddress

    if ($ipList) {
        Write-PowerToolLine "IPs" ($ipList -join ", ") "White"
    }
    else {
        Write-PowerToolLine "IPs" "Nenhum IPv4 valido encontrado" "Yellow"
    }

    $tcpListen = Get-NetTCPConnection -LocalPort 3389 -State Listen -ErrorAction SilentlyContinue |
        Select-Object -First 1
    $portaStatus = if ($tcpListen) { "Escutando em $($tcpListen.LocalAddress):$($tcpListen.LocalPort)" } else { "Nao detectada em LISTEN" }
    $portaCor = if ($tcpListen) { "Green" } else { "Yellow" }
    Write-PowerToolLine "Porta 3389" $portaStatus $portaCor

    $grupoEncontrado = $false
    foreach ($groupName in @("Remote Desktop Users", "Usuarios da Area de Trabalho Remota", "Usuários da Área de Trabalho Remota")) {
        try {
            $members = Get-LocalGroupMember -Group $groupName -ErrorAction Stop
            $memberNames = @($members | Select-Object -ExpandProperty Name)
            $memberText = if ($memberNames.Count -gt 0) { $memberNames -join ", " } else { "Sem membros" }
            Write-PowerToolLine "Usuarios RDP" "$groupName`: $memberText" "White"
            $grupoEncontrado = $true
            break
        }
        catch { }
    }
    if (-not $grupoEncontrado) {
        Write-PowerToolLine "Usuarios RDP" "Grupo local nao encontrado" "Yellow"
    }

    Write-PowerToolFooter -Status "Finished"
}
catch {
    Write-PowerToolLine "Erro" $_.Exception.Message "Red"
    Write-PowerToolFooter -Status "Falhou"
    exit 1
}
