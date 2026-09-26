<#
    Copyright: (c) Flex IT - 2026
    Function: Exportar Drivers
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


# Define o diretorio de backup de drivers
$backupDir = "C:\Temp\Drivers"
# Header
#----------------------------------------------------------------------------------------------
# Get the current script directory
$scriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path -Parent

# Get the current script name
$scriptName = [System.IO.Path]::GetFileName($MyInvocation.MyCommand.Path)


# Show local header
Write-PowerToolHeader -Script $scriptName -Titulo "Exportar Drivers"
#----------------------------------------------------------------------------------------------

# Start actions
#----------------------------------------------------------------------------------------------
# Cria a pasta de destino, caso ela nao exista
if (-not (Test-Path $backupDir)) {
    New-Item -Path $backupDir -ItemType Directory | Out-Null
    Write-PowerToolLine "Diretorio" "$backupDir criado" "Green"
}

# Exporta todos os drivers instalados para o diretorio de destino
$drivers = Export-WindowsDriver -Online -Destination $backupDir

# Exporta as informacoes dos drivers para um arquivo texto
$drivers | Format-Table ProviderName, ClassName, Date, Version -AutoSize | Out-File "$backupDir\drivers.txt"

# Funcao para obter o nome do dispositivo a partir do arquivo INF
function Get-DeviceNameFromInf {
    param (
        [string]$infPath
    )

    # Tenta abrir e ler o arquivo INF
    try {
        $infContent = Get-Content $infPath -Raw
        # Procurar a secao que contem o nome do dispositivo
        if ($infContent -match 'DeviceDescription\s*=\s*"(.+?)"') {
            return $matches[1]
        } else {
            Write-PowerToolLine "Status" "Erro no INF: $infPath" "White"
            return $null
        }
    } catch {
        Write-PowerToolLine "Status" "Nao foi possivel ler o arquivo INF: $infPath" "Green"
        return $null
    }
}

# Obtem todas as subpastas no diretorio de backup
$subfolders = Get-ChildItem -Path $backupDir -Directory

foreach ($folder in $subfolders) {
    $deviceNames = @()

    # Obtem todos os arquivos INF dentro da subpasta
    $infFiles = Get-ChildItem -Path $folder.FullName -Filter *.inf -File

    foreach ($infFile in $infFiles) {
        # Obtem o nome do dispositivo a partir do arquivo INF
        $deviceName = Get-DeviceNameFromInf -infPath $infFile.FullName

        if ($deviceName) {
            # Adiciona o nome do dispositivo a lista
            $deviceNames += $deviceName
        }
    }

    if ($deviceNames.Count -gt 0) {
        # Usa o primeiro nome de dispositivo encontrado ou um nome padrao se a lista estiver vazia
        $finalDeviceName = $deviceNames[0] -replace '[\\/:*?"<>|]', '-'
        $newFolderName = Join-Path $backupDir $finalDeviceName

        # Renomeia a pasta, se necessario
        if ($folder.FullName -ne $newFolderName) {
            Write-PowerToolLine "Status" "Renomeando a pasta '$($folder.FullName)' para '$newFolderName'" "Green"
            Rename-Item -Path $folder.FullName -NewName $finalDeviceName -Force
        }
    } else {
        Write-PowerToolLine "Status" "Erro ao renomear a pasta '$($folder.FullName)'" "DarkCyan"
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