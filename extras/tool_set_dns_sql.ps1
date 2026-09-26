<#
    Copyright: (c) Flex IT - 2026
    Function: Definir DNS SQL
    Description: Script Powershell do pacote PowerTool para execution automated em Windows 10 e Windows 11.
#>

param(
    [string]$Servidor = "192.0.2.10",
    [string]$BancoDeDados = "SIGLA",
    [string]$Usuario = "sa",
    [string]$Senha = "M@rzz@llo0101",
    [string]$NomeDaConexao = "SIGLA",
    [string]$TipoDSN = "1"  # 1 para DSN do usuario, 2 para DSN do sistema
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
Write-PowerToolHeader -Script $scriptName -Titulo "Conectar ao Banco de Dados SQL Server e Criar DSN"
#----------------------------------------------------------------------------------------------

# Start actions
#----------------------------------------------------------------------------------------------
function Testar-Conexao {
    param (
        [string]$ConnectionString
    )
    try {
        $connection = New-Object System.Data.SqlClient.SqlConnection($ConnectionString)
        $connection.Open()
        Write-PowerToolLine "Status" "Conectado" "Cyan"
        $connection.Close()
    } catch {
        Write-PowerToolLine "Status" "Failure na conexao: $_" "Cyan"
    }
}

function Criar-DSN {
    param (
        [string]$NomeDSN,
        [string]$Driver,
        [string]$Servidor,
        [string]$BancoDeDados,
        [string]$Usuario,
        [string]$Senha,
        [string]$TipoDSN
    )

    $dsnPath = if ($TipoDSN -eq "1") {
        "HKCU:\Software\ODBC\ODBC.INI\$NomeDSN"  # DSN do usuario
    } elseif ($TipoDSN -eq "2") {
        "HKLM:\Software\ODBC\ODBC.INI\$NomeDSN"  # DSN do sistema
    } else {
        Write-Host "Tipo DSN invalido. Use 1 para DSN do usuario ou 2 para DSN do sistema." -ForegroundColor Red
        return
    }

    # Adicionar DSN ao registro
    if (-not (Test-Path $dsnPath)) {
        $null = New-Item -Path $dsnPath -Force | Out-Null
        }
        Set-ItemProperty -Path $dsnPath -Name "Driver" -Value $Driver
        Write-PowerToolLine "Driver" $Driver "White"
        Set-ItemProperty -Path $dsnPath -Name "Server" -Value $Servidor
        Write-PowerToolLine "Servidor" $Servidor "White"
        Set-ItemProperty -Path $dsnPath -Name "Database" -Value $BancoDeDados
        Write-PowerToolLine "Banco de Dados" $BancoDeDados "White"
        Set-ItemProperty -Path $dsnPath -Name "Uid" -Value $Usuario
        Write-PowerToolLine "Usuario" $Usuario "White"
        Set-ItemProperty -Path $dsnPath -Name "Pwd" -Value $Senha
        Write-PowerToolLine "Senha" $Senha "White"
        Set-ItemProperty -Path $dsnPath -Name "Description" -Value $Descricao
        Write-PowerToolLine "Descricao" $Descricao "White"
        Set-ItemProperty -Path $dsnPath -Name "Encrypt" -Value $Encrypt
        Write-PowerToolLine "Encriptacao" $Encrypt "White"
        Set-ItemProperty -Path $dsnPath -Name "TrustServerCertificate" -Value $TrustServerCertificate
        Write-PowerToolLine "Certificado" $TrustServerCertificate "White"
        Set-ItemProperty -Path $dsnPath -Name "ClientCertificate" -Value $ClientCertificate
        Write-PowerToolLine "Certificado do Cliente" $ClientCertificate "White"
        Set-ItemProperty -Path $dsnPath -Name "KeystoreAuthentication" -Value $KeystoreAuthentication
        Write-PowerToolLine "Autenticacao" $KeystoreAuthentication "White"
        Set-ItemProperty -Path $dsnPath -Name "KeystorePrincipalId" -Value $KeystorePrincipalId
        Write-PowerToolLine "ID" $KeystorePrincipalId "White"
        Set-ItemProperty -Path $dsnPath -Name "KeystoreSecret" -Value $KeystoreSecret
        Write-PowerToolLine "Secret" $KeystoreSecret "White"
        Set-ItemProperty -Path $dsnPath -Name "KeystoreLocation" -Value $KeystoreLocation
        Write-PowerToolLine "Location" $KeystoreLocation "White"
        Set-ItemProperty -Path $dsnPath -Name "LastUser" -Value $LastUser
        Write-PowerToolLine "Ultimo Usuario" $LastUser "White"
        Set-ItemProperty -Path $dsnPath -Name "Trusted_Connection" -Value $Trusted_Connection
        Write-PowerToolLine "Conexao Confiavel" $Trusted_Connection "White"
        Write-PowerToolLine "DSN" "DSN '$NomeDSN' criado com success." "Cyan"
}

# Define a string de conexao
$connectionString = "Server=$Servidor;Database=$BancoDeDados;User Id=$Usuario;Password=$Senha;"

# Testa a conexao
Testar-Conexao -ConnectionString $connectionString

# Cria o DSN
$dsnDriver = "{SQL Server}"
Criar-DSN -NomeDSN $NomeDaConexao -Driver $dsnDriver -Servidor $Servidor -BancoDeDados $BancoDeDados -Usuario $Usuario -Senha $Senha -TipoDSN $TipoDSN
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