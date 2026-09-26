<#
    Copyright: (c) Flex IT - 2026
    Function: Diagnose System Kernel Power 41
    Description: Diagnoses System / Microsoft-Windows-Kernel-Power / Event ID 41 using safe PowerTool Event Viewer handling.
#>
[CmdletBinding()]
param(
    [ValidateRange(1,3650)][int]$DaysBack = 30,
    [ValidateRange(1,500)][int]$MaxEvents = 50,
    [switch]$Repair
)

$enginePath = Join-Path -Path $PSScriptRoot -ChildPath 'PowerTool.EventViewer.ps1'
. $enginePath
Invoke-PowerToolEventDiagnostic -EventKey 'system_kernel_power_41' -DaysBack $DaysBack -MaxEvents $MaxEvents -Repair:$Repair
