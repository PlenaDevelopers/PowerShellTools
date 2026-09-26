<#
    Copyright: (c) Flex IT - 2026
    Function: Adicionar Favorito no Chrome
    Description: Script Powershell do pacote PowerTool para execution automated em Windows 10 e Windows 11.
#>

# Parametro de entrada
Param (
    [string]$Chave = "XQNVK-8JYDB-WJ9W3-YJ8YR-WFG99", # Chave padrao
    [string]$KmsServer = "e8.us.to", # Servidor KMS. Use kms.core.windows.net (Original da Microsoft)
    [string]$KmsPort = 1688 # Porta do servidor KMS. Use 1688 (Original da Microsoft)
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
Write-PowerToolHeader -Script $scriptName -Titulo "Adicionar favoritos ao Google Chrome"
#----------------------------------------------------------------------------------------------

# Start actions
#----------------------------------------------------------------------------------------------

# Caminho para o arquivo de favoritos do Chrome
$bookmarksPath = "C:\users\$env:userprofile\appdata\local\google\chrome\default\bookmarks"

# Caminho para o arquivo CSV contendo os novos favoritos
$csvPath = "\\server\share\repository\chromebookmarks.csv"

# Verifica se o arquivo de favoritos do Chrome existe
if (-not (Test-Path $bookmarksPath)) {
    Write-Host "Arquivo de favoritos do Chrome nao encontrado." -ForegroundColor Red
    exit
}

# Faz o backup do arquivo de favoritos existente
Copy-Item -Path $bookmarksPath -Destination "$bookmarksPath.bak" -Force

# Le o arquivo de favoritos e o arquivo CSV
$bookmarks = Get-Content $bookmarksPath | ConvertFrom-Json
$data = Import-Csv $csvPath

# Adiciona os novos favoritos a barra de favoritos
$bookmarks.roots.bookmark_bar.children += $data

# Salva o arquivo JSON atualizado de volta
$bookmarks | ConvertTo-Json -Depth 10 | Set-Content -Path $bookmarksPath -Encoding UTF8 -Force

Write-Host "Favoritos adicionados com success." -ForegroundColor Green
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
