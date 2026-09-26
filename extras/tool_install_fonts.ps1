<#
    Copyright: (c) Flex IT - 2026
    Function: Instalar Fontes
    Description: Script Powershell do pacote PowerTool para execution automated em Windows 10 e Windows 11.
#>

param (
    [string]$fontDirectory = "D:\perfil\OneDrive\Documents\Projeto Powershell\script\PowershellTools\fontes",  # Caminho da pasta onde as fontes estao localizadas
    [string]$scope = "current"  # Escopo de instalacao: "current" para usuario atual, "all" para todos os usuarios
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
Write-PowerToolHeader -Script $scriptName -Titulo "Instalar Fontes"
#----------------------------------------------------------------------------------------------

# Start actions
#----------------------------------------------------------------------------------------------
# Informa o nome da fonte
function Get-FontName {
    param (
        [string]$fontFilePath  # Caminho completo do arquivo de fonte
    )

    # Verifica se o arquivo de fonte existe
    if (-not (Test-Path $fontFilePath)) {
        Write-Host "Arquivo de fonte nao encontrado: $fontFilePath" -ForegroundColor Red
        return
    }

    try {
        # Carrega o tipo de fonte usando .NET
        Add-Type -AssemblyName System.Drawing

        # Cria um objeto Font usando o arquivo de fonte
        $fontCollection = New-Object System.Drawing.Text.PrivateFontCollection
        $fontCollection.AddFontFile($fontFilePath)
        $fontFamily = $fontCollection.Families[0]

        # Obtem o nome da fonte
        return $fontFamily.Name
    } catch {
        Write-Host "Erro ao obter o nome da fonte: $_" -ForegroundColor Red
    }
}

# Verifica se o diretorio informado existe
if (-not (Test-Path -Path $fontDirectory)) {
    Write-PowerToolLine "Erro" "A pasta informada nao foi encontrada" "White"
    exit
}

# Funcao para instalar a fonte
function Install-Font {
    param (
        [string]$fontPath,  # Caminho completo da fonte
        [string]$scope      # Escopo de instalacao
    )

    $fontFileName = [System.IO.Path]::GetFileNameWithoutExtension($fontPath)

    # Obtem o nome da familia da fonte usando a funcao Get-FontName
    $fontFamilyName = Get-FontName -fontFilePath $fontPath

    try {
        if ($scope -eq "all") {
            # Instala para todos os usuarios
            Write-PowerToolLine "Instalando (Everyone)" "$fontFileName ($fontFamilyName)" "White"
            $destination = "$env:WINDIR\Fonts\$($fontFileName).ttf"
            $null = Copy-Item $fontPath -Destination $destination -Force -ErrorAction SilentlyContinue
            $regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
            $null = Set-ItemProperty -Path $regPath -Name "$fontFileName (TrueType)" -Value "$fontFileName.ttf" -ErrorAction SilentlyContinue
        } elseif ($scope -eq "current") {
            # Instala apenas para o usuario atual
            Write-PowerToolLine "Instalando (Este usuario)" "$fontFileName ($fontFamilyName)" "White"
            $destination = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts\$($fontFileName).ttf"
            $null = Copy-Item $fontPath -Destination $destination -Force -ErrorAction SilentlyContinue
            $regPath = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts"
            $null = Set-ItemProperty -Path $regPath -Name "$fontFileName (TrueType)" -Value "$fontFileName.ttf" -ErrorAction SilentlyContinue
        } else {
            Write-PowerToolLine "Erro" "Escopo invalido" "DarkMagenta"
            exit
        }
    } catch {
        Write-PowerToolLine "Erro" "Erro ao copiar o arquivo" "DarkMagenta"
    }
}

# Obtenha todos os arquivos de fontes (ttf) da pasta fornecida
$fontFiles = Get-ChildItem -Path $fontDirectory -Filter *.ttf -Recurse

if ($fontFiles.Count -eq 0) {
    Write-PowerToolLine "Erro" "Nenhum arquivo de fonte encontrado" "DarkMagenta"
    exit
}

# Loop para instalar cada fonte encontrada
foreach ($font in $fontFiles) {
    Install-Font -fontPath $font.FullName -scope $scope
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
