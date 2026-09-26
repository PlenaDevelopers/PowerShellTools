<#
    Copyright: (c) Flex IT - 2026
    Function: Diagnose System Disk 15
    Description: Diagnoses System / Disk / Event ID 15 using safe PowerTool Event Viewer handling.
#>
[CmdletBinding()]
param(
    [ValidateRange(1,3650)][int]$DaysBack = 30,
    [ValidateRange(1,500)][int]$MaxEvents = 50,
    [switch]$Repair
)

$enginePath = Join-Path -Path $PSScriptRoot -ChildPath 'PowerTool.EventViewer.ps1'
. $enginePath
Invoke-PowerToolEventDiagnostic -EventKey 'system_disk_15' -DaysBack $DaysBack -MaxEvents $MaxEvents -Repair:$Repair
