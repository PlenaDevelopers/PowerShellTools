<#
.SYNOPSIS
Detect Windows pending reboot indicators.

.DESCRIPTION
Explains reboot requirements from CBS, Windows Update, pending file rename and computer rename indicators.

.EXAMPLE
.\tool_diagnostic_pending_reboot.ps1

.NOTES
Category: Windows
Administrator required: No
Standalone: Yes
Mode: Read-only
#>
[CmdletBinding()]
param()


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


Write-Section 'DETECT WINDOWS PENDING REBOOT INDICATORS.'
Write-Item 'Tool' 'tool_diagnostic_pending_reboot.ps1'
Write-Item 'Category' 'Windows'
Write-Item 'Standalone' 'Yes'
Write-Item 'Administrator' 'No'

Write-Section 'PENDING REBOOT INDICATORS'
$checks = @(
    @{Name='CBS RebootPending'; Present=Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'; Reason='Component Based Servicing has pending operations.'},
    @{Name='Windows Update RebootRequired'; Present=Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'; Reason='Windows Update requires reboot.'},
    @{Name='Pending File Rename'; Present=($null -ne (Get-RegistryValueSafe 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' 'PendingFileRenameOperations')); Reason='Files are scheduled to be renamed or deleted at boot.'},
    @{Name='Computer Rename'; Present=((Get-RegistryValueSafe 'HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName' 'ComputerName') -ne (Get-RegistryValueSafe 'HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName' 'ComputerName')); Reason='Computer name change is pending.'}
)
$needed = $false
foreach ($c in $checks) { Write-Item $c.Name $c.Present ($(if ($c.Present) { 'Yellow' } else { 'Green' })); if ($c.Present) { $needed = $true; Write-Status 'Warning' $c.Reason } }
if ($needed) { Write-Status 'Reboot Required' 'Windows has one or more pending reboot indicators.' } else { Write-Status 'Healthy' 'No common pending reboot indicator was detected.' }
