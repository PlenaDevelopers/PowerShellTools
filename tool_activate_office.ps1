<#
    Copyright: (c) Flex IT - 2026
    Function: Ativar Microsoft Office
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
Write-PowerToolHeader -Script $scriptName -Titulo "Ativar o Microsoft Office 365"
#----------------------------------------------------------------------------------------------

# Start actions
#----------------------------------------------------------------------------------------------
# Definindo as variaveis de diretorio base para Office 64 bits e 32 bits
$Office64Path = "${env:ProgramFiles}\Microsoft Office\Office16"
$Office32Path = "${env:ProgramFiles(x86)}\Microsoft Office\Office16"

# Verificando se o diretorio do Office 64 bits existe
if (Test-Path $Office64Path) {
    Set-Location -Path $Office64Path
    Write-PowerToolLine "Diretorio do Office(x64)" $Office64Path "White"
}
# Verificando se o diretorio do Office 32 bits existe
elseif (Test-Path $Office32Path) {
    Set-Location -Path $Office32Path
    Write-PowerToolLine "Diretorio do Office(x86)" $Office32Path "White"
}
else {
    # Rodape para Office nao encontrado
    #----------------------------------------------------------------------------------------------
    Write-PowerToolBorder '+' '+' 'Cyan'
    Write-PowerToolLine "Process" "Finished" "Cyan"
    Write-PowerToolBorder '+' '+' 'Cyan'
    exit
}

# Inserindo as licencas KMS
Write-PowerToolLine "Inserindo Chave" $Chave "Yellow"
Get-ChildItem -Path "..\root\Licenses16" -Filter "proplusvl_kms*.xrm-ms" | ForEach-Object {
    Write-PowerToolLine "Executando" $($_.FullName) "White"
    $null = & cscript ospp.vbs /inslic:"$($_.FullName)"
}

# Inserindo a chave de produto
Write-PowerToolLine "Chave" $Chave "White"
$null=& cscript ospp.vbs /inpkey:$Chave

# Removendo chaves antigas
$OldKeys = @("BTDRB", "KHGM9", "CPQVG")
foreach ($Key in $OldKeys) {
    Write-PowerToolLine "Remover chave" $Key "White"
    & cscript ospp.vbs /unpkey:$Key > $null
}
Write-PowerToolLine "Servidor KMS" $KmsServer "White"
Write-PowerToolLine "Porta KMS" $KmsPort "White"
$null = & cscript ospp.vbs /sethst:$KmsServer
$null = & cscript ospp.vbs /setprt:$KmsPort
Write-PowerToolLine "Operation" "Ativando" "White"
$null = & cscript ospp.vbs /act

# Verificando se o Office esta ativado
$ActivationStatus = & cscript ospp.vbs /dstatus

# Interpretando a saida para verificar o status de ativacao
if ($ActivationStatus -match "LICENSE STATUS:  ---LICENSED---") {
    Write-PowerToolBorder '+' '+' 'Cyan'
    Write-PowerToolLine "Status de Ativacao" "O Office esta ativado com success!" "Green"
} else {
    Write-PowerToolBorder '+' '+' 'Cyan'
    Write-PowerToolLine "Status de Ativacao" "Failure na ativacao do Office. Verifique os detalhes." "Red"
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
