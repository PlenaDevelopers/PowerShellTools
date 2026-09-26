<#
.SYNOPSIS
Correlate unexpected shutdown evidence.

.DESCRIPTION
Correlates Kernel-Power, EventLog, BugCheck, User32, Kernel-General and WHEA evidence.

.PARAMETER DaysBack
Parameter used by this standalone tool.

.EXAMPLE
.\tool_diagnostic_unexpected_shutdown.ps1

.NOTES
Category: Windows
Administrator required: No
Standalone: Yes
Mode: Read-only
#>
[CmdletBinding()]
param(
    [int]$DaysBack = 30
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


Write-Section 'CORRELATE UNEXPECTED SHUTDOWN EVIDENCE.'
Write-Item 'Tool' 'tool_diagnostic_unexpected_shutdown.ps1'
Write-Item 'Category' 'Windows'
Write-Item 'Standalone' 'Yes'
Write-Item 'Administrator' 'No'

Write-Section 'SHUTDOWN CORRELATION'
$ids = @(
    @{Name='Kernel-Power 41';Log='System';Provider='Microsoft-Windows-Kernel-Power';Id=41},
    @{Name='EventLog 6008';Log='System';Provider='EventLog';Id=6008},
    @{Name='BugCheck 1001';Log='System';Provider='Microsoft-Windows-WER-SystemErrorReporting';Id=1001},
    @{Name='User32 1074';Log='System';Provider='User32';Id=1074},
    @{Name='Kernel-General 12';Log='System';Provider='Microsoft-Windows-Kernel-General';Id=12},
    @{Name='Kernel-General 13';Log='System';Provider='Microsoft-Windows-Kernel-General';Id=13}
)
foreach ($i in $ids) { $c=(Get-EventsSafe -LogName $i.Log -ProviderName $i.Provider -Id $i.Id -Hours ($DaysBack*24)).Count; Write-Item $i.Name $c }
$bug=(Get-EventsSafe -LogName System -ProviderName 'Microsoft-Windows-WER-SystemErrorReporting' -Id 1001 -Hours ($DaysBack*24)).Count
$requested=(Get-EventsSafe -LogName System -ProviderName User32 -Id 1074 -Hours ($DaysBack*24)).Count
if ($bug -gt 0) { Write-Status 'Problem Detected' 'BSOD/BugCheck evidence exists near the selected period.' }
elseif ($requested -gt 0) { Write-Status 'OK' 'Requested shutdown/restart events exist. Review timestamps against Kernel-Power events.' }
else { Write-Status 'Unable to Determine' 'Unexpected shutdown evidence exists without enough proof to assign a root cause.' }
