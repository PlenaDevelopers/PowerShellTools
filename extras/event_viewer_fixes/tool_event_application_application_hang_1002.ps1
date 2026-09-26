<#
    Copyright: (c) Flex IT - 2026
    Function: Diagnose Application Application Hang 1002
    Description: Diagnoses Application / Application Hang / Event ID 1002 using safe PowerTool Event Viewer handling.
#>
[CmdletBinding()]
param(
    [ValidateRange(1,3650)][int]$DaysBack = 30,
    [ValidateRange(1,500)][int]$MaxEvents = 50,
    [switch]$Repair
)

$enginePath = Join-Path -Path $PSScriptRoot -ChildPath 'PowerTool.EventViewer.ps1'
. $enginePath
Invoke-PowerToolEventDiagnostic -EventKey 'application_application_hang_1002' -DaysBack $DaysBack -MaxEvents $MaxEvents -Repair:$Repair
