<#
    Copyright: (c) Flex IT - 2026
    Function: Diagnose System Service Control Manager 7031
    Description: Diagnoses System / Service Control Manager / Event ID 7031 using safe PowerTool Event Viewer handling.
#>
[CmdletBinding()]
param(
    [ValidateRange(1,3650)][int]$DaysBack = 30,
    [ValidateRange(1,500)][int]$MaxEvents = 50,
    [switch]$Repair
)

$enginePath = Join-Path -Path $PSScriptRoot -ChildPath 'PowerTool.EventViewer.ps1'
. $enginePath
Invoke-PowerToolEventDiagnostic -EventKey 'system_service_control_manager_7031' -DaysBack $DaysBack -MaxEvents $MaxEvents -Repair:$Repair
