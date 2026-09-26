<#
    Copyright: (c) Flex IT - 2026
    Function: Criar Usuarios em Lote
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


# Lista de usuarios a serem criados
$usuarios = @(
    @{ Name = "Teste de Usuario 1"; Username = "teste1"; Password = "SenhaSegura123!"; Group = "Usuarios"; Description = "Usuario de Teste 1" },
    @{ Name = "Teste de Usuario 2"; Username = "teste2"; Password = "SenhaSegura123!"; Group = "Administradores"; Description = "Usuario de Teste 2" },
    @{ Name = "Teste de Usuario 3"; Username = "teste3"; Password = "SenhaSegura123!"; Group = "Usuarios"; Description = "Usuario de Teste de Script" },
    @{ Name = "Teste de Usuario 4"; Username = "teste4"; Password = "SenhaSegura123!"; Group = "Usuarios"; Description = "Usuario de Teste 4" }
)

# Header
#----------------------------------------------------------------------------------------------
# Get the current script directory
$scriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path -Parent

# Get the current script name
$scriptName = [System.IO.Path]::GetFileName($MyInvocation.MyCommand.Path)


# Show local header
Write-PowerToolHeader -Script $scriptName -Titulo "Criar Usuarios no Windows"
#----------------------------------------------------------------------------------------------

# Start actions
#----------------------------------------------------------------------------------------------
# Funcao para verificar e criar grupos se necessario
function VerificarOuCriarGrupo($grupo) {
    if (-not (Get-LocalGroup -Name $grupo -ErrorAction SilentlyContinue)) {
        Write-PowerToolLine "Criando Grupo" $grupo "Green"
        $null = New-LocalGroup -Name $grupo
    }
}

# Start actions
#----------------------------------------------------------------------------------------------
foreach ($usuario in $usuarios) {
    $nomeUsuario = $usuario.Username
    $senhaUsuario = $usuario.Password
    $grupoUsuario = $usuario.Group
    $descricaoUsuario = $usuario.Description

    # Verifica e cria o grupo se necessario
    VerificarOuCriarGrupo -grupo $grupoUsuario

    # Verifica se o usuario ja existe
    if (-not (Get-LocalUser -Name $nomeUsuario -ErrorAction SilentlyContinue)) {
        # Cria o usuario
        $null = New-LocalUser -Name $nomeUsuario -Password (ConvertTo-SecureString $senhaUsuario -AsPlainText -Force) -FullName $usuario.Name -Description $usuario.Description -PasswordNeverExpires
        Write-PowerToolLine "Usuario Criado" $($nomeUsuario +" - " +$grupoUsuario) "Green"
        # Aguardar um momento para garantir que o sistema reconheca o usuario
        Start-Sleep -Seconds 2

        try {
            # Adiciona o usuario ao grupo especificado
            $null = Add-LocalGroupMember -Group $grupoUsuario -Member $nomeUsuario -ErrorAction Stop

            # Verifica se o usuario foi adicionado ao grupo
            $isMember = Get-LocalGroupMember -Group $grupoUsuario | Where-Object { $_.Name -eq $nomeUsuario }

            if ($isMember) {
                Write-PowerToolLine "Adicionado ao Grupo" $grupoUsuario "Green"
            } else {
                Write-PowerToolLine "Failure ao Adicionar ao Grupo" $grupoUsuario "Red"
            }
        } catch {
            Write-PowerToolLine "Erro ao Adicionar ao Grupo" $_.Exception.Message "Red"
        }
    } else {
        Write-PowerToolLine "Usuario ja existe" $nomeUsuario "Red"
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