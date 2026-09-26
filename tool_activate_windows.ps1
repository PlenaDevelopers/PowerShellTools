<#
    Copyright: (c) Flex IT - 2026
    Function: Ativar Windows
    Description: Script Powershell do pacote PowerTool para execution automated em Windows 10 e Windows 11.
#>

# Parametro de entrada
Param (
    [string]$KmsServer = "kms.digiboy.ir" # Servidor KMS. Use kms.core.windows.net (Original da Microsoft)
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
Write-PowerToolHeader -Script $scriptName -Titulo "Ativar o Microsoft Windows"
#----------------------------------------------------------------------------------------------

# Start actions
#----------------------------------------------------------------------------------------------
Write-PowerToolLine "Versoes Suportadas" "Serial Utilizado" "Yellow"
Write-PowerToolBorder '+' '+' 'Cyan'

# Windows 10 Professional                                 W269N-WFGWX-YVC9B-4J6C9-T83GX
Write-PowerToolLine "Windows 10 Professional" "W269N-WFGWX-YVC9B-4J6C9-T83GX" "Gray"
# Windows 10 Professional N                               MH37W-N47XK-V7XM9-C7227-GCQG9
Write-PowerToolLine "Windows 10 Professional N" "MH37W-N47XK-V7XM9-C7227-GCQG9" "Gray"
# Windows 10 Education                                    NW6C2-QMPVW-D7KKK-3GKT6-VCFB2
Write-PowerToolLine "Windows 10 Education" "NW6C2-QMPVW-D7KKK-3GKT6-VCFB2" "Gray"
# Windows 10 Education N                                  2WH4N-8QGBV-H22JP-CT43Q-MDWWJ
Write-PowerToolLine "Windows 10 Education N" "2WH4N-8QGBV-H22JP-CT43Q-MDWW" "Gray"
# Windows 10 Enterprise                                   NPPR9-FWDCX-D2C8J-H872K-2YT43
Write-PowerToolLine "Windows 10 Enterprise n" "NPPR9-FWDCX-D2C8J-H872K-2YT43" "Gray"
# Windows 10 Enterprise N                                 DPH2V-TTNVB-4X9Q3-TJR4H-KHJW4
Write-PowerToolLine "Windows 10 Enterprise N" "DPH2V-TTNVB-4X9Q3-TJR4H-KHJW4" "Gray"
# Windows 10 Enterprise N G (Goverment Edition)           44RPN-FTY23-9VTTB-MP9BX-T84FV
Write-PowerToolLine "Windows 10 Enterprise N G" "44RPN-FTY23-9VTTB-MP9BX-T84FV" "Gray"
# Windows 10 Enterprise 2015 LTSB                         WNMTR-4C88C-JK8YV-HQ7T2-76DF9
Write-PowerToolLine "Windows 10 Ent. 2015 LTSB" "WNMTR-4C88C-JK8YV-HQ7T2-76DF9" "Gray"
# Windows 10 Enterprise 2015 LTSB N                       2F77B-TNFGY-69QQF-B8YKP-D69TJ
Write-PowerToolLine "Windows 10 Ent. 2015 LTSB N " "2F77B-TNFGY-69QQF-B8YKP-D69TJ" "Gray"
# Windows 10 Education                                    NW6C2-QMPVW-D7KKK-3GKT6-VCFB2
Write-PowerToolLine "Windows 10 Education" "NW6C2-QMPVW-D7KKK-3GKT6-VCFB2" "Gray"
# Windows 10 Education N                                  2WH4N-8QGBV-H22JP-CT43Q-MDWWJ
Write-PowerToolLine "Windows 10 Education N " "2WH4N-8QGBV-H22JP-CT43Q-MDWWJ" "Gray"
# Windows 10 PPIPRO (Surface Hub Edition)                 XKCNC-J26Q9-KFHD2-FKTHY-KD72Y
Write-PowerToolLine "Windows 10 PPIPRO" "XKCNC-J26Q9-KFHD2-FKTHY-KD72Y" "Gray"
# Windows 10 Home                                         TX9XD-98N7V-6WMQ6-BX7FG-H8Q99
Write-PowerToolLine "Windows 10 Home" "TX9XD-98N7V-6WMQ6-BX7FG-H8Q99" "Gray"
# Windows 10 Home N                                       3KHY7-WNT83-DGQKR-F7HPR-844BM
Write-PowerToolLine "Windows 10 Home N" "3KHY7-WNT83-DGQKR-F7HPR-844BM" "Gray"
# Windows 10 Home Single Language                         7HNRX-D7KGG-3K4RQ-4WPJ4-YTDFH
Write-PowerToolLine "Windows 10 Home Sing Lang " "7HNRX-D7KGG-3K4RQ-4WPJ4-YTDFH" "Gray"
# Windows 10 Home Country Specific                        PVMJN-6DFY6-9CCP6-7BKTT-D3WVR
Write-PowerToolLine "Windows 10 Home Coun Specific" "PVMJN-6DFY6-9CCP6-7BKTT-D3WVR" "Gray"
# Windows Server 2016                                     CB7KF-BWN84-R7R2Y-793K2-8XDDG
Write-PowerToolLine "Windows Server 2016 Datacent" "CB7KF-BWN84-R7R2Y-793K2-8XDDG" "Gray"
# Windows Server 2016                                     WC2BQ-8NRM3-FDDYY-2BFGV-KHKQY
Write-PowerToolLine "Windows Server 2016 Standard" "WC2BQ-8NRM3-FDDYY-2BFGV-KHKQY" "Gray"
# Windows Server 2019                                     WMDGN-G9PQG-XVVXX-R3X43-63DFG
Write-PowerToolLine "Windows Server 2019" "WMDGN-G9PQG-XVVXX-R3X43-63DFG" "Gray"
# Windows Server 2022                                     VDYBN-27WPP-V4HQT-9VMD4-VMK7H
Write-PowerToolLine "Windows Server 2022" "VDYBN-27WPP-V4HQT-9VMD4-VMK7H" "Gray"
Write-PowerToolBorder '|' '|' 'Cyan'
#----------------------------------------------------------------------------------------------

# Start actions
#----------------------------------------------------------------------------------------------
$os = (Get-CimInstance Win32_OperatingSystem).Caption
Write-PowerToolLine "Sistema Operacional" $os "Cyan"
if ($os -like '*Windows 10 Enterprise*') {
    $chave = "NPPR9-FWDCX-D2C8J-H872K-2YT43"
}
if ($os -like '*Windows 11*') {
    $chave = "W269N-WFGWX-YVC9B-4J6C9-T83GX"
}
if ($os -like '*Windows 10 Pro*') {
    $chave = "W269N-WFGWX-YVC9B-4J6C9-T83GX"
}
if ($os -like '*Windows 10 N*') {
    $chave = "MH37W-N47XK-V7XM9-C7227-GCQG9"
}
if ($os -like '*Windows 10 Home*') {
    $chave = "TX9XD-98N7V-6WMQ6-BX7FG-H8Q99"
}
if ($os -like '*Server 2016 Standard*') {
    $chave = "WC2BQ-8NRM3-FDDYY-2BFGV-KHKQY"
}
if ($os -like '*Server 2016 Datacenter*') {
    $chave = "CB7KF-BWN84-R7R2Y-793K2-8XDDG"
}
if ($os -like '*Server 2019*') {
    $chave = "WMDGN-G9PQG-XVVXX-R3X43-63DFG"
}
if ($os -like '*Server 2022*') {
    $chave = "VDYBN-27WPP-V4HQT-9VMD4-VMK7H"
}
Write-PowerToolLine "Chave" $chave "Cyan"
$null = & cscript.exe C:\Windows\System32\slmgr.vbs /ipk $chave
Write-PowerToolLine "Servidor KMS" $KmsServer "Cyan"
$null = & cscript.exe C:\Windows\System32\slmgr.vbs /skms $KmsServer

# Ativar o Windows
$null = & cscript.exe C:\Windows\System32\slmgr.vbs /ato

$activationStatus = (Get-CimInstance -ClassName SoftwareLicensingProduct -Filter "Name like 'Windows%'" | Where-Object { $_.LicenseStatus -ne $null }).LicenseStatus

if ($activationStatus -eq 1) {
    Write-PowerToolLine "Licenciamento" "O Windows esta ativado." "Green"
}
else {
    Write-PowerToolLine "Licenciamento" "O Windows nao esta ativado." "Red"
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
