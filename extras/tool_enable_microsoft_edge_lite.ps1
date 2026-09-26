<#
    Copyright: (c) Flex IT - 2026
    Function: Habilitar Microsoft Edge Lite
    Description: Script Powershell do pacote PowerTool para execution automated em Windows 10 e Windows 11.
#>

# Function: Microsoft Edge Lite
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
# Get the current script directory
$scriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path -Parent

# Get the current script name
$scriptName = [System.IO.Path]::GetFileName($MyInvocation.MyCommand.Path)


# Show local header
Write-PowerToolHeader -Script $scriptName -Titulo "Microsoft Edge Lite"
#----------------------------------------------------------------------------------------------

# Start actions
#----------------------------------------------------------------------------------------------
$edgeKeyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
$edgeUpdateKeyPath = "HKLM:\SOFTWARE\Policies\Microsoft\EdgeUpdate"
$microsoftKeyPath = "HKLM:\SOFTWARE\Microsoft"

# Criar as chaves de registro se nao existirem
if (-not (Test-Path $edgeKeyPath)) {
    New-Item -Path $edgeKeyPath -Force | Out-Null
}
if (-not (Test-Path $edgeUpdateKeyPath)) {
    New-Item -Path $edgeUpdateKeyPath -Force | Out-Null
}
if (-not (Test-Path $microsoftKeyPath)) {
    New-Item -Path $microsoftKeyPath -Force | Out-Null
}

# Definir valores para habilitar ou desabilitar
if ($Action -eq "1") {
    $syncDisabled = 1
    $browserSignin = 0
    $newSmartScreenLibraryEnabled = 0
    $smartScreenEnabled = 0
    $smartScreenPuaEnabled = 0
    $startupBoostEnabled = 0
    $bingAdsSuppression = 1
    $backgroundModeEnabled = 0
    $componentUpdatesEnabled = 0
    $edgeShoppingAssistantEnabled = 0
    $forceGoogleSafeSearch = 1
    $autoUpdateCheckPeriodMinutes = 0
    $updateDefault = 0
    $updatePolicy = 0
    $doNotUpdateToEdgeWithChromium = 1
    Write-PowerToolLine "Status" "Microsoft Edge Lite - Habilitado" "White"
} else {
    $syncDisabled = 0
    $browserSignin = 1
    $newSmartScreenLibraryEnabled = 1
    $smartScreenEnabled = 1
    $smartScreenPuaEnabled = 1
    $startupBoostEnabled = 1
    $bingAdsSuppression = 0
    $backgroundModeEnabled = 1
    $componentUpdatesEnabled = 1
    $edgeShoppingAssistantEnabled = 1
    $forceGoogleSafeSearch = 0
    $autoUpdateCheckPeriodMinutes = 1440
    $updateDefault = 1
    $updatePolicy = 1
    $doNotUpdateToEdgeWithChromium = 0
    Write-PowerToolLine "Status" "Microsoft Edge Lite - Desabilitado" "White"
}

# Aplicando valores no registro para Edge
Write-PowerToolLine "Valor" "SyncDisabled = $syncDisabled" "Green"
$null=New-ItemProperty -Path $edgeKeyPath -Name "SyncDisabled" -PropertyType DWord -Value $syncDisabled -Force
Write-PowerToolLine "Valor" "BrowserSignin = $browserSignin" "Green"
$null=New-ItemProperty -Path $edgeKeyPath -Name "BrowserSignin" -PropertyType DWord -Value $browserSignin -Force
Write-PowerToolLine "Valor" "NewSmartScreenLibraryEnabled = $newSmartScreenLibraryEnabled" "Green"
$null=New-ItemProperty -Path $edgeKeyPath -Name "NewSmartScreenLibraryEnabled" -PropertyType DWord -Value $newSmartScreenLibraryEnabled -Force
Write-PowerToolLine "Valor" "SmartScreenEnabled = $smartScreenEnabled" "Green"
$null=New-ItemProperty -Path $edgeKeyPath -Name "SmartScreenEnabled" -PropertyType DWord -Value $smartScreenEnabled -Force
Write-PowerToolLine "Valor" "SmartScreenPuaEnabled = $smartScreenPuaEnabled" "Green"
$null=New-ItemProperty -Path $edgeKeyPath -Name "SmartScreenPuaEnabled" -PropertyType DWord -Value $smartScreenPuaEnabled -Force
Write-PowerToolLine "Valor" "StartupBoostEnabled = $startupBoostEnabled" "Green"
$null=New-ItemProperty -Path $edgeKeyPath -Name "StartupBoostEnabled" -PropertyType DWord -Value $startupBoostEnabled -Force
Write-PowerToolLine "Valor" "BingAdsSuppression = $bingAdsSuppression" "Green"
$null=New-ItemProperty -Path $edgeKeyPath -Name "BingAdsSuppression" -PropertyType DWord -Value $bingAdsSuppression -Force
Write-PowerToolLine "Valor" "BackgroundModeEnabled = $backgroundModeEnabled" "Green"
$null=New-ItemProperty -Path $edgeKeyPath -Name "BackgroundModeEnabled" -PropertyType DWord -Value $backgroundModeEnabled -Force
Write-PowerToolLine "Valor" "ComponentUpdatesEnabled = $componentUpdatesEnabled" "Green"
$null=New-ItemProperty -Path $edgeKeyPath -Name "ComponentUpdatesEnabled" -PropertyType DWord -Value $componentUpdatesEnabled -Force
Write-PowerToolLine "Valor" "EdgeShoppingAssistantEnabled = $edgeShoppingAssistantEnabled" "Green"
$null=New-ItemProperty -Path $edgeKeyPath -Name "EdgeShoppingAssistantEnabled" -PropertyType DWord -Value $edgeShoppingAssistantEnabled -Force
Write-PowerToolLine "Valor" "ForceGoogleSafeSearch = $forceGoogleSafeSearch" "Green"
$null=New-ItemProperty -Path $edgeKeyPath -Name "ForceGoogleSafeSearch" -PropertyType DWord -Value $forceGoogleSafeSearch -Force

# Aplicando valores no registro para EdgeUpdate
Write-PowerToolLine "Valor" "AutoUpdateCheckPeriodMinutes = $autoUpdateCheckPeriodMinutes" "Green"
$null=New-ItemProperty -Path $edgeUpdateKeyPath -Name "AutoUpdateCheckPeriodMinutes" -PropertyType DWord -Value $autoUpdateCheckPeriodMinutes -Force
Write-PowerToolLine "Valor" "UpdateDefault = $updateDefault" "Green"
$null=New-ItemProperty -Path $edgeUpdateKeyPath -Name "UpdateDefault" -PropertyType DWord -Value $updateDefault -Force
Write-PowerToolLine "Valor" "UpdatePolicy = $updatePolicy" "Green"
$null=New-ItemProperty -Path $edgeUpdateKeyPath -Name "UpdatePolicy" -PropertyType DWord -Value $updatePolicy -Force

# Aplicando valores no registro para Microsoft
Write-PowerToolLine "Valor" "DoNotUpdateToEdgeWithChromium = $doNotUpdateToEdgeWithChromium" "Green"
$null=New-ItemProperty -Path $microsoftKeyPath -Name "DoNotUpdateToEdgeWithChromium" -PropertyType DWord -Value $doNotUpdateToEdgeWithChromium -Force
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
