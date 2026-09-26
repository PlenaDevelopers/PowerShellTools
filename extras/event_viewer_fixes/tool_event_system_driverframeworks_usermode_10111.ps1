<#
    Copyright: (c) Flex IT - 2026
    Function: Diagnose System Driverframeworks Usermode 10111
    Description: Diagnoses System / Microsoft-Windows-DriverFrameworks-UserMode / Event ID 10111 using safe PowerTool Event Viewer handling.
#>
[CmdletBinding()]
param(
    [ValidateRange(1,3650)][int]$DaysBack = 30,
    [ValidateRange(1,500)][int]$MaxEvents = 50,
    [switch]$Repair
)

$enginePath = Join-Path -Path $PSScriptRoot -ChildPath 'PowerTool.EventViewer.ps1'
. $enginePath
Invoke-PowerToolEventDiagnostic -EventKey 'system_driverframeworks_usermode_10111' -DaysBack $DaysBack -MaxEvents $MaxEvents -Repair:$Repair
