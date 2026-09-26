<#
    Copyright: (c) Flex IT - 2026
    Function: Configurar Login Automatico
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

<#
    Function: Configurar Login Automatico no Windows 10/11
	Copyright:  Flex IT - 2026
	Date: Maio/2026

	Autor: PowerTool Team
	Contato: support@example.com
	------------------------------------------------------------------------------
#>

# Header
#----------------------------------------------------------------------------------------------
if ($PSScriptRoot) {
    $scriptDirectory = $PSScriptRoot
}
else {
    $scriptDirectory = (Get-Location).Path
}

$scriptName = $MyInvocation.MyCommand.Name

if ([string]::IsNullOrWhiteSpace($scriptName)) {
    $scriptName = "AutoLogon.ps1"
}


Write-PowerToolHeader -Script $scriptName -Titulo "Configurar Login Automatico"
#----------------------------------------------------------------------------------------------

function Escrever-Linha {
    param (
        [string]$Campo,
        [string]$Valor,
        [string]$Cor = "White"
    )
    Write-PowerToolLine $Campo $Valor "$Cor"
}

function Testar-Administrador {
    $usuarioAtual = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($usuarioAtual)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Converter-SecureStringTexto {
    param (
        [System.Security.SecureString]$SecureString
    )

    $ptr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)

    try {
        return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)
    }
    finally {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)
    }
}

function Testar-CredencialLocal {
    param (
        [string]$Usuario,
        [string]$Senha,
        [string]$Dominio
    )

    Add-Type @"
using System;
using System.Runtime.InteropServices;

public class LogonHelper {
    [DllImport("advapi32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
    public static extern bool LogonUser(
        string lpszUsername,
        string lpszDomain,
        string lpszPassword,
        int dwLogonType,
        int dwLogonProvider,
        out IntPtr phToken
    );

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern bool CloseHandle(IntPtr hObject);
}
"@

    $token = [IntPtr]::Zero

    $ok = [LogonHelper]::LogonUser(
        $Usuario,
        $Dominio,
        $Senha,
        2,
        0,
        [ref]$token
    )

    if ($token -ne [IntPtr]::Zero) {
        [LogonHelper]::CloseHandle($token) | Out-Null
    }

    return $ok
}

if (-not (Testar-Administrador)) {
    Escrever-Linha "Erro" "Execute este script como Administrador." "Red"
    Start-Sleep -Seconds 1
    exit
}

# Detectar Windows
#----------------------------------------------------------------------------------------------
$os = Get-CimInstance Win32_OperatingSystem
$build = [int]$os.BuildNumber

if ($build -ge 22000) {
    $versaoWindows = "Windows 11"
}
elseif ($build -ge 10240) {
    $versaoWindows = "Windows 10"
}
else {
    $versaoWindows = "Windows nao suportado"
}

Escrever-Linha "Sistema detectado" "$versaoWindows - Build $build" "Green"
#----------------------------------------------------------------------------------------------

# Correcoes Netplwiz/UserPasswords2
#----------------------------------------------------------------------------------------------
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\PasswordLess\Device" /v DevicePasswordLessBuildVersion /t REG_DWORD /d 0 /f | Out-Null
Escrever-Linha "Correcao PasswordLess" "Aplicada" "Green"

reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon /t REG_SZ /d 0 /f | Out-Null
Escrever-Linha "AutoAdminLogon antigo" "Resetado" "Green"

reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v DontDisplayLastUserName /t REG_DWORD /d 0 /f | Out-Null
Escrever-Linha "Politica ultimo usuario" "Liberada" "Green"

reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableAutomaticRestartSignOn /t REG_DWORD /d 0 /f | Out-Null
Escrever-Linha "Restart Sign-On" "Liberado" "Green"
#----------------------------------------------------------------------------------------------

# Listar usuarios locais
#----------------------------------------------------------------------------------------------
Write-Host ""
Escrever-Linha "Usuarios locais" "Listando usuarios habilitados" "Yellow"
Write-Host ""

$usuarios = Get-LocalUser | Where-Object { $_.Enabled -eq $true } | Sort-Object Name

if (-not $usuarios -or $usuarios.Count -eq 0) {
    Escrever-Linha "Erro" "Nenhum usuario local habilitado encontrado." "Red"
    Start-Sleep -Seconds 1
    exit
}

$indice = 1
$listaUsuarios = @()

foreach ($usuario in $usuarios) {
    $listaUsuarios += [PSCustomObject]@{
        Indice = $indice
        Nome   = $usuario.Name
    }

    Write-Host "|" -NoNewline -ForegroundColor Cyan
    Write-Host (" {0,2}. " -f $indice) -NoNewline -ForegroundColor Yellow
    Write-Host ("{0,-110}" -f $usuario.Name) -NoNewline -ForegroundColor White
    Write-Host "|" -ForegroundColor Cyan

    $indice++
}

Write-Host ""
$usuarioParametro = $env:POWERTOOL_AUTOLOGIN_USER
if ($args.Count -gt 0 -and -not [string]::IsNullOrWhiteSpace($args[0])) {
    $usuarioParametro = $args[0]
}

if ([string]::IsNullOrWhiteSpace($usuarioParametro)) {
    $usuarioParametro = $env:USERNAME
}

$usuarioSelecionado = $listaUsuarios | Where-Object { $_.Nome -ieq $usuarioParametro } | Select-Object -First 1

if (-not $usuarioSelecionado) {
    Escrever-Linha "Erro" "Usuario nao encontrado ou desabilitado: $usuarioParametro" "Red"
    Start-Sleep -Seconds 1
    exit
}

$nomeUsuario = $usuarioSelecionado.Nome
#----------------------------------------------------------------------------------------------

# Detectar dominio/local
#----------------------------------------------------------------------------------------------
$computador = $env:COMPUTERNAME
$dominio = $computador

try {
    $cs = Get-CimInstance Win32_ComputerSystem
    if ($cs.PartOfDomain -eq $true) {
        $dominio = $cs.Domain
    }
}
catch {
    $dominio = $computador
}

Escrever-Linha "Dominio/Computador" $dominio "Green"
#----------------------------------------------------------------------------------------------

# Solicitar e validar senha
#----------------------------------------------------------------------------------------------
Write-Host ""
Escrever-Linha "Usuario selecionado" $nomeUsuario "Green"

$senhaTexto = $env:POWERTOOL_AUTOLOGIN_PASSWORD
if ($args.Count -gt 1 -and -not [string]::IsNullOrWhiteSpace($args[1])) {
    $senhaTexto = $args[1]
}

if ([string]::IsNullOrWhiteSpace($senhaTexto)) {
    Escrever-Linha "Erro" "Senha vazia. Operation cancelada." "Red"
    Start-Sleep -Seconds 1
    exit
}

Escrever-Linha "Validando senha" "Aguarde..." "Yellow"

$senhaValida = Testar-CredencialLocal -Usuario $nomeUsuario -Senha $senhaTexto -Dominio $dominio

if (-not $senhaValida) {
    Escrever-Linha "Erro" "Senha invalida. Login automatico nao foi configurado." "Red"

    reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultPassword /f 2>$null | Out-Null
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon /t REG_SZ /d 0 /f | Out-Null
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v ForceAutoLogon /t REG_SZ /d 0 /f | Out-Null

    Start-Sleep -Seconds 1
    exit
}

Escrever-Linha "Senha" "Validada com success" "Green"
#----------------------------------------------------------------------------------------------

# Aplicar login automatico
#----------------------------------------------------------------------------------------------
try {
    $winlogon = "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"

    reg add $winlogon /v AutoAdminLogon /t REG_SZ /d 1 /f | Out-Null
    reg add $winlogon /v DefaultUserName /t REG_SZ /d "$nomeUsuario" /f | Out-Null
    reg add $winlogon /v DefaultPassword /t REG_SZ /d "$senhaTexto" /f | Out-Null
    reg add $winlogon /v DefaultDomainName /t REG_SZ /d "$dominio" /f | Out-Null
    reg add $winlogon /v ForceAutoLogon /t REG_SZ /d 1 /f | Out-Null

    Escrever-Linha "Login automatico" "Configurado com success" "Green"
    Escrever-Linha "Usuario" $nomeUsuario "Green"
}
catch {
    Escrever-Linha "Erro" "Failure ao configurar login automatico." "Red"
    Escrever-Linha "Detalhe" $_.Exception.Message "Red"
    Start-Sleep -Seconds 1
    exit
}
#----------------------------------------------------------------------------------------------

# Aplicar alteracoes
#----------------------------------------------------------------------------------------------
try {
    rundll32.exe user32.dll, UpdatePerUserSystemParameters
    Escrever-Linha "Atualizacao sistema" "Parameters atualizados" "Green"
}
catch {
    Escrever-Linha "Atualizacao sistema" "Nao foi possivel atualizar parametros" "Yellow"
}
#----------------------------------------------------------------------------------------------

Write-Host ""
Escrever-Linha "Aviso" "A senha fica salva no Registro do Windows para o AutoLogon." "Yellow"
Escrever-Linha "Proximo passo" "Reinicie o computador para testar." "Yellow"

# Rodape
#----------------------------------------------------------------------------------------------
if ($PSScriptRoot) {
    $CurrentScriptDirectory = $PSScriptRoot
}
else {
    $CurrentScriptDirectory = (Get-Location).Path
}


Write-PowerToolFooter
}
else {
    Write-Host "===============================================================================" -ForegroundColor Cyan
