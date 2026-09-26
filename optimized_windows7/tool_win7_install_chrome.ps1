<#
    Copyright: (c) Flex IT - 2026
    Function: Windows 7 Instalar Chrome
    Description: Script Powershell do pacote PowerTool para execution automated em Windows 10 e Windows 11.
#>


<#
    Instala Google Chrome no Windows 7.
    Compativel com Powershell 2.0.
#>

param(
    [string]$InstallerPath = ""
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


$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $scriptDir "lib_win7.ps1")
Assert-Admin $MyInvocation.MyCommand.Path
Write-Header "Windows 7 - Instalar Google Chrome"

$chromePaths = @(
    "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
    "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
    "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe"
)

foreach ($chromePath in $chromePaths) {
    if ($chromePath -and (Test-Path $chromePath)) {
        Write-Line "Google Chrome" "Ja instalado: $chromePath" "Green"
        Write-Footer "Nenhuma instalacao necessaria"
        exit
    }
}

$tempDir = Join-Path $env:SystemDrive "Temp"
if (-not (Test-Path $tempDir)) {
    New-Item -Path $tempDir -ItemType Directory -Force | Out-Null
}

$is64 = $false
try {
    $os = Get-WmiObject Win32_OperatingSystem -ErrorAction SilentlyContinue
    if ($os.OSArchitecture -match "64") {
        $is64 = $true
    }
} catch {
    if ($env:PROCESSOR_ARCHITECTURE -match "64" -or $env:PROCESSOR_ARCHITEW6432 -match "64") {
        $is64 = $true
    }
}

function Test-ExeValido {
    param([string]$Path)

    if (-not (Test-Path $Path)) {
        return $false
    }

    $item = Get-Item $Path -ErrorAction SilentlyContinue
    if ($item -eq $null -or $item.Length -lt 1048576) {
        return $false
    }

    $stream = $null
    try {
        $stream = [System.IO.File]::OpenRead($Path)
        $bytes = New-Object byte[] 2
        [void]$stream.Read($bytes, 0, 2)
        return ($bytes[0] -eq 77 -and $bytes[1] -eq 90)
    } catch {
        return $false
    } finally {
        if ($stream -ne $null) {
            $stream.Close()
        }
    }
}

if ([string]::IsNullOrEmpty($InstallerPath)) {
    if ($is64) {
        $localCandidates = @(
            (Join-Path $scriptDir "ChromeStandaloneSetup64.exe"),
            (Join-Path $scriptDir "ChromeStandaloneSetup.exe"),
            (Join-Path $scriptDir "chrome_installer.exe"),
            (Join-Path (Split-Path -Parent $scriptDir) "updates\chrome\ChromeStandaloneSetup64.exe"),
            (Join-Path (Split-Path -Parent $scriptDir) "updates\chrome\ChromeStandaloneSetup.exe"),
            (Join-Path (Split-Path -Parent $scriptDir) "updates\chrome\chrome_installer.exe")
        )
    } else {
        $localCandidates = @(
            (Join-Path $scriptDir "ChromeStandaloneSetup.exe"),
            (Join-Path $scriptDir "chrome_installer.exe"),
            (Join-Path $scriptDir "ChromeStandaloneSetup64.exe"),
            (Join-Path (Split-Path -Parent $scriptDir) "updates\chrome\ChromeStandaloneSetup.exe"),
            (Join-Path (Split-Path -Parent $scriptDir) "updates\chrome\chrome_installer.exe"),
            (Join-Path (Split-Path -Parent $scriptDir) "updates\chrome\ChromeStandaloneSetup64.exe")
        )
    }

    foreach ($candidate in $localCandidates) {
        if (Test-ExeValido $candidate) {
            $InstallerPath = $candidate
            break
        }
    }
}

if ([string]::IsNullOrEmpty($InstallerPath)) {
    $InstallerPath = Join-Path $tempDir "Chrome_Installer.exe"
    $url = "https://dl.google.com/chrome/install/375.126/chrome_installer.exe"

    Write-Line "Download" $url "White"
    Write-Line "Destino" $InstallerPath "White"

    try {
        [Net.ServicePointManager]::SecurityProtocol = 3072 -bor 768 -bor 192
    } catch {
    }

    $client = New-Object System.Net.WebClient
    $client.Headers.Add("User-Agent", "Mozilla/5.0")
    try {
        $client.DownloadFile($url, $InstallerPath)
    } catch {
        Write-Line "Erro" "Failure ao baixar. Use instalador offline em optimized_windows7 ou updates\chrome." "Red"
        Write-Footer "Chrome nao instalado"
        exit 1
    }

    if (-not (Test-ExeValido $InstallerPath)) {
        Remove-Item -Confirm:$false -LiteralPath $InstallerPath -Force -ErrorAction SilentlyContinue
        Write-Line "Erro" "Download invalido ou incompatovel com este Windows 7." "Red"
        Write-Line "Solucao" "Coloque o Chrome offline compativel em optimized_windows7 ou updates\chrome." "Yellow"
        Write-Footer "Chrome nao instalado"
        exit 1
    }
}

if (-not (Test-ExeValido $InstallerPath)) {
    Write-Line "Erro" "Instalador invalido: $InstallerPath" "Red"
    Write-Footer "Chrome nao instalado"
    exit 1
}

Write-Line "Instalador" $InstallerPath "Green"
Write-Line "Instalacao" "Silenciosa" "White"

try {
    $process = Start-Process -FilePath $InstallerPath -ArgumentList "/silent /install" -Wait -PassThru -ErrorAction Stop
} catch {
    Write-Line "Erro" $_.Exception.Message "Red"
    Write-Footer "Chrome nao instalado"
    exit 1
}

if ($process -ne $null -and ($process.ExitCode -eq 0 -or $process.ExitCode -eq $null)) {
    Write-Footer "Instalacao concluida"
} else {
    Write-Line "Exit code" $process.ExitCode "Yellow"
    Write-Footer "Instalador finalizado com aviso/erro"
}
