<#
.SYNOPSIS
Collect support diagnostics package.

.DESCRIPTION
Creates a technician-safe diagnostic package without passwords, tokens, browser secrets or personal documents.

.PARAMETER OutputDirectory
Parameter used by this standalone tool.

.EXAMPLE
.\tool_collect_support_diagnostics.ps1

.NOTES
Category: Support
Administrator required: No
Standalone: Yes
Mode: Read-only
#>
[CmdletBinding()]
param(
    [string]$OutputDirectory = $null
)


Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'

function Write-Section {
    param([string]$Title)
    Write-Host ''
    Write-Host ('=' * 72) -ForegroundColor Cyan
    Write-Host $Title -ForegroundColor Cyan
    Write-Host ('=' * 72) -ForegroundColor Cyan
}

function Write-Item {
    param([string]$Label, [object]$Value, [ConsoleColor]$Color = [ConsoleColor]::White)
    if ($null -eq $Value -or [string]::IsNullOrWhiteSpace([string]$Value)) { $Value = 'Unavailable' }
    Write-Host ('{0,-30}: ' -f $Label) -NoNewline -ForegroundColor DarkGray
    Write-Host ([string]$Value) -ForegroundColor $Color
}

function Write-Status {
    param([string]$Status, [string]$Message)
    $color = switch ($Status) {
        'Healthy' { 'Green' }
        'OK' { 'Green' }
        'Warning' { 'Yellow' }
        'Problem Detected' { 'Red' }
        'Repair Completed' { 'Green' }
        'Repair Failed' { 'Red' }
        'Manual Intervention Required' { 'Yellow' }
        'Reboot Required' { 'Yellow' }
        'Hardware Investigation Required' { 'Red' }
        'Not Applicable' { 'DarkGray' }
        default { 'White' }
    }
    Write-Host ('[{0}] {1}' -f $Status, $Message) -ForegroundColor $color
}

function Test-Administrator {
    try {
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = [Security.Principal.WindowsPrincipal]::new($identity)
        return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    } catch { return $false }
}

function Invoke-Safe {
    param([scriptblock]$ScriptBlock, [string]$Label = 'Operation')
    try { & $ScriptBlock }
    catch { Write-Status 'Warning' ("{0}: {1}" -f $Label, $_.Exception.Message) }
}

function Get-RegistryValueSafe {
    param([string]$Path, [string]$Name)
    try { (Get-ItemProperty -LiteralPath $Path -Name $Name -ErrorAction Stop).$Name } catch { $null }
}

function Get-EventsSafe {
    param([string]$LogName, [string]$ProviderName, [int]$Id, [int]$Hours = 168, [int]$MaxEvents = 50)
    $filter = @{ LogName = $LogName; Id = $Id; StartTime = (Get-Date).AddHours(-[Math]::Abs($Hours)) }
    if ($ProviderName) { $filter.ProviderName = $ProviderName }
    try { @(Get-WinEvent -FilterHashtable $filter -MaxEvents $MaxEvents -ErrorAction Stop) } catch { @() }
}

function Format-Bytes {
    param([Nullable[double]]$Bytes)
    if ($null -eq $Bytes) { return 'Unavailable' }
    if ($Bytes -ge 1TB) { return ('{0:N2} TB' -f ($Bytes / 1TB)) }
    if ($Bytes -ge 1GB) { return ('{0:N2} GB' -f ($Bytes / 1GB)) }
    if ($Bytes -ge 1MB) { return ('{0:N2} MB' -f ($Bytes / 1MB)) }
    if ($Bytes -ge 1KB) { return ('{0:N2} KB' -f ($Bytes / 1KB)) }
    return ('{0:N0} B' -f $Bytes)
}

function ConvertTo-EventDataMap {
    param($Event)
    $map = [ordered]@{}
    try {
        [xml]$xml = $Event.ToXml()
        $index = 0
        foreach ($data in $xml.Event.EventData.Data) {
            $name = if ($data.Name) { [string]$data.Name } else { 'Data{0}' -f $index }
            if (-not $map.Contains($name)) { $map[$name] = [string]$data.'#text' }
            $index++
        }
    } catch { }
    return $map
}


Write-Section 'COLLECT SUPPORT DIAGNOSTICS PACKAGE.'
Write-Item 'Tool' 'tool_collect_support_diagnostics.ps1'
Write-Item 'Category' 'Support'
Write-Item 'Standalone' 'Yes'
Write-Item 'Administrator' 'No'

$root = if($OutputDirectory){$OutputDirectory}else{Join-Path $env:TEMP ('PowerShellTools-Diagnostic-{0}-{1:yyyyMMdd-HHmmss}' -f $env:COMPUTERNAME,(Get-Date))}; New-Item -ItemType Directory -Path $root -Force|Out-Null; foreach($d in 'System','Hardware','Storage','Network','Drivers','Services','Updates','EventViewer','BSOD','Summary'){New-Item -ItemType Directory -Path (Join-Path $root $d) -Force|Out-Null}; Get-CimInstance Win32_OperatingSystem | Out-File (Join-Path $root 'System\os.txt'); Get-CimInstance Win32_ComputerSystem | Out-File (Join-Path $root 'Hardware\computer.txt'); Get-CimInstance Win32_Processor | Out-File (Join-Path $root 'Hardware\cpu.txt'); Get-CimInstance Win32_LogicalDisk | Out-File (Join-Path $root 'Storage\logical-disks.txt'); Get-NetIPConfiguration | Out-File (Join-Path $root 'Network\ipconfig.txt'); Get-CimInstance Win32_PnPSignedDriver | Select-Object DeviceName,DriverProviderName,DriverVersion,DriverDate,InfName | Out-File (Join-Path $root 'Drivers\drivers.txt'); Get-Service | Out-File (Join-Path $root 'Services\services.txt'); Get-HotFix | Out-File (Join-Path $root 'Updates\hotfixes.txt'); Get-WinEvent -FilterHashtable @{LogName='System';Level=1,2;StartTime=(Get-Date).AddDays(-7)} -MaxEvents 200 -ErrorAction SilentlyContinue | Select-Object TimeCreated,ProviderName,Id,LevelDisplayName,Message | Out-File (Join-Path $root 'EventViewer\system-errors.txt'); 'Package may contain usernames, computer names, IP addresses, domain names, installed software, hardware serials and event messages. It intentionally excludes passwords, private keys, browser tokens and personal document contents.' | Out-File (Join-Path $root 'Summary\sensitivity.txt'); $zip = $root + '.zip'; if(Test-Path $zip){Remove-Item $zip -Force}; Compress-Archive -Path (Join-Path $root '*') -DestinationPath $zip; Write-Item 'Package' $zip; Write-Status 'OK' 'Support package created.'
