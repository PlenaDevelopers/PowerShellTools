<#
    Copyright: (c) Flex IT - 2026
    Function: Habilitar Windows Defender
    Description: Script Powershell do pacote PowerTool para execution automated em Windows 10 e Windows 11.
#>

# Function: Configuracao Windows Defender
param (
    [string]$Action = "0" # "0" - Desabilitar, "1" - Habilitar
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


# Header
#----------------------------------------------------------------------------------------------
$scriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
$scriptName = [System.IO.Path]::GetFileName($MyInvocation.MyCommand.Path)
Write-PowerToolHeader -Script $scriptName -Titulo "Configuracao Windows Defender"
#----------------------------------------------------------------------------------------------

# Start actions
#----------------------------------------------------------------------------------------------
$keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"
$rtKeyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection"
$ssKeyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\SmartScreen"
$suKeyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates"
$spKeyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet"
$mfKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows Defender\Features"

# Criar as chaves de registro se nao existirem
$paths = @($keyPath, $rtKeyPath, $ssKeyPath, $suKeyPath, $spKeyPath, $mfKeyPath)
foreach ($path in $paths) {
    if (-not (Test-Path $path)) {
        New-Item -Path $path -Force | Out-Null
    }
}

# Definir valores no registro
$regEntries = @(
    @{ Path = $keyPath; Name = "DisableAntiSpyware"; Value = 1 },
    @{ Path = $keyPath; Name = "DisableRealtimeMonitoring"; Value = 1 },
    @{ Path = $keyPath; Name = "DisableAntiVirus"; Value = 1 },
    @{ Path = $keyPath; Name = "DisableSpecialRunningModes"; Value = 1 },
    @{ Path = $keyPath; Name = "DisableRoutinelyTakingAction"; Value = 1 },
    @{ Path = $keyPath; Name = "ServiceKeepAlive"; Value = 0 },
    @{ Path = $rtKeyPath; Name = "DisableBehaviorMonitoring"; Value = 1 },
    @{ Path = $rtKeyPath; Name = "DisableOnAccessProtection"; Value = 1 },
    @{ Path = $rtKeyPath; Name = "DisableScanOnRealtimeEnable"; Value = 1 },
    @{ Path = $rtKeyPath; Name = "DisableIOAVProtection"; Value = 1 },
    @{ Path = $rtKeyPath; Name = "DisableRealtimeMonitoring"; Value = 1 },
    @{ Path = $ssKeyPath; Name = "ConfigureAppInstallControlEnabled"; Value = 0 },
    @{ Path = $suKeyPath; Name = "ForceUpdateFromMU"; Value = 0 },
    @{ Path = $spKeyPath; Name = "DisableBlockAtFirstSeen"; Value = 1 },
    @{ Path = $spKeyPath; Name = "SubmitSamplesConsent"; Value = 2 },
    @{ Path = $spKeyPath; Name = "SpynetReporting"; Value = 0 },
    @{ Path = $mfKeyPath; Name = "TamperProtection"; Value = 0 },
    @{ Path = $keyPath; Name = "ServiceStartStates"; Value = 1 }
)

foreach ($entry in $regEntries) {
    Write-PowerToolLine "Valor" "$($entry.Name) = $($entry.Value)" "Green"
    New-ItemProperty -Path $entry.Path -Name $entry.Name -PropertyType DWord -Value $entry.Value -Force | Out-Null
}
Write-PowerToolLine "Status" "Windows Defender - Configurado com Sucesso" "White"
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
