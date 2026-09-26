<#
    Copyright: (c) Flex IT - 2026
    Function: Windows 7 Otimizar Rede TCP
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

<#
    Otimizacao TCP compativel com Windows 7.
    Evita cmdlets Get-Net* que existem apenas em Windows mais novo.
#>

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $scriptDir "lib_win7.ps1")
Assert-Admin $MyInvocation.MyCommand.Path
Write-Header "Windows 7 - Rede TCP"

$backup = New-Win7BackupFolder
$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
reg export "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip" "$backup\Tcpip_$stamp.reg" /y | Out-Null
reg export "HKLM\SYSTEM\CurrentControlSet\Services\AFD" "$backup\AFD_$stamp.reg" /y | Out-Null
Write-Line "Backup" $backup "Green"

netsh interface tcp set global autotuninglevel=normal | Out-Null
netsh interface tcp set global rss=enabled | Out-Null
netsh interface tcp set global chimney=disabled | Out-Null
netsh interface tcp set global ecncapability=disabled | Out-Null
netsh interface tcp set global timestamps=disabled | Out-Null
netsh interface tcp set global congestionprovider=ctcp | Out-Null

Write-Line "Auto tuning" "normal" "Green"
Write-Line "RSS" "enabled" "Green"
Write-Line "Chimney" "disabled" "Green"
Write-Line "ECN" "disabled" "Green"
Write-Line "Timestamps" "disabled" "Green"
Write-Line "CTCP" "enabled" "Green"

Set-RegDword "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "DefaultTTL" 64
Set-RegDword "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "EnableTCPA" 0
Set-RegDword "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "DisableTaskOffload" 0
Set-RegDword "HKLM:\SYSTEM\CurrentControlSet\Services\AFD\Parameters" "DefaultSendWindow" 65536
Set-RegDword "HKLM:\SYSTEM\CurrentControlSet\Services\AFD\Parameters" "DefaultReceiveWindow" 65536

$interfacesPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
Get-ChildItem $interfacesPath -ErrorAction SilentlyContinue | ForEach-Object {
    Set-RegDword $_.PSPath "TcpAckFrequency" 1
    Set-RegDword $_.PSPath "TCPNoDelay" 1
}

Write-Footer "Rede configurada. Reinicie para aplicar tudo."
