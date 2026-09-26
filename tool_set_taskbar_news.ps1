<#
    Copyright: (c) Flex IT - 2026
    Function: Configurar Noticias e Interesses da Barra de Tasks
    Description: Script Powershell do pacote PowerTool para execution automated em Windows 10 e Windows 11.
#>

param (
    [string]$acao = "0" # "0" para desativar, "1" para ativar
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
Write-PowerToolHeader -Script $scriptName -Titulo "Habilitar/Desabilitar a Barra de Novidades"
#----------------------------------------------------------------------------------------------

# Start actions
#----------------------------------------------------------------------------------------------
if ($acao -eq "1") {
    # Ativar a barra de noticias
    $regValue = 1
    $status = "Ativar"
    $shellFeedsTaskbarViewMode = 1
    $enshellFeedsTaskbarViewMode = 0x3AF5A154 # Valor hexadecimal para EnshellFeedsTaskbarViewMode
    Write-PowerToolLine "Opcao" $status "White"
} elseif ($acao -eq "0") {
    # Desativar a barra de noticias
    $regValue = 0
    $status = "Desativar"
    $shellFeedsTaskbarViewMode = 0
    $enshellFeedsTaskbarViewMode = 0x4E7A5612 # Valor hexadecimal para EnshellFeedsTaskbarViewMode quando desativado
    Write-PowerToolLine "Opcao" $status "White"
} else {
    Write-PowerToolLine "Erro" "Parametro invalido. Use '0' para desativar ou '1' para ativar." "Red"
    exit
}

# Defina o caminho da chave de registro
$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds"

# Verifique se a chave de registro existe
if (Test-Path $regPath) {
    Write-PowerToolLine "Apagar valores" $regPath "Cyan"
    # Obtenha todos os valores dentro da chave de registro
    $values = Get-ItemProperty -Path $regPath | Select-Object -Property * -ExcludeProperty PSPath, PSParentPath, PSChildName, PSDrive, PSProvider

    # Remova cada valor individualmente
    foreach ($value in $values.PSObject.Properties.Name) {
        Remove-ItemProperty -Confirm:$false -Path $regPath -Name $value -Force
    }
    Write-PowerToolLine "Valores apagados" $regPath "Cyan"
} else {
    Write-PowerToolLine "Chave nao encontrada" $regPath "Red"
}

# Defina o caminho da chave de registro
$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds"

$properties = @(
    @{Name="shellFeedsTaskbarViewMode"; Value=$shellFeedsTaskbarViewMode; Type="DWord"}
    @{Name="DeviceTier"; Value=2; Type="DWord"}
    @{Name="DeviceSSD"; Value=1; Type="DWord"}
    @{Name="DeviceMemory"; Value=32; Type="DWord"}
    @{Name="DeviceProcessr"; Value=6; Type="DWord"}
    @{Name="EdgeHandoffOnboardingComplete"; Value=0; Type="DWord"}
    @{Name="osLocale"; Value="pt_br"; Type="String"}
    @{Name="IsAnaheimEdgeInstalled"; Value=1; Type="DWord"}
    @{Name="IsFeedsAvailable"; Value=1; Type="DWord"}
    @{Name="IsEnterpriseDevice"; Value=0; Type="DWord"}
    @{Name="HeadlinesOnboardingComplete"; Value=1; Type="DWord"}
    @{Name="EnshellFeedsTaskbarViewMode"; Value=$enshellFeedsTaskbarViewMode; Type="DWord"}
    @{Name="UnpinReason"; Value=0; Type="DWord"}
    @{Name="UnpinTimestamp"; Value=(Get-Date).ToString("yyyy-MM-ddTHH-mm-ss"); Type="String"}
    @{Name="shellFeedsTaskbarPreviousViewMode"; Value=1; Type="DWord"}
    @{Name="IsLocationTurnedOn"; Value=0; Type="DWord"}
    @{Name="IsEdgeUser"; Value=1; Type="DWord"}
    @{Name="ActiveMUID"; Value="3F9B855219DA691707B6919718CE686F"; Type="String"}
    @{Name="ActiveId"; Value="0de1b966b88745cd"; Type="String"}
    @{Name="ActiveAccountId"; Value="00060000813C9381"; Type="String"}
    @{Name="ActiveAuthority"; Value="consumers"; Type="String"}
    @{Name="ActiveProfileName"; Value="Pessoal"; Type="String"}
    @{Name="ActiveProfileInError"; Value=0; Type="DWord"}
    @{Name="ActiveProfileId"; Value="A1B2C3D4"; Type="String"}
)

foreach ($prop in $properties) {
    try {
                Write-PowerToolLine "Verificando Valor" $prop.Name "White"
        # Verificar se a chave de registro existe
        if (Test-Path $regPath) {
            # Verificar se o valor existe
            if (Get-ItemProperty -Path $regPath -Name $prop.Name -ErrorAction SilentlyContinue) {
                Write-PowerToolLine "Alterando Valor" $prop.Name "Red"
                if ($prop.Type -eq "DWord") {
                    $null=Set-ItemProperty -Path $regPath -Name $prop.Name -Value [UInt32]$prop.Value -Type DWord -Force
                } elseif ($prop.Type -eq "String") {
                    $null=Set-ItemProperty -Path $regPath -Name $prop.Name -Value $prop.Value -Type String -Force
                }
            } else {
                Write-PowerToolLine "Status" "Valor nao encontrado para alteracao" "Red"
            }
        } else {
                Write-PowerToolLine "Status" "Chave de registro nao encontrada" "Red"
        }
    } catch {
                Write-PowerToolLine "Status" "Failure ao alterar valor" "Red"
    }
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


# Exibir rodape local
Write-PowerToolFooter
#----------------------------------------------------------------------------------------------