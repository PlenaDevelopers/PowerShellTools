<#
    Copyright: (c) Flex IT - 2026
    Function: Configurar Logon Automatico
    Description: Script Powershell do pacote PowerTool para execution automated em Windows 10 e Windows 11.
#>

param (
    [string]$Usuario = 'Administrador',
    [string]$Senha = 'ChangeMe!123',
    [string]$HabilitarLogonAutomatico = '1'  # '1' para Habilitar, '0' para Desabilitar
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
Write-PowerToolHeader -Script $scriptName -Titulo "Habilitar/Desabilitar o Logon Automatico"
#----------------------------------------------------------------------------------------------

# Start actions
#----------------------------------------------------------------------------------------------
# Valor a ser configurado (1 para ativar e 0 para desativar)
if ($HabilitarLogonAutomatico -eq "1") {
    Write-PowerToolLine "Opcao" "Ativar" "White"
} else {
    Write-PowerToolLine "Opcao" "Desativar" "White"
}

# Converter o nome do parametro
$regValue = $HabilitarLogonAutomatico

$regPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
$regName = "AutoAdminLogon"
Write-PowerToolLine "Chave" $regPath "White"
Write-PowerToolLine "Item" $regName "White"
Write-PowerToolLine "Valor" $regValue "White"
# Verificar se o caminho no Registro existe, criar se nao existir
if (-not (Test-Path $regPath)) {
    $null = New-Item -Path $regPath -Force | Out-Null
    Write-PowerToolLine "Chave" "Criada" "Green"
}

# Configurar o AutoAdminLogon
$null = Set-ItemProperty -Path $regPath -Name $regName -Value $regValue -Type String

# Configurar as chaves DefaultUsername e DefaultPassword apenas se o AutoAdminLogon estiver habilitado
if ($HabilitarLogonAutomatico -eq '1') {
    $null = Set-ItemProperty $RegPath 'DefaultUsername' -Value "$Usuario" -Type String
    Write-PowerToolLine "Valor" ("DefaultUsername: $Usuario - Criado") "Green"
    $null = Set-ItemProperty $RegPath 'DefaultPassword' -Value "$Senha" -Type String
    Write-PowerToolLine "Valor" ("DefaultPassword: $Senha - Criado") "Green"
} else {
    # Remover as chaves DefaultUsername e DefaultPassword se o AutoAdminLogon estiver desabilitado
    if (Test-Path $regPath) {
        $usernameExists = Get-ItemProperty -Path $regPath -Name 'DefaultUsername' -ErrorAction SilentlyContinue
        if ($usernameExists) {
            $usernameValue = Get-ItemPropertyValue -Path $regPath -Name 'DefaultUsername'
            $null = Remove-ItemProperty -Confirm:$false $regPath -Name 'DefaultUsername'
            Write-PowerToolLine "Valor" ("DefaultUsername: $usernameValue Removido") "Green"
        } else {
            Write-PowerToolLine "Valor" "DefaultUsername: Nao havia um valor" "Yellow"
        }
    }

    if (Test-Path $regPath) {
        $passwordExists = Get-ItemProperty -Path $regPath -Name 'DefaultPassword' -ErrorAction SilentlyContinue
        if ($passwordExists) {
            $passwordValue = Get-ItemPropertyValue -Path $regPath -Name 'DefaultPassword'
            $null = Remove-ItemProperty -Confirm:$false $regPath -Name 'DefaultPassword'
            Write-PowerToolLine "Valor" ("DefaultPassword: $passwordValue Removido") "Green"
        } else {
            Write-PowerToolLine "Valor" "DefaultPassword: Nao havia um valor" "Yellow"
        }
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
