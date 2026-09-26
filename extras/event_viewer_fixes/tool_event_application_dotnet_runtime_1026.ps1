<#
    Copyright: (c) Flex IT - 2026
    Function: Diagnose Application Dotnet Runtime 1026
    Description: Diagnoses Application / .NET Runtime / Event ID 1026 using safe PowerTool Event Viewer handling.
#>
[CmdletBinding()]
param(
    [ValidateRange(1,3650)][int]$DaysBack = 30,
    [ValidateRange(1,500)][int]$MaxEvents = 50,
    [switch]$Repair
)

$enginePath = Join-Path -Path $PSScriptRoot -ChildPath 'PowerTool.EventViewer.ps1'
. $enginePath
Invoke-PowerToolEventDiagnostic -EventKey 'application_dotnet_runtime_1026' -DaysBack $DaysBack -MaxEvents $MaxEvents -Repair:$Repair
