<#
.SYNOPSIS
Analyze disk-space consumption.

.DESCRIPTION
Shows volume usage and largest top-level directories without deleting files.

.PARAMETER Path
Parameter used by this standalone tool.

.PARAMETER Top
Parameter used by this standalone tool.

.EXAMPLE
.\tool_analyze_disk_space.ps1

.NOTES
Category: Storage
Administrator required: No
Standalone: Yes
Mode: Read-only
#>
[CmdletBinding()]
param(
    [string]$Path = $null,
    [int]$Top = 20
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


Write-Section 'ANALYZE DISK-SPACE CONSUMPTION.'
Write-Item 'Tool' 'tool_analyze_disk_space.ps1'
Write-Item 'Category' 'Storage'
Write-Item 'Standalone' 'Yes'
Write-Item 'Administrator' 'No'

Write-Section 'VOLUME USAGE'
Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object { Write-Item $_.DeviceID ((Format-Bytes $_.FreeSpace) + ' free of ' + (Format-Bytes $_.Size)) }
Write-Section 'LARGEST DIRECTORIES'
$target = if ($Path) { $Path } else { $env:SystemDrive + '\' }
Write-Item 'Analyzed path' $target
Invoke-Safe { Get-ChildItem -LiteralPath $target -Directory -Force -ErrorAction Stop | ForEach-Object { $size=(Get-ChildItem -LiteralPath $_.FullName -Recurse -File -Force -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum; [pscustomobject]@{Path=$_.FullName;Size=$size;SizeText=Format-Bytes $size} } | Sort-Object Size -Descending | Select-Object -First $Top Path,SizeText | Format-Table -AutoSize | Out-String | Write-Host } 'Directory size scan'
Write-Status 'OK' 'No files were deleted.'
