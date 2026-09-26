<#
.SYNOPSIS
Diagnose and repair Windows Update.

.DESCRIPTION
Checks update services, pending reboot, update history, failed events and safely resets transient cache only when justified.

.EXAMPLE
.\tool_repair_windows_update.ps1

.NOTES
Category: Repair
Administrator required: Yes
Standalone: Yes
Mode: Repair
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


Write-Section 'DIAGNOSE AND REPAIR WINDOWS UPDATE.'
Write-Item 'Tool' 'tool_repair_windows_update.ps1'
Write-Item 'Category' 'Repair'
Write-Item 'Standalone' 'Yes'
Write-Item 'Administrator' 'Yes'

if (-not (Test-Administrator)) { Write-Status 'Manual Intervention Required' 'Run as Administrator to repair Windows Update components.'; exit 1 }
Write-Section 'WINDOWS UPDATE DIAGNOSIS'
$services = 'wuauserv','bits','cryptsvc','msiserver'
foreach ($name in $services) { Invoke-Safe { $s=Get-Service $name -ErrorAction Stop; Write-Item $name $s.Status } "Service $name" }
Write-Item 'Pending reboot' ((Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'))
Invoke-Safe { Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 10 | Format-Table -AutoSize | Out-String | Write-Host } 'Update history'
$failures = Get-EventsSafe -LogName System -ProviderName 'Microsoft-Windows-WindowsUpdateClient' -Id 20 -Hours 168 -MaxEvents 20
Write-Item 'Recent failed update events' $failures.Count
Write-Section 'REPAIR'
foreach ($name in $services) { Invoke-Safe { Set-Service -Name $name -StartupType Manual; Start-Service -Name $name -ErrorAction Stop; Write-Status 'OK' "Service ready: $name" } "Start service $name" }
if ($failures.Count -gt 0) {
    Write-Status 'Warning' 'Recent Windows Update failures detected. Resetting transient downloader state without deleting installed updates.'
    Invoke-Safe { Stop-Service wuauserv,bits -Force -ErrorAction SilentlyContinue; Remove-Item "$env:SystemRoot\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue; Start-Service bits,wuauserv } 'Clean Windows Update download cache'
} else { Write-Status 'OK' 'No recent Windows Update failure evidence found; cache reset was skipped.' }
Write-Status 'OK' 'Windows Update repair completed. Reboot may be required if Windows already had pending servicing.'
