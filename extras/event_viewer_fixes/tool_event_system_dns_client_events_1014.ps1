<#
    Copyright: (c) Flex IT - 2026
    Function: Diagnose System DNS Client Events 1014
    Description: Diagnoses System / Microsoft-Windows-DNS-Client / Event ID 1014 using safe PowerTool Event Viewer handling.
#>
[CmdletBinding()]
param(
    [ValidateRange(1,3650)][int]$DaysBack = 30,
    [ValidateRange(1,500)][int]$MaxEvents = 50,
    [switch]$Repair
)

$enginePath = Join-Path -Path $PSScriptRoot -ChildPath 'PowerTool.EventViewer.ps1'
. $enginePath
Invoke-PowerToolEventDiagnostic -EventKey 'system_dns_client_events_1014' -DaysBack $DaysBack -MaxEvents $MaxEvents -Repair:$Repair
