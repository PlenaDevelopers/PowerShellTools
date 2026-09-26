<#
.SYNOPSIS
Comprehensive Windows health diagnostic.

.DESCRIPTION
Analyzes Windows version, uptime, reboot state, services, events, disk and resources without broad repair.

.EXAMPLE
.\tool_diagnostic_windows_health.ps1

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


Write-Section 'COMPREHENSIVE WINDOWS HEALTH DIAGNOSTIC.'
Write-Item 'Tool' 'tool_diagnostic_windows_health.ps1'
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

Write-Section 'WINDOWS VERSION AND UPTIME'
Invoke-Safe { $os = Get-CimInstance Win32_OperatingSystem; Write-Item 'Caption' $os.Caption; Write-Item 'Version' $os.Version; Write-Item 'Build' $os.BuildNumber; Write-Item 'Install date' $os.InstallDate; Write-Item 'Last boot' $os.LastBootUpTime; Write-Item 'Free physical memory' (Format-Bytes ($os.FreePhysicalMemory * 1KB)) } 'Operating system query'
Write-Section 'IMPORTANT SERVICES'
'wuauserv','bits','cryptsvc','trustedinstaller','Winmgmt','EventLog','Schedule' | ForEach-Object { Invoke-Safe { $s = Get-Service -Name $_ -ErrorAction Stop; Write-Item $s.Name $s.Status } "Service $_" }
Write-Section 'SYSTEM RESOURCES'
Invoke-Safe { Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object { Write-Item ("Volume {0}" -f $_.DeviceID) ((Format-Bytes $_.FreeSpace) + ' free of ' + (Format-Bytes $_.Size)) } } 'Disk query'
Invoke-Safe { $cs = Get-CimInstance Win32_ComputerSystem; Write-Item 'Total RAM' (Format-Bytes $cs.TotalPhysicalMemory) } 'RAM query'
Write-Section 'RECENT CRITICAL SYSTEM EVENTS'
Invoke-Safe { Get-WinEvent -FilterHashtable @{LogName='System'; Level=1; StartTime=(Get-Date).AddDays(-7)} -MaxEvents 10 | Select-Object TimeCreated,ProviderName,Id,LevelDisplayName | Format-Table -AutoSize | Out-String | Write-Host } 'Critical event query'
Write-Section 'RESULT'
Write-Status 'OK' 'Diagnostic completed. No broad repair was performed.'
