<#
    Copyright: (c) Flex IT - 2026
    Function: Diagnose Security Microsoft Windows Security Auditing 4648
    Description: Diagnoses Security / Microsoft-Windows-Security-Auditing / Event ID 4648 using safe PowerTool Event Viewer handling.
#>
[CmdletBinding()]
param(
    [ValidateRange(1,3650)][int]$DaysBack = 30,
    [ValidateRange(1,500)][int]$MaxEvents = 50,
    [switch]$Repair
)

$enginePath = Join-Path -Path $PSScriptRoot -ChildPath 'PowerTool.EventViewer.ps1'
. $enginePath
Invoke-PowerToolEventDiagnostic -EventKey 'security_microsoft_windows_security_auditing_4648' -DaysBack $DaysBack -MaxEvents $MaxEvents -Repair:$Repair
