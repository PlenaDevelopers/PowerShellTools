<#
    Copyright: (c) Flex IT - 2026
    Function: Definir Compartilhamento Windows 10
    Description: Configura nome do computador, descoberta de rede e compartilhamento C:\transferencias no Windows 10.
#>

[CmdletBinding()]
param(
    [string]$NomeComputador,
    [string]$Dominio = "flexit.local.net",
    [string]$Folder = "C:\transferencias",
    [string]$Compartilhamento = "transferencias"
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

function Initialize-PowerToolConsole {
    try {
        $logDir = Join-Path -Path $PSScriptRoot -ChildPath 'logs'
        if (-not (Test-Path -LiteralPath $logDir)) { New-Item -Path $logDir -ItemType Directory -Force | Out-Null }
        $logPath = Join-Path -Path $logDir -ChildPath ("PowerTool_{0}_{1}_{2}.log" -f (Get-Date -Format 'yyyyMMdd_HHmmss'), [IO.Path]::GetFileNameWithoutExtension($PSCommandPath), $PID)
        Start-Transcript -Path $logPath -Force | Out-Null
        $global:PowerToolTranscriptActive = $true
    } catch { $global:PowerToolTranscriptActive = $false }
}
function Stop-PowerToolTranscript { try { if ($global:PowerToolTranscriptActive) { Stop-Transcript | Out-Null } } catch { } }
function Get-PowerToolWidth { try { return [Math]::Min([Math]::Max(($Host.UI.RawUI.WindowSize.Width - 4), 96), 160) } catch { return 120 } }
function Write-PowerToolBorder { param([string]$Left = '+', [string]$Right = '+', [string]$Color = 'Cyan') Write-Host ($Left + ('-' * (Get-PowerToolWidth)) + $Right) -ForegroundColor $Color }
function Write-PowerToolLine { param([string]$Campo, [string]$Valor, [string]$CorValor = 'White') $w = (Get-PowerToolWidth) - 33; if ($null -eq $Valor) { $Valor = '' }; $t = [string]$Valor; if ($t.Length -gt $w) { $t = $t.Substring(0, $w - 3) + '...' }; Write-Host ("|{0,-30} : {1}|" -f $Campo, $t.PadRight($w)) -ForegroundColor $CorValor }
function Write-PowerToolHeader { param([string]$Script, [string]$Titulo) Initialize-PowerToolConsole; Write-PowerToolBorder '+' '+' 'Yellow'; Write-PowerToolLine 'Operation' $Titulo 'Yellow'; Write-PowerToolLine 'Production' (Get-Date).Year 'Yellow'; Write-PowerToolLine 'Copyright' 'Flex IT' 'Yellow'; Write-PowerToolLine 'Script' $Script 'White'; Write-PowerToolBorder '+' '+' 'Cyan' }
function Write-PowerToolFooter { param([string]$Status = 'Finished') Write-PowerToolBorder '+' '+' 'Cyan'; Write-PowerToolLine 'Process' $Status 'Green'; Write-PowerToolBorder '+' '+' 'Yellow'; Stop-PowerToolTranscript }

function Assert-Admin {
    $principal = [Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent())
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { throw "Execute este script como Administrador." }
}
function Read-ValidHostName {
    do {
        $nome = if ($NomeComputador) { $NomeComputador } else { Read-Host "Nome do computador" }
        $nome = $nome.Trim().ToLower()
        if ($nome -match '^[a-z0-9]([a-z0-9-]{0,13}[a-z0-9])?$') { return $nome }
        Write-PowerToolLine "Nome invalido" "Use letras, numeros e hifen, ate 15 caracteres." "Red"
        $script:NomeComputador = $null
    } while ($true)
}
function Grant-ShareAccessCompat { param([string]$Name, [string]$AccountName) foreach ($account in @($AccountName, "Everyone", "Everyone")) { if ([string]::IsNullOrWhiteSpace($account)) { continue }; try { Grant-SmbShareAccess -Name $Name -AccountName $account -AccessRight Full -Force -ErrorAction Stop | Out-Null; return } catch { } }; Write-PowerToolLine "Permission SMB" "Failure ao conceder Everyone/Everyone automaticamente." "Yellow" }

try {
    Assert-Admin
    Write-PowerToolHeader -Script ([IO.Path]::GetFileName($PSCommandPath)) -Titulo "Definir Compartilhamento Windows 10"
    $hostCurto = Read-ValidHostName
    $Dominio = $Dominio.Trim().Trim(".").ToLower()
    if ($Dominio -notmatch '^([a-z0-9]([a-z0-9-]*[a-z0-9])?\.)+[a-z0-9]([a-z0-9-]*[a-z0-9])?$') { throw "Dominio invalido: $Dominio" }
    $fqdn = "$hostCurto.$Dominio"
    Write-PowerToolLine "Computador" $hostCurto "Yellow"
    Write-PowerToolLine "FQDN" $fqdn "Yellow"
    Write-PowerToolLine "Folder" $Folder "Yellow"

    if ($env:COMPUTERNAME.ToLower() -ne $hostCurto) { Rename-Computer -NewName $hostCurto -Force; Write-PowerToolLine "Nome" "Alteracao concluida apos reiniciar" "Yellow" }
    New-Item -ItemType Directory -Path $Folder -Force | Out-Null
    $sidEveryone = New-Object Security.Principal.SecurityIdentifier "S-1-1-0"
    $contaEveryone = $sidEveryone.Translate([Security.Principal.NTAccount]).Value
    $acl = Get-Acl $Folder
    $rule = New-Object Security.AccessControl.FileSystemAccessRule($contaEveryone, "Modify", "ContainerInherit,ObjectInherit", "None", "Allow")
    $acl.SetAccessRule($rule)
    Set-Acl -Path $Folder -AclObject $acl
    Write-PowerToolLine "Permissions NTFS" $contaEveryone "Green"

    Set-Service -Name LanmanServer -StartupType Automatic
    Start-Service -Name LanmanServer
    foreach ($svc in @("FDResPub", "fdPHost", "SSDPSRV", "upnphost")) { try { Set-Service -Name $svc -StartupType Automatic; Start-Service -Name $svc } catch { Write-PowerToolLine "Servico $svc" $_.Exception.Message "Yellow" } }
    Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private
    Enable-NetFirewallRule -DisplayGroup "File and Printer Sharing" -ErrorAction SilentlyContinue
    Enable-NetFirewallRule -DisplayGroup "Network Discovery" -ErrorAction SilentlyContinue

    $share = Get-SmbShare -Name $Compartilhamento -ErrorAction SilentlyContinue
    if ($share -and $share.Path -ne $Folder) { Remove-SmbShare -Name $Compartilhamento -Force; $share = $null }
    if ($share) { Set-SmbShare -Name $Compartilhamento -Description "Transferencias - $hostCurto" -Force } else { New-SmbShare -Name $Compartilhamento -Path $Folder -Description "Transferencias - $hostCurto" -FullAccess $contaEveryone | Out-Null }
    Grant-ShareAccessCompat -Name $Compartilhamento -AccountName $contaEveryone
    $ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike "169.254.*" -and $_.IPAddress -ne "127.0.0.1" } | Select-Object -First 1 -ExpandProperty IPAddress)
    Write-PowerToolLine "Access por IP" "\\$ip\$Compartilhamento" "Green"
    Write-PowerToolLine "Access por nome" "\\$hostCurto\$Compartilhamento" "Green"
    Write-PowerToolLine "Aviso" "Reinicie o Windows para concluir nome e descoberta." "Yellow"
    Write-PowerToolFooter
} catch {
    Write-PowerToolLine "Erro" $_.Exception.Message "Red"
    Write-PowerToolFooter -Status "Falhou"
    exit 1
}
