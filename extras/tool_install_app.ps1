<#
    Copyright: (c) Flex IT - 2026
    Function: Instalar Aplicativo
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


# Header
#----------------------------------------------------------------------------------------------
# Get the current script directory
$scriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path -Parent

# Get the current script name
$scriptName = [System.IO.Path]::GetFileName($MyInvocation.MyCommand.Path)


# Show local header
Write-PowerToolHeader -Script $scriptName -Titulo "Instalar aplicativos"
#----------------------------------------------------------------------------------------------

# Start actions
#----------------------------------------------------------------------------------------------

# URL do instalador do 7-Zip
#----------------------------------------------------------------------------------------------
$url = "https://www.7-zip.org/a/7z1900-x64.exe"
$installerPath = "C:\Temp\7z_installer.exe"
Write-Host "|" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Aplicativo") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} "   -f "7-zip" ) -NoNewline -ForegroundColor Cyan
Write-Host "|" -ForegroundColor Cyan

Write-Host "|" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " URL") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} "   -f "$url" ) -NoNewline -ForegroundColor Yellow
Write-Host "|" -ForegroundColor Cyan

Write-Host "|" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Arquivo Temporario") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} "   -f "$installerPath" ) -NoNewline -ForegroundColor Yellow
Write-Host "|" -ForegroundColor Cyan
# Criar o diretorio se nao existir
$directory = [System.IO.Path]::GetDirectoryName($installerPath)
if (-not (Test-Path $directory -PathType Container)) {
    New-Item -ItemType Directory -Path $directory | Out-Null
}
# Baixar o instalador com exibicao de progresso
Invoke-WebRequest -Uri $url -OutFile $installerPath -UseBasicParsing
# Executar a instalacao silenciosa
Start-Process -FilePath $installerPath -ArgumentList "/S" -Wait
# Remover o instalador apos a instalacao (opcional)
Remove-Item -Confirm:$false -Path $installerPath
Write-PowerToolBorder '|' '|' 'gray'
#----------------------------------------------------------------------------------------------

# URL do instalador do AnyDesk
#----------------------------------------------------------------------------------------------
$url = "https://download.anydesk.com/AnyDesk.exe"
$installerPath = "C:\Temp\AnyDesk_Installer.exe"
Write-Host "|" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Aplicativo") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} "   -f "Anydesk" ) -NoNewline -ForegroundColor Cyan
Write-Host "|" -ForegroundColor Cyan
Write-Host "|" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " URL") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} "   -f "$url" ) -NoNewline -ForegroundColor Yellow
Write-Host "|" -ForegroundColor Cyan
Write-Host "|" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Arquivo Temporario") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} "   -f "$installerPath" ) -NoNewline -ForegroundColor Yellow
Write-Host "|" -ForegroundColor Cyan
# Criar o diretorio se nao existir
$directory = [System.IO.Path]::GetDirectoryName($installerPath)
if (-not (Test-Path $directory -PathType Container)) {
    New-Item -ItemType Directory -Path $directory | Out-Null
}
# Baixar o instalador com exibicao de progresso
Invoke-WebRequest -Uri $url -OutFile $installerPath -UseBasicParsing
# Caminho de instalacao do AnyDesk
$installPath = "C:\Program Files (x86)\AnyDesk"
# Instalacao do AnyDesk
Start-Process -FilePath $installerPath -ArgumentList "--install `"$installPath`" --start-with-win --silent --create-shortcuts --create-desktop-icon" -Wait

# Registrar a chave de licenca
$licenseKey = "licence_keyABC"
$processStartInfo = New-Object System.Diagnostics.ProcessStartInfo
$processStartInfo.FileName = "$installPath\AnyDesk.exe"
$processStartInfo.Arguments = "--register-licence"
$processStartInfo.RedirectStandardInput = $true
$processStartInfo.UseshellExecute = $false
$processStartInfo.CreateNoWindow = $true

$process = New-Object System.Diagnostics.Process
$process.StartInfo = $processStartInfo
$process.Start() | Out-Null
$process.StandardInput.WriteLine($licenseKey)
$process.WaitForExit()

# Definir senha do AnyDesk
$password = "password123"
$processStartInfo.Arguments = "--set-password"

# Criar um novo objeto Process para a segunda execution
$process = New-Object System.Diagnostics.Process
$process.StartInfo = $processStartInfo
$process.Start() | Out-Null
$process.StandardInput.WriteLine($password)
$process.WaitForExit()
# Remover o instalador apos a instalacao (opcional)
Remove-Item -Confirm:$false -Path $installerPath
Write-PowerToolBorder '|' '|' 'gray'
#----------------------------------------------------------------------------------------------

# URL do instalador do Google Chrome
#----------------------------------------------------------------------------------------------
$url = "https://dl.google.com/chrome/install/375.126/chrome_installer.exe"
$installerPath = "C:\Temp\Chrome_Installer.exe"
Write-Host "|" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Aplicativo") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} "   -f "Google Chrome" ) -NoNewline -ForegroundColor Cyan
Write-Host "|" -ForegroundColor Cyan
Write-Host "|" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " URL") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} "   -f "$url" ) -NoNewline -ForegroundColor Yellow
Write-Host "|" -ForegroundColor Cyan
Write-Host "|" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Arquivo Temporario") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} "   -f "$installerPath" ) -NoNewline -ForegroundColor Yellow
Write-Host "|" -ForegroundColor Cyan
# Criar o diretorio se nao existir
$directory = [System.IO.Path]::GetDirectoryName($installerPath)
if (-not (Test-Path $directory -PathType Container)) {
    New-Item -ItemType Directory -Path $directory | Out-Null
}
# Baixar o instalador com exibicao de progresso
Invoke-WebRequest -Uri $url -OutFile $installerPath -UseBasicParsing
# Executar a instalacao silenciosa
Start-Process -FilePath $installerPath -ArgumentList "/silent /install" -Wait
# Remover o instalador apos a instalacao (opcional)
Remove-Item -Confirm:$false -Path $installerPath
#----------------------------------------------------------------------------------------------

# Applying changes
#----------------------------------------------------------------------------------------------
rundll32.exe user32.dll, UpdatePerUserSystemParameters
#----------------------------------------------------------------------------------------------

# Rodape
#----------------------------------------------------------------------------------------------
# Get the current script directory
$CurrentScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path -Parent


