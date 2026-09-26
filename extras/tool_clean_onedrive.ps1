<#
    Copyright: (c) Flex IT - 2026
    Function: Limpar OneDrive
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

function Stop-PowerToolExplorer {
    $null = & taskkill.exe /F /IM explorer.exe 2>$null
}

#Script para remover o Microsoft ONEDrive

# Checks whether the script is running as administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    if ($env:POWERTOOL_DASHBOARD -eq '1') {
        Write-Host "Erro: execute o dashboard como administrador." -ForegroundColor Red
        exit 1
    }
    Write-Host "Executando script como administrador..."
    Start-Sleep -Seconds 1
    # Inicia uma nova instancia do Powershell com privilegios de administrador
    Start-Process powershell -Verb runAs -ArgumentList ("-File $($MyInvocation.MyCommand.Path) $args")
    # Encerra a execution deste script
    Exit
}

# Verificar se o processo OneDrive.exe esta em execution
if (Get-Process -Name "OneDrive" -ErrorAction SilentlyContinue) {
    # Se estiver em execution, encerrar o processo
    Stop-Process -Confirm:$false -Name "OneDrive" -Force
}

# Verificar se o processo explorer.exe esta em execution
$explorerProcess = Get-Process -Name "explorer" -ErrorAction SilentlyContinue

if ($explorerProcess -eq $null) {
    # Se o processo explorer nao estiver em execution, inicie-o
    Start-Process explorer
}

if (Test-Path "$env:systemroot\System32\OneDriveSetup.exe") {
    & "$env:systemroot\System32\OneDriveSetup.exe" /uninstall
}
if (Test-Path "$env:systemroot\SysWOW64\OneDriveSetup.exe") {
    & "$env:systemroot\SysWOW64\OneDriveSetup.exe" /uninstall
}

# Criar a chave do Registro se ela ainda nao existir
$null = New-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\OneDrive" -Force | Out-Null

# Definir o valor do Registro para desabilitar o OneDrive
$null = Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\OneDrive" -Name "DisableFileSyncNGSC" -Value 1

# Remover residuos do OneDrive
$null = rm -Recurse -Force -ErrorAction SilentlyContinue "$env:localappdata\Microsoft\OneDrive"
$null = rm -Recurse -Force -ErrorAction SilentlyContinue "$env:programdata\Microsoft OneDrive"
$null = rm -Recurse -Force -ErrorAction SilentlyContinue "C:\OneDriveTemp"

# Remover o OneDrive da barra de tarefas
$null = New-PSDrive -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" -Name "HKCR"
$null = mkdir -Force "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
$null = sp "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" "System.IsPinnedToNameSpaceTree" 0
$null = mkdir -Force "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
$null = sp "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" "System.IsPinnedToNameSpaceTree" 0
$null = Remove-PSDrive -Confirm:$false "HKCR"

# Carregar o Registro do perfil padrao
$null = reg load "HKU\Default" "C:\Users\Default\NTUSER.DAT"

# Verificar se a chave do Registro existe antes de excluir
if (Test-Path "HKU\Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Run") {
    # Excluir a entrada de execution do OneDrive do Registro
    $null = reg delete "HKU\Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "OneDriveSetup" /f
}

# Descarregar o Registro do perfil padrao
$null = reg unload "HKU\Default"

# Remover Entradas do Menu Iniciar
$null = rm -Force -ErrorAction SilentlyContinue "$env:userprofile\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk"

# Atualiza as configuracoes para refletir as mudancas
rundll32.exe user32.dll, UpdatePerUserSystemParameters

# Encerra o processo do Windows Explorer para aplicar as alteracoes imediatamente
Stop-PowerToolExplorer

# Aguarda alguns segundos antes de reiniciar o Windows Explorer
Start-Sleep -Seconds 2

# Remover residuos individuais do OneDrive
$diretorioOnedrive = "$env:WinDir\WinSxS"
$items = Get-ChildItem -Path $diretorioOnedrive -Recurse -Directory | Where-Object { $_.Name -like "*onedrive*" -or $_.Name -like "*settingsync-onedrive*" }

foreach ($item in $items) {
    # Tentar remover o item e capturar excecoes de permissao
    try {
        # Resetar permissoes com icacls
        icacls $item.FullName /reset /T /C
        
        $acl = $item.GetAccessControl() 

        # Obter o SID para o grupo "Everyone"
        $sid = New-Object System.Security.Principal.SecurityIdentifier([System.Security.Principal.WellKnownSidType]::WorldSid, $null)
        6
        # Criar a regra de acesso usando o SID
        $permission = New-Object System.Security.AccessControl.FileSystemAccessRule($sid, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")

        $acl.SetAccessRuleProtection($True, $False)

        $acl.SetAccessRule($permission)
        $item.SetAccessControl($acl)
        
        # Remover arquivos com rm
        rm -Recurse -Force $item.FullName | Out-Null
    } catch {
        Write-Host "Nao foi possivel remover o item $($item.FullName): $($_.Exception.Message)"
    }
}

# Se o processo nao estiver em execution, inicie-o
if ($explorerProcess -eq $null) {
    Start-Process explorer
}

# Atualiza as configuracoes para refletir as mudancas
rundll32.exe user32.dll, UpdatePerUserSystemParameters

# Encerra o processo do Windows Explorer para aplicar as alteracoes imediatamente
Stop-PowerToolExplorer

# Aguarda alguns segundos antes de reiniciar o Windows Explorer
Start-Sleep -Seconds 2
