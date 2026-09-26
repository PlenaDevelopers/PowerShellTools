<#
    Copyright: (c) Flex IT - 2026
    Function: Atualizar Microsoft .NET Framework
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

function Get-NetFrameworkRelease {
    try {
        $release = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' -Name Release -ErrorAction Stop
        return [int]$release
    }
    catch {
        return 0
    }
}

function Test-NetFrameworkRelease {
    param([int]$MinimumRelease)
    return ((Get-NetFrameworkRelease) -ge $MinimumRelease)
}

function Invoke-FrameworkInstaller {
    param(
        [string]$Name,
        [string]$Path,
        [string]$Arguments,
        [int]$MinimumRelease
    )

    if ($MinimumRelease -gt 0 -and (Test-NetFrameworkRelease -MinimumRelease $MinimumRelease)) {
        Write-PowerToolLine "Ignorado" ("{0} ja instalado" -f $Name) "Yellow"
        return
    }

    if (-not (Test-Path -LiteralPath $Path)) {
        Write-PowerToolLine "Aviso" ("{0} nao encontrado no diretorio." -f $Name) "Yellow"
        return
    }

    Write-PowerToolLine "Instalando" $Name "Green"
    $process = Start-Process -FilePath $Path -ArgumentList $Arguments -Wait -PassThru -WindowStyle Hidden -ErrorAction Stop
    Write-PowerToolLine "Codigo de Saida" ("{0} = {1}" -f $Name, $process.ExitCode) "White"
}


# Header
#----------------------------------------------------------------------------------------------
# Get the current script directory
$scriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path -Parent

# Get the current script name
$scriptName = [System.IO.Path]::GetFileName($MyInvocation.MyCommand.Path)


# Show local header
Write-PowerToolHeader -Script $scriptName -Titulo "Atualizar o Microsoft Net. Framework"
#----------------------------------------------------------------------------------------------

# Start actions
#----------------------------------------------------------------------------------------------
# Obtem o diretorio atual do script
$currentScriptDirectory = $PSScriptRoot

# Adiciona o subdiretorio "updates"
$updatesDirectory = Join-Path $currentScriptDirectory "updates\framework"

# Se precisar do caminho completo do script
$currentScriptPath = $MyInvocation.MyCommand.Path

Write-PowerToolLine "Diretorio das Atualizacoes" $updatesDirectory
Write-PowerToolBorder '+' '+' 'Cyan'
#----------------------------------------------------------------------------------------------
# Instalacao do .NET Frameworks para Windows 10 e Windows Server
#----------------------------------------------------------------------------------------------

# Ativando o recurso .NET Framework 3.5
try {
    $netFx3 = Get-WindowsOptionalFeature -Online -FeatureName NetFx3 -ErrorAction Stop
    if ($netFx3.State -eq 'Enabled') {
        Write-PowerToolLine "Ignorado" "Microsoft NET. Framework 3.5 ja habilitado" "Yellow"
    }
    else {
        Write-PowerToolLine "Instalando" "Microsoft NET. Framework 3.5" "Green"
        [void](Enable-WindowsOptionalFeature -Online -FeatureName NetFx3 -All -NoRestart -ErrorAction Stop)
        Write-PowerToolLine "Status" "NetFx3 habilitado sem reinicializacao automatica" "Green"
    }
} catch {
    Write-PowerToolLine "Erro" ("Failure ao instalar o .NET Framework 3.5: {0}" -f $_.Exception.Message) "Red"
}

# .NET Framework 4.x e uma atualizacao in-place: 4.8/4.8.1 substituem 4.5, 4.6 e 4.7.x.
$legacyFrameworks = @(
    "Microsoft NET. Framework 4.5",
    "Microsoft NET. Framework 4.6",
    "Microsoft NET. Framework 4.7.1",
    "Microsoft NET. Framework 4.7.2",
    "Microsoft NET. Framework 4.7.3"
)

foreach ($legacyFramework in $legacyFrameworks) {
    Write-PowerToolLine "Ignorado" ("{0} substituido pelo 4.8/4.8.1" -f $legacyFramework) "Yellow"
}

# Lista de instaladores adicionais
$installers = @(
    @{ Name = "Microsoft NET. Framework 4.8"; Executable = "net_framework_4_8.exe"; Switch = "/quiet /norestart"; MinimumRelease = 528040 },
    @{ Name = "Microsoft NET. Framework 4.8.1"; Executable = "net_framework_4_8_1.exe"; Switch = "/quiet /norestart"; MinimumRelease = 533320 }
)

# Loop para instalar cada um
foreach ($installer in $installers) {
    $installerPath = Join-Path $updatesDirectory $installer.Executable
    try {
        Invoke-FrameworkInstaller -Name $installer.Name -Path $installerPath -Arguments $installer.Switch -MinimumRelease $installer.MinimumRelease
    }
    catch {
        Write-PowerToolLine "Erro" ("Failure ao instalar {0}: {1}" -f $installer.Name, $_.Exception.Message) "Red"
    }
}

#----------------------------------------------------------------------------------------------
# Applying changes visuais
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
