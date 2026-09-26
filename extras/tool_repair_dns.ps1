<#
.SYNOPSIS
Safe DNS remediation.

.DESCRIPTION
Backs up DNS configuration, flushes cache, registers DNS and restarts DNS Client without changing DNS servers.

.PARAMETER Names
Parameter used by this standalone tool.

.EXAMPLE
.\tool_repair_dns.ps1

.NOTES
Category: Network
Administrator required: Yes
Standalone: Yes
Mode: Repair
#>
[CmdletBinding()]
param(
    [string[]]$Names = @('microsoft.com')
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


Write-Section 'SAFE DNS REMEDIATION.'
Write-Item 'Tool' 'tool_repair_dns.ps1'
Write-Item 'Category' 'Network'
Write-Item 'Standalone' 'Yes'
Write-Item 'Administrator' 'Yes'

Write-Section 'DNS CONFIGURATION'
Invoke-Safe { Get-DnsClientServerAddress | Select-Object InterfaceAlias,AddressFamily,ServerAddresses | Format-Table -AutoSize | Out-String | Write-Host } 'DNS servers'
Invoke-Safe { Get-Service Dnscache | Select-Object Name,Status,StartType | Format-Table -AutoSize | Out-String | Write-Host } 'DNS Client service'
Write-Section 'RESOLUTION TEST'
foreach ($name in $Names) { Invoke-Safe { Resolve-DnsName $name -ErrorAction Stop | Select-Object -First 5 | Format-Table -AutoSize | Out-String | Write-Host } "Resolve $name" }
Write-Item 'DNS Client 1014 events' ((Get-EventsSafe -LogName System -ProviderName 'Microsoft-Windows-DNS-Client' -Id 1014 -Hours 168).Count)

Write-Section 'SAFE DNS REPAIR'
if (-not (Test-Administrator)) { Write-Status 'Manual Intervention Required' 'Run as Administrator to flush/register DNS and restart DNS Client.'; exit 1 }
$backup = Join-Path $env:TEMP ('PowerShellTools-DNS-Backup-{0:yyyyMMdd-HHmmss}.txt' -f (Get-Date))
Invoke-Safe { Get-DnsClientServerAddress | Out-File -FilePath $backup -Encoding UTF8; Write-Item 'Backup' $backup } 'DNS backup'
Invoke-Safe { Clear-DnsClientCache; Write-Status 'Repair Completed' 'DNS client cache flushed.' } 'Clear DNS cache'
Invoke-Safe { ipconfig /registerdns | Out-Host } 'Register DNS'
Invoke-Safe { Restart-Service Dnscache -Force; Write-Status 'Repair Completed' 'DNS Client restarted.' } 'Restart DNS Client'
Write-Status 'OK' 'No public DNS servers were configured. Existing DNS server assignments were preserved.'
