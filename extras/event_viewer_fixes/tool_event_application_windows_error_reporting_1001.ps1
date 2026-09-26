<#
    Copyright: (c) Flex IT - 2026
    Function: Diagnose Application Windows Error Reporting 1001
    Description: Diagnoses Application / Windows Error Reporting / Event ID 1001 using safe PowerTool Event Viewer handling.
#>
[CmdletBinding()]
param(
    [ValidateRange(1,3650)][int]$DaysBack = 30,
    [ValidateRange(1,500)][int]$MaxEvents = 50,
    [switch]$Repair
)

$enginePath = Join-Path -Path $PSScriptRoot -ChildPath 'PowerTool.EventViewer.ps1'
. $enginePath
Invoke-PowerToolEventDiagnostic -EventKey 'application_windows_error_reporting_1001' -DaysBack $DaysBack -MaxEvents $MaxEvents -Repair:$Repair
