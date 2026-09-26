<#
    Copyright: (c) Flex IT - 2026
    Function: Diagnose Application Msiinstaller 11707
    Description: Diagnoses Application / MsiInstaller / Event ID 11707 using safe PowerTool Event Viewer handling.
#>
[CmdletBinding()]
param(
    [ValidateRange(1,3650)][int]$DaysBack = 30,
    [ValidateRange(1,500)][int]$MaxEvents = 50,
    [switch]$Repair
)

$enginePath = Join-Path -Path $PSScriptRoot -ChildPath 'PowerTool.EventViewer.ps1'
. $enginePath
Invoke-PowerToolEventDiagnostic -EventKey 'application_msiinstaller_11707' -DaysBack $DaysBack -MaxEvents $MaxEvents -Repair:$Repair
