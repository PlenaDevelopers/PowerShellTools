<#
    Copyright: (c) Flex IT - 2026
    Function: Fix Security Microsoft-Windows-Security-Auditing 4720
    Description: Standalone diagnostic and safe remediation tool for Security / Microsoft-Windows-Security-Auditing / Event ID 4720.
#>
[CmdletBinding()]
param(
    [ValidateRange(1,3650)]
    [int]$DaysBack = 30,

    [ValidateRange(1,500)]
    [int]$MaxEvents = 50,

    [switch]$Repair
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$EventLogName = 'Security'
$EventProviderName = 'Microsoft-Windows-Security-Auditing'
$EventId = 4720
$EventClassification = 'Security Investigation Required'
$EventSummary = 'User account created. Validate authorization.'

function Write-Section { param([string]$Title) Write-Host ''; Write-Host ('=' * 88) -ForegroundColor Cyan; Write-Host $Title -ForegroundColor Cyan; Write-Host ('=' * 88) -ForegroundColor Cyan }
function Write-Item { param([string]$Label,[object]$Value,[ConsoleColor]$Color = [ConsoleColor]::White) if ($null -eq $Value -or [string]::IsNullOrWhiteSpace([string]$Value)) { $Value = 'Not available' }; Write-Host ('{0,-28}: ' -f $Label) -NoNewline -ForegroundColor DarkGray; Write-Host ([string]$Value) -ForegroundColor $Color }
function Write-Status { param([string]$Status,[string]$Message) $color = switch ($Status) { 'OK' { 'Green' } 'WARN' { 'Yellow' } 'FAIL' { 'Red' } 'INFO' { 'Cyan' } default { 'White' } }; Write-Host ('[{0}] {1}' -f $Status,$Message) -ForegroundColor $color }

function ConvertTo-EventDataMap {
    param([Parameter(Mandatory)]$Event)
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

function Get-EventValue {
    param([System.Collections.IDictionary]$Data,[string[]]$Names)
    foreach ($name in $Names) {
        if ($Data.Contains($name) -and -not [string]::IsNullOrWhiteSpace([string]$Data[$name])) { return [string]$Data[$name] }
    }
    return $null
}

function Get-EventsByIdentity {
    param([string]$LogName,[string]$ProviderName,[int]$Id,[datetime]$StartTime,[int]$Limit = 50)
    $filter = @{ LogName = $LogName; Id = $Id; StartTime = $StartTime }
    if ($ProviderName -and $ProviderName -ne '*') { $filter.ProviderName = $ProviderName }
    try { @(Get-WinEvent -FilterHashtable $filter -MaxEvents $Limit -ErrorAction Stop) }
    catch [System.Diagnostics.Eventing.Reader.EventLogException] { @() }
    catch { @() }
}

function Get-FrequencySummary {
    param([object[]]$Events)
    $now = Get-Date
    [pscustomobject]@{
        Total = @($Events).Count
        Last24Hours = @($Events | Where-Object { $_.TimeCreated -ge $now.AddHours(-24) }).Count
        Last7Days = @($Events | Where-Object { $_.TimeCreated -ge $now.AddDays(-7) }).Count
        FirstOccurrence = @($Events | Sort-Object TimeCreated | Select-Object -First 1).TimeCreated
        LatestOccurrence = @($Events | Sort-Object TimeCreated -Descending | Select-Object -First 1).TimeCreated
    }
}

function Show-EventHeader {
    Write-Section ('Event Viewer Standalone Tool: {0} / {1} / {2}' -f $EventLogName,$EventProviderName,$EventId)
    Write-Item 'Log' $EventLogName
    Write-Item 'Provider' $EventProviderName
    Write-Item 'Event ID' $EventId
    Write-Item 'Classification' $EventClassification Yellow
    Write-Status 'INFO' $EventSummary
    Write-Status 'INFO' 'This script identifies events by Log + Provider + Event ID, not by Event ID alone.'
}

function Show-Frequency {
    param([object[]]$Events)
    $f = Get-FrequencySummary -Events $Events
    Write-Section 'Frequency'
    Write-Item 'Total in selected window' $f.Total
    Write-Item 'Last 24 hours' $f.Last24Hours
    Write-Item 'Last 7 days' $f.Last7Days
    Write-Item 'First occurrence' $f.FirstOccurrence
    Write-Item 'Latest occurrence' $f.LatestOccurrence
}

function Show-LatestEventCore {
    param($Event)
    Write-Section 'Latest Matching Event'
    Write-Item 'Time' $Event.TimeCreated
    Write-Item 'Record ID' $Event.RecordId
    Write-Item 'Machine' $Event.MachineName
    $data = ConvertTo-EventDataMap -Event $Event
    $shown = 0
    foreach ($key in $data.Keys) {
        if ($shown -ge 10) { break }
        Write-Item $key $data[$key]
        $shown++
    }
    return $data
}

function Get-RelatedEventCount {
    param([string]$LogName,[string]$ProviderName,[int]$Id,[int]$Hours = 24)
    @(Get-EventsByIdentity -LogName $LogName -ProviderName $ProviderName -Id $Id -StartTime (Get-Date).AddHours(-[Math]::Abs($Hours)) -Limit 100).Count
}

function Show-SecurityDiagnostics {
    param($LatestEvent,[System.Collections.IDictionary]$Data)
    Write-Section 'Security Evidence'
    foreach ($name in @('TargetUserName','TargetDomainName','SubjectUserName','IpAddress','WorkstationName','LogonType','Status','SubStatus','FailureReason','AuthenticationPackageName','ProcessName','MemberName','TargetSid')) { Write-Item $name (Get-EventValue -Data $Data -Names @($name)) }
    Write-Section 'Frequency by Recent Records'
    Write-Status 'INFO' 'Security events are investigation data. This script does not change passwords, unlock accounts, or clear logs.'
    if ($Repair) { Write-Status 'WARN' 'Repair mode was requested, but automatic remediation is not appropriate for this security event.' }
    Write-Status 'FAIL' 'Result: Security Investigation Required for suspicious or repeated activity.'
}

Show-EventHeader
$start = (Get-Date).AddDays(-[Math]::Abs($DaysBack))
$events = Get-EventsByIdentity -LogName $EventLogName -ProviderName $EventProviderName -Id $EventId -StartTime $start -Limit $MaxEvents
if (-not $events -or $events.Count -eq 0) {
    Write-Status 'OK' 'No matching events were found in the selected time window.'
    exit 0
}
Show-Frequency -Events $events
$latest = @($events | Sort-Object TimeCreated -Descending | Select-Object -First 1)[0]
$data = Show-LatestEventCore -Event $latest
Show-SecurityDiagnostics -LatestEvent $latest -Data $data
Write-Section 'Final Report'
Write-Item 'Result' $EventClassification Yellow
Write-Item 'Repair requested' ([bool]$Repair)
Write-Status 'INFO' 'Completed without using external PowerShellTools files, custom modules, repository metadata, or Internet access.'
