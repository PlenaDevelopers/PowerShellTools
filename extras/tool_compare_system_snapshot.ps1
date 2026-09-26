<#
.SYNOPSIS
Create and compare system snapshots.

.DESCRIPTION
Creates or compares standalone JSON snapshots of software, drivers, services, updates, network and startup state.

.PARAMETER CreateSnapshot
Parameter used by this standalone tool.

.PARAMETER Compare
Parameter used by this standalone tool.

.PARAMETER SnapshotPath
Parameter used by this standalone tool.

.EXAMPLE
.\tool_compare_system_snapshot.ps1

.NOTES
Category: Support
Administrator required: No
Standalone: Yes
Mode: Read-only
#>
[CmdletBinding()]
param(
    [switch]$CreateSnapshot,
    [switch]$Compare,
    [string]$SnapshotPath = (Join-Path $PWD 'PowerShellTools-SystemSnapshot.json')
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


Write-Section 'CREATE AND COMPARE SYSTEM SNAPSHOTS.'
Write-Item 'Tool' 'tool_compare_system_snapshot.ps1'
Write-Item 'Category' 'Support'
Write-Item 'Standalone' 'Yes'
Write-Item 'Administrator' 'No'

if($CreateSnapshot){$snap=[ordered]@{Created=(Get-Date);Computer=$env:COMPUTERNAME;Software=Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* -ErrorAction SilentlyContinue|Select-Object DisplayName,DisplayVersion,Publisher,InstallDate;Drivers=Get-CimInstance Win32_PnPSignedDriver|Select-Object DeviceName,DriverVersion,DriverDate,InfName;Services=Get-Service|Select-Object Name,Status,StartType;Updates=Get-HotFix|Select-Object HotFixID,InstalledOn;Network=Get-NetIPConfiguration|Select-Object InterfaceAlias,IPv4Address,IPv4DefaultGateway,DNSServer;Startup=Get-CimInstance Win32_StartupCommand|Select-Object Name,Command,Location}; $snap|ConvertTo-Json -Depth 5|Out-File $SnapshotPath -Encoding UTF8; Write-Item 'Snapshot' $SnapshotPath} elseif($Compare){ if(-not(Test-Path $SnapshotPath)){Write-Status 'Problem Detected' 'SnapshotPath not found.';exit 1}; $old=Get-Content $SnapshotPath -Raw|ConvertFrom-Json; Write-Item 'Snapshot created' $old.Created; Write-Status 'Warning' 'Comparison summary is based on object counts and key lists; review JSON for exact details.'; Write-Item 'Old services' @($old.Services).Count; Write-Item 'Current services' @(Get-Service).Count; Write-Item 'Old drivers' @($old.Drivers).Count; Write-Item 'Current drivers' @(Get-CimInstance Win32_PnPSignedDriver).Count } else { Write-Status 'Manual Intervention Required' 'Use -CreateSnapshot or -Compare.' }
