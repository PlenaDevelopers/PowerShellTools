<#
    Copyright: (c) Flex IT - 2026
    Function: Configurar Cortana
    Description: Script Powershell do pacote PowerTool para execution automated em Windows 10 e Windows 11.
#>

param (
    [string]$acao = "0" # "0" - Desabilitar, "1" - Habilitar
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
Write-PowerToolHeader -Script $scriptName -Titulo "Habilitar/Desabilitar o Cortana"
#----------------------------------------------------------------------------------------------

# Start actions
#----------------------------------------------------------------------------------------------
if ($acao -eq "0") {
    Write-PowerToolLine "Opcao" "Desabilitar o Cortana" "White"
    $AcceptedPrivacyPolicyValue = 0
    $RestrictImplicitValueCollection = 1
    $RDsxWAaQUzQtK3MVfvekDQNsktKT7oB4hw = 1
    $HarvestContactsValue = 0
    Get-AppxPackage *Microsoft.549981C3F5F10* | Remove-AppxPackage -Confirm:$false
} elseif ($acao -eq "1") {
    Write-PowerToolLine "Opcao" "Habilitar o Cortana" "White"
    $AcceptedPrivacyPolicyValue = 1
    $RestrictImplicitValueCollection = 0
    $RDsxWAaQUzQtK3MVfvekDQNsktKT7oB4hw = 0
    $HarvestContactsValue = 1
    Get-AppXPackage *Microsoft.549981C3F5F10* -AllUsers | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
}

$Cortana1 = "HKCU:\SOFTWARE\Microsoft\Personalization\Settings"
$Cortana2 = "HKCU:\SOFTWARE\Microsoft\InputPersonalization"
$Cortana3 = "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore"

If (!(Test-Path $Cortana1)) {
    New-Item $Cortana1
    Write-PowerToolLine "Chave (Criada)" $Cortana1 "White"
}
else {
    Write-PowerToolLine "Chave (Presente)" $Cortana1 "White"
}
    Write-PowerToolLine "AcceptedPrivacyPolicy" $AcceptedPrivacyPolicyValue "White"
    Set-ItemProperty $Cortana1 AcceptedPrivacyPolicy -Value $AcceptedPrivacyPolicyValue 

If (!(Test-Path $Cortana2)) {
    New-Item $Cortana2
    Write-PowerToolLine "Chave (Criada)" $Cortana2 "White"
}
else {
    Write-PowerToolLine "Chave (Presente)" $Cortana2 "White"
}
    Write-PowerToolLine "RestrictImplicitTextCollection" $RestrictImplicitValueCollection "White"
    Set-ItemProperty $Cortana2 RestrictImplicitTextCollection -Value $RestrictImplicitValueCollection 
    Write-PowerToolLine "RestrictImplicitInkCollection" $RDsxWAaQUzQtK3MVfvekDQNsktKT7oB4hw "White"
    Set-ItemProperty $Cortana2 RestrictImplicitInkCollection -Value $RestrictImplicitInkCollectionValue 

If (!(Test-Path $Cortana3)) {
    New-Item $Cortana3
    Write-PowerToolLine "Chave (Criada)" $Cortana3 "White"
}
else {
    Write-PowerToolLine "Chave (Presente)" $Cortana3 "White"
}
    Write-PowerToolLine "HarvestContacts" $HarvestContactsValue "White"
    Set-ItemProperty $Cortana3 HarvestContacts -Value $HarvestContactsValue 
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