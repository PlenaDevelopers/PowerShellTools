<#
    Copyright: (c) Flex IT - 2026
    Function: Atualizar Powershell
    Description: Instala ou atualiza o Powershell 7 usando o instalador oficial da Microsoft em https://aka.ms/install-powershell.ps1.
#>

[CmdletBinding()]
param(
    [switch]$Preview,
    [switch]$HabilitarPSRemoting,
    [switch]$AdicionarMenuExplorer,
    [switch]$CriarTaskAgendada,
    [string]$HorarioTask = "03:00"
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
$UrlInstalador = "https://aka.ms/install-powershell.ps1"
$NomeTask = "FlexIT Atualizar Powershell"

function Initialize-PowerToolConsole {
    Set-Variable -Name ConfirmPreference -Value 'None' -Scope Global
    Set-Variable -Name WhatIfPreference -Value $false -Scope Global
    Set-Variable -Name ProgressPreference -Value 'SilentlyContinue' -Scope Global
    try {
        $logDir = Join-Path -Path $PSScriptRoot -ChildPath 'logs'
        if (-not (Test-Path -LiteralPath $logDir)) { New-Item -Path $logDir -ItemType Directory -Force | Out-Null }
        $logPath = Join-Path -Path $logDir -ChildPath ("PowerTool_{0}_{1}_{2}.log" -f (Get-Date -Format 'yyyyMMdd_HHmmss'), [IO.Path]::GetFileNameWithoutExtension($PSCommandPath), $PID)
        Start-Transcript -Path $logPath -Force | Out-Null
        $global:PowerToolTranscriptActive = $true
        $global:PowerToolTranscriptPath = $logPath
    } catch { $global:PowerToolTranscriptActive = $false }
}

function Stop-PowerToolTranscript {
    try { if ($global:PowerToolTranscriptActive) { Stop-Transcript | Out-Null } } catch { }
}

function Get-PowerToolWidth {
    try { return [Math]::Min([Math]::Max(($Host.UI.RawUI.WindowSize.Width - 4), 96), 160) } catch { return 120 }
}

function Write-PowerToolBorder { param([string]$Left = '+', [string]$Right = '+', [string]$Color = 'Cyan') Write-Host ($Left + ('-' * (Get-PowerToolWidth)) + $Right) -ForegroundColor $Color }
function Write-PowerToolLine {
    param([string]$Campo, [string]$Valor, [string]$CorValor = 'White')
    $width = Get-PowerToolWidth
    $valueWidth = $width - 33
    if ($null -eq $Valor) { $Valor = '' }
    $texto = [string]$Valor
    if ($texto.Length -gt $valueWidth) { $texto = $texto.Substring(0, $valueWidth - 3) + '...' }
    Write-Host ("|{0,-30} : {1}|" -f $Campo, $texto.PadRight($valueWidth)) -ForegroundColor $CorValor
}

function Write-PowerToolHeader {
    param([string]$Script, [string]$Titulo)
    Initialize-PowerToolConsole
    Write-PowerToolBorder '+' '+' 'Yellow'
    Write-PowerToolLine 'Operation' $Titulo 'Yellow'
    Write-PowerToolLine 'Production' (Get-Date).Year 'Yellow'
    Write-PowerToolLine 'Copyright' 'Flex IT' 'Yellow'
    Write-PowerToolLine 'Script' $Script 'White'
    Write-PowerToolBorder '+' '+' 'Cyan'
}

function Write-PowerToolFooter { param([string]$Status = 'Finished') Write-PowerToolBorder '+' '+' 'Cyan'; Write-PowerToolLine 'Process' $Status 'Green'; Write-PowerToolBorder '+' '+' 'Yellow'; Stop-PowerToolTranscript }

function Assert-Admin {
    $identidade = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identidade)
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "Execute este script em um Powershell aberto como Administrador."
    }
}

function Get-PwshVersion {
    $cmd = Get-Command pwsh.exe -ErrorAction SilentlyContinue
    if (-not $cmd) { return "nao instalado" }
    try { return (& $cmd.Source -NoLogo -NoProfile -Command '$PSVersionTable.PSVersion.ToString()') } catch { return "detectado, mas versao indisponivel" }
}

function Install-OrUpdatePowershell {
    $tempDir = Join-Path ([IO.Path]::GetTempPath()) ("flexit-pwsh-" + [guid]::NewGuid().ToString("N"))
    $instaladorLocal = Join-Path $tempDir "install-powershell.ps1"
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    try {
        Write-PowerToolLine "Fonte" $UrlInstalador "Yellow"
        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $UrlInstalador -OutFile $instaladorLocal -UseBasicParsing
        Unblock-File -Path $instaladorLocal -ErrorAction SilentlyContinue
        if (-not (Select-String -Path $instaladorLocal -Pattern "UseMSI" -Quiet)) { throw "O arquivo baixado nao parece ser o instalador oficial esperado." }

        $argumentos = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "`"$instaladorLocal`"", "-UseMSI", "-Quiet")
        if ($Preview) { $argumentos += "-Preview" }
        if ($HabilitarPSRemoting) { $argumentos += "-EnablePSRemoting" }
        if ($AdicionarMenuExplorer) { $argumentos += "-AddExplorerContextMenu" }

        Write-PowerToolLine "Instalacao" "Executando MSI silencioso" "Cyan"
        $processo = Start-Process -FilePath "powershell.exe" -ArgumentList $argumentos -Wait -PassThru -WindowStyle Hidden
        if ($processo.ExitCode -ne 0) { throw "Instalador retornou codigo $($processo.ExitCode)." }
    } finally {
        Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

function Register-UpdateTask {
    $scriptCompleto = (Resolve-Path $PSCommandPath).Path
    $argumentos = "-NoProfile -ExecutionPolicy Bypass -File `"$scriptCompleto`""
    if ($Preview) { $argumentos += " -Preview" }
    if ($HabilitarPSRemoting) { $argumentos += " -HabilitarPSRemoting" }
    if ($AdicionarMenuExplorer) { $argumentos += " -AdicionarMenuExplorer" }
    $acao = New-ScheduledTaskAction -Execute "powershell.exe" -Argument $argumentos
    $gatilho = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At $HorarioTask
    $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest
    $config = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
    Register-ScheduledTask -TaskName $NomeTask -Action $acao -Trigger $gatilho -Principal $principal -Settings $config -Force | Out-Null
    Write-PowerToolLine "Task agendada" "$NomeTask - domingos as $HorarioTask" "Green"
}

try {
    Assert-Admin
    $scriptName = [IO.Path]::GetFileName($PSCommandPath)
    Write-PowerToolHeader -Script $scriptName -Titulo "Atualizar Powershell"
    $antes = Get-PwshVersion
    Write-PowerToolLine "Versao anterior" $antes "Yellow"
    Install-OrUpdatePowershell
    $depois = Get-PwshVersion
    Write-PowerToolLine "Versao atual" $depois "Green"
    if ($CriarTaskAgendada) { Register-UpdateTask }
    Write-PowerToolLine "Aviso" "Abra uma nova janela do terminal para atualizar o PATH." "Yellow"
    Write-PowerToolFooter
} catch {
    Write-PowerToolLine "Erro" $_.Exception.Message "Red"
    Write-PowerToolFooter -Status "Falhou"
    exit 1
}
