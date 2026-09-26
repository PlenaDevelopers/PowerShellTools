# PowerTool Event Viewer diagnostic engine.
Set-StrictMode -Version Latest

$script:PowerToolEventTranscriptStarted = $false

$script:PowerToolEventCatalog = @(
    [pscustomobject]@{ Key = 'application_dotnet_runtime_1026'; LogName = 'Application'; ProviderName = '.NET Runtime'; EventId = 1026; Category = 'Application'; Classification = 'Diagnostic'; AutoRepair = 'No'; Summary = '.NET Runtime unhandled exception. Extracts application and exception evidence.'; RepairAction = 'None'; PreviousState = 'Missing'; Guidance = @() }
    [pscustomobject]@{ Key = 'application_application_error_1000'; LogName = 'Application'; ProviderName = 'Application Error'; EventId = 1000; Category = 'Application'; Classification = 'Diagnostic'; AutoRepair = 'No'; Summary = 'Application crash. Extracts application, module, exception, and process evidence.'; RepairAction = 'None'; PreviousState = 'Missing'; Guidance = @() }
    [pscustomobject]@{ Key = 'application_application_hang_1002'; LogName = 'Application'; ProviderName = 'Application Hang'; EventId = 1002; Category = 'Application'; Classification = 'Diagnostic'; AutoRepair = 'No'; Summary = 'Application hang. Extracts affected application and hang evidence.'; RepairAction = 'None'; PreviousState = 'Missing'; Guidance = @() }
    [pscustomobject]@{ Key = 'application_msiinstaller_11707'; LogName = 'Application'; ProviderName = 'MsiInstaller'; EventId = 11707; Category = 'Application'; Classification = 'Diagnostic'; AutoRepair = 'No'; Summary = 'MSI installer event 11707. Distinguishes successful installation from failed installation evidence.'; RepairAction = 'None'; PreviousState = 'Missing'; Guidance = @() }
    [pscustomobject]@{ Key = 'application_msiinstaller_11708'; LogName = 'Application'; ProviderName = 'MsiInstaller'; EventId = 11708; Category = 'Application'; Classification = 'Diagnostic'; AutoRepair = 'No'; Summary = 'MSI installer event 11708. Distinguishes successful installation from failed installation evidence.'; RepairAction = 'None'; PreviousState = 'Missing'; Guidance = @() }
    [pscustomobject]@{ Key = 'application_windows_error_reporting_1001'; LogName = 'Application'; ProviderName = 'Windows Error Reporting'; EventId = 1001; Category = 'Application'; Classification = 'Diagnostic'; AutoRepair = 'No'; Summary = 'Windows Error Reporting application report. Correlates with Application Error 1000 and .NET Runtime 1026.'; RepairAction = 'None'; PreviousState = 'Missing'; Guidance = @() }
    [pscustomobject]@{ Key = 'security_microsoft_windows_security_auditing_1102'; LogName = 'Security'; ProviderName = 'Microsoft-Windows-Security-Auditing'; EventId = 1102; Category = 'Security'; Classification = 'Security Investigation Required'; AutoRepair = 'No'; Summary = 'Audit log cleared. Security investigation event, not a repair task.'; RepairAction = 'None'; PreviousState = 'Missing'; Guidance = @() }
    [pscustomobject]@{ Key = 'security_microsoft_windows_security_auditing_4624'; LogName = 'Security'; ProviderName = 'Microsoft-Windows-Security-Auditing'; EventId = 4624; Category = 'Security'; Classification = 'Informational'; AutoRepair = 'No'; Summary = 'Successful logon. Normally no repair.'; RepairAction = 'None'; PreviousState = 'Missing'; Guidance = @() }
    [pscustomobject]@{ Key = 'security_microsoft_windows_security_auditing_4625'; LogName = 'Security'; ProviderName = 'Microsoft-Windows-Security-Auditing'; EventId = 4625; Category = 'Security'; Classification = 'Security Investigation Required'; AutoRepair = 'No'; Summary = 'Failed logon. Investigate account, source, logon type, and failure reason before remediation.'; RepairAction = 'None'; PreviousState = 'Missing'; Guidance = @() }
    [pscustomobject]@{ Key = 'security_microsoft_windows_security_auditing_4634'; LogName = 'Security'; ProviderName = 'Microsoft-Windows-Security-Auditing'; EventId = 4634; Category = 'Security'; Classification = 'Informational'; AutoRepair = 'No'; Summary = 'Account logged off. Normally no repair.'; RepairAction = 'None'; PreviousState = 'Missing'; Guidance = @() }
    [pscustomobject]@{ Key = 'security_microsoft_windows_security_auditing_4647'; LogName = 'Security'; ProviderName = 'Microsoft-Windows-Security-Auditing'; EventId = 4647; Category = 'Security'; Classification = 'Informational'; AutoRepair = 'No'; Summary = 'User initiated logoff. Normally no repair.'; RepairAction = 'None'; PreviousState = 'Missing'; Guidance = @() }
    [pscustomobject]@{ Key = 'security_microsoft_windows_security_auditing_4648'; LogName = 'Security'; ProviderName = 'Microsoft-Windows-Security-Auditing'; EventId = 4648; Category = 'Security'; Classification = 'Security Investigation Required'; AutoRepair = 'No'; Summary = 'Explicit credential logon. Review account and target server context.'; RepairAction = 'None'; PreviousState = 'Missing'; Guidance = @() }
    [pscustomobject]@{ Key = 'security_microsoft_windows_security_auditing_4672'; LogName = 'Security'; ProviderName = 'Microsoft-Windows-Security-Auditing'; EventId = 4672; Category = 'Security'; Classification = 'Security Investigation Required'; AutoRepair = 'No'; Summary = 'Special privileges assigned at logon. Review privileged account activity.'; RepairAction = 'None'; PreviousState = 'Missing'; Guidance = @() }
    [pscustomobject]@{ Key = 'security_microsoft_windows_security_auditing_4688'; LogName = 'Security'; ProviderName = 'Microsoft-Windows-Security-Auditing'; EventId = 4688; Category = 'Security'; Classification = 'Security Investigation Required'; AutoRepair = 'No'; Summary = 'Process creation auditing event. Useful for investigation when enabled.'; RepairAction = 'None'; PreviousState = 'Missing'; Guidance = @() }
    [pscustomobject]@{ Key = 'security_microsoft_windows_security_auditing_4720'; LogName = 'Security'; ProviderName = 'Microsoft-Windows-Security-Auditing'; EventId = 4720; Category = 'Security'; Classification = 'Security Investigation Required'; AutoRepair = 'No'; Summary = 'User account created. Validate authorization.'; RepairAction = 'None'; PreviousState = 'Missing'; Guidance = @() }
    [pscustomobject]@{ Key = 'security_microsoft_windows_security_auditing_4726'; LogName = 'Security'; ProviderName = 'Microsoft-Windows-Security-Auditing'; EventId = 4726; Category = 'Security'; Classification = 'Security Investigation Required'; AutoRepair = 'No'; Summary = 'User account deleted. Validate authorization.'; RepairAction = 'None'; PreviousState = 'Missing'; Guidance = @() }
    [pscustomobject]@{ Key = 'security_microsoft_windows_security_auditing_4732'; LogName = 'Security'; ProviderName = 'Microsoft-Windows-Security-Auditing'; EventId = 4732; Category = 'Security'; Classification = 'Security Investigation Required'; AutoRepair = 'No'; Summary = 'Member added to local security-enabled group. Validate authorization.'; RepairAction = 'None'; PreviousState = 'Missing'; Guidance = @() }
    [pscustomobject]@{ Key = 'security_microsoft_windows_security_auditing_4733'; LogName = 'Security'; ProviderName = 'Microsoft-Windows-Security-Auditing'; EventId = 4733; Category = 'Security'; Classification = 'Security Investigation Required'; AutoRepair = 'No'; Summary = 'Member removed from local security-enabled group. Validate authorization.'; RepairAction = 'None'; PreviousState = 'Missing'; Guidance = @() }
    [pscustomobject]@{ Key = 'security_microsoft_windows_security_auditing_4740'; LogName = 'Security'; ProviderName = 'Microsoft-Windows-Security-Auditing'; EventId = 4740; Category = 'Security'; Classification = 'Security Investigation Required'; AutoRepair = 'No'; Summary = 'Account locked out. Identify lockout source before unlocking or changing policy.'; RepairAction = 'None'; PreviousState = 'Missing'; Guidance = @() }
    [pscustomobject]@{ Key = 'legacy_event_243'; LogName = 'System'; ProviderName = '*'; EventId = 243; Category = 'Legacy'; Classification = 'Diagnostic'; AutoRepair = 'No'; Summary = 'Legacy Event ID 243 helper retained for compatibility. Requires operator to provide log/provider context for precise diagnosis.'; RepairAction = 'None'; PreviousState = 'Existing / Needs Improvement'; Guidance = @() }
    [pscustomobject]@{ Key = 'system_disk_7'; LogName = 'System'; ProviderName = 'Disk'; EventId = 7; Category = 'Storage'; Classification = 'Hardware Investigation Required'; AutoRepair = 'No'; Summary = 'Disk event 7. Storage evidence collection only; no destructive repair.'; RepairAction = 'None'; PreviousState = 'Missing'; Guidance = @('Review disk/controller/cable/power evidence.', 'CHKDSK cannot repair physical media failure.') }
    [pscustomobject]@{ Key = 'system_disk_11'; LogName = 'System'; ProviderName = 'Disk'; EventId = 11; Category = 'Storage'; Classification = 'Hardware Investigation Required'; AutoRepair = 'No'; Summary = 'Disk event 11. Storage evidence collection only; no destructive repair.'; RepairAction = 'None'; PreviousState = 'Missing'; Guidance = @('Review disk/controller/cable/power evidence.', 'CHKDSK cannot repair physical media failure.') }
    [pscustomobject]@{ Key = 'system_disk_15'; LogName = 'System'; ProviderName = 'Disk'; EventId = 15; Category = 'Storage'; Classification = 'Hardware Investigation Required'; AutoRepair = 'No'; Summary = 'Disk event 15. Storage evidence collection only; no destructive repair.'; RepairAction = 'None'; PreviousState = 'Missing'; Guidance = @('Review disk/controller/cable/power evidence.', 'CHKDSK cannot repair physical media failure.') }
    [pscustomobject]@{ Key = 'system_disk_51'; LogName = 'System'; ProviderName = 'Disk'; EventId = 51; Category = 'Storage'; Classification = 'Hardware Investigation Required'; AutoRepair = 'No'; Summary = 'Disk event 51. Storage evidence collection only; no destructive repair.'; RepairAction = 'None'; PreviousState = 'Missing'; Guidance = @('Review disk/controller/cable/power evidence.', 'CHKDSK cannot repair physical media failure.') }
    [pscustomobject]@{ Key = 'system_disk_153'; LogName = 'System'; ProviderName = 'Disk'; EventId = 153; Category = 'Storage'; Classification = 'Hardware Investigation Required'; AutoRepair = 'No'; Summary = 'Disk event 153. Storage evidence collection only; no destructive repair.'; RepairAction = 'None'; PreviousState = 'Missing'; Guidance = @('Review disk/controller/cable/power evidence.', 'CHKDSK cannot repair physical media failure.') }
    [pscustomobject]@{ Key = 'system_disk_157'; LogName = 'System'; ProviderName = 'Disk'; EventId = 157; Category = 'Storage'; Classification = 'Diagnostic'; AutoRepair = 'No'; Summary = 'Disk event 157. Storage evidence collection only; no destructive repair.'; RepairAction = 'None'; PreviousState = 'Missing'; Guidance = @('Review disk/controller/cable/power evidence.', 'CHKDSK cannot repair physical media failure.') }
    [pscustomobject]@{ Key = 'system_eventlog_6005'; LogName = 'System'; ProviderName = 'EventLog'; EventId = 6005; Category = 'PowerBoot'; Classification = 'Informational'; AutoRepair = 'No'; Summary = 'Event Log service started. Usually informational boot marker.'; RepairAction = 'None'; PreviousState = 'Missing'; Guidance = @() }
    [pscustomobject]@{ Key = 'system_eventlog_6006'; LogName = 'System'; ProviderName = 'EventLog'; EventId = 6006; Category = 'PowerBoot'; Classification = 'Informational'; AutoRepair = 'No'; Summary = 'Event Log service stopped. Usually informational shutdown marker.'; RepairAction = 'None'; PreviousState = 'Missing'; Guidance = @() }
    [pscustomobject]@{ Key = 'system_eventlog_6008'; LogName = 'System'; ProviderName = 'EventLog'; EventId = 6008; Category = 'PowerBoot'; Classification = 'Diagnostic'; AutoRepair = 'No'; Summary = 'Previous shutdown was unexpected.'; RepairAction = 'None'; PreviousState = 'Missing'; Guidance = @() }
    [pscustomobject]@{ Key = 'system_eventlog_6009'; LogName = 'System'; ProviderName = 'EventLog'; EventId = 6009; Category = 'PowerBoot'; Classification = 'Informational'; AutoRepair = 'No'; Summary = 'Operating system version detected at boot. Informational boot marker.'; RepairAction = 'None'; PreviousState = 'Missing'; Guidance = @() }
    [pscustomobject]@{ Key = 'system_dns_client_events_1014'; LogName = 'System'; ProviderName = 'Microsoft-Windows-DNS-Client'; EventId = 1014; Category = 'NetworkDns'; Classification = 'Conditionally Repairable'; AutoRepair = 'Conditional'; Summary = 'DNS Client name resolution timeout. Diagnoses adapters, DNS servers, DNS Client service, gateway, and cache without replacing corporate DNS.'; RepairAction = 'DnsDiagnostic'; PreviousState = 'Missing'; Guidance = @() }
    [pscustomobject]@{ Key = 'system_driverframeworks_usermode_10110'; LogName = 'System'; ProviderName = 'Microsoft-Windows-DriverFrameworks-UserMode'; EventId = 10110; Category = 'DriversDevices'; Classification = 'Diagnostic'; AutoRepair = 'No'; Summary = 'DriverFrameworks-UserMode device/driver problem 10110. Diagnostic only; no blind device uninstall.'; RepairAction = 'None'; PreviousState = 'Missing'; Guidance = @() }
    [pscustomobject]@{ Key = 'system_driverframeworks_usermode_10111'; LogName = 'System'; ProviderName = 'Microsoft-Windows-DriverFrameworks-UserMode'; EventId = 10111; Category = 'DriversDevices'; Classification = 'Diagnostic'; AutoRepair = 'No'; Summary = 'DriverFrameworks-UserMode device/driver problem 10111. Diagnostic only; no blind device uninstall.'; RepairAction = 'None'; PreviousState = 'Missing'; Guidance = @() }
    [pscustomobject]@{ Key = 'system_kernel_general_12'; LogName = 'System'; ProviderName = 'Microsoft-Windows-Kernel-General'; EventId = 12; Category = 'PowerBoot'; Classification = 'Informational'; AutoRepair = 'No'; Summary = 'Operating system started.'; RepairAction = 'None'; PreviousState = 'Missing'; Guidance = @() }
    [pscustomobject]@{ Key = 'system_kernel_general_13'; LogName = 'System'; ProviderName = 'Microsoft-Windows-Kernel-General'; EventId = 13; Category = 'PowerBoot'; Classification = 'Informational'; AutoRepair = 'No'; Summary = 'Operating system shut down.'; RepairAction = 'None'; PreviousState = 'Missing'; Guidance = @() }
    [pscustomobject]@{ Key = 'system_kernel_pnp_219'; LogName = 'System'; ProviderName = 'Microsoft-Windows-Kernel-PnP'; EventId = 219; Category = 'DriversDevices'; Classification = 'Diagnostic'; AutoRepair = 'No'; Summary = 'Kernel-PnP driver failed to load for a device. Identifies device instance information when available.'; RepairAction = 'None'; PreviousState = 'Missing'; Guidance = @() }
    [pscustomobject]@{ Key = 'system_kernel_power_41'; LogName = 'System'; ProviderName = 'Microsoft-Windows-Kernel-Power'; EventId = 41; Category = 'PowerBoot'; Classification = 'Diagnostic'; AutoRepair = 'No'; Summary = 'Unexpected shutdown or restart without clean shutdown. Correlates with EventLog 6008, User32 1074, Kernel-General 12/13, and BugCheck 1001.'; RepairAction = 'None'; PreviousState = 'Missing'; Guidance = @('Check for recent BugCheck events before suspecting power hardware.', 'Review thermal, firmware, UPS, battery, and driver history when repeated.') }
    [pscustomobject]@{ Key = 'system_wer_bugcheck_1001'; LogName = 'System'; ProviderName = 'Microsoft-Windows-WER-SystemErrorReporting'; EventId = 1001; Category = 'PowerBoot'; Classification = 'Diagnostic'; AutoRepair = 'No'; Summary = 'BugCheck / BSOD report. Diagnostic only; use dump, stop code, and driver evidence before remediation.'; RepairAction = 'None'; PreviousState = 'Missing'; Guidance = @('Collect bugcheck code and parameters.', 'Do not run broad repair commands without evidence.') }
    [pscustomobject]@{ Key = 'system_whea_logger_1'; LogName = 'System'; ProviderName = 'Microsoft-Windows-WHEA-Logger'; EventId = 1; Category = 'HardwareWhea'; Classification = 'Hardware Investigation Required'; AutoRepair = 'No'; Summary = 'WHEA hardware error report 1. Evidence collection and guidance only; no fake repair.'; RepairAction = 'None'; PreviousState = 'Missing'; Guidance = @() }
    [pscustomobject]@{ Key = 'system_whea_logger_17'; LogName = 'System'; ProviderName = 'Microsoft-Windows-WHEA-Logger'; EventId = 17; Category = 'HardwareWhea'; Classification = 'Diagnostic'; AutoRepair = 'No'; Summary = 'WHEA hardware error report 17. Evidence collection and guidance only; no fake repair.'; RepairAction = 'None'; PreviousState = 'Missing'; Guidance = @() }
    [pscustomobject]@{ Key = 'system_whea_logger_18'; LogName = 'System'; ProviderName = 'Microsoft-Windows-WHEA-Logger'; EventId = 18; Category = 'HardwareWhea'; Classification = 'Hardware Investigation Required'; AutoRepair = 'No'; Summary = 'WHEA hardware error report 18. Evidence collection and guidance only; no fake repair.'; RepairAction = 'None'; PreviousState = 'Missing'; Guidance = @() }
    [pscustomobject]@{ Key = 'system_whea_logger_19'; LogName = 'System'; ProviderName = 'Microsoft-Windows-WHEA-Logger'; EventId = 19; Category = 'HardwareWhea'; Classification = 'Diagnostic'; AutoRepair = 'No'; Summary = 'WHEA hardware error report 19. Evidence collection and guidance only; no fake repair.'; RepairAction = 'None'; PreviousState = 'Missing'; Guidance = @() }
    [pscustomobject]@{ Key = 'system_whea_logger_20'; LogName = 'System'; ProviderName = 'Microsoft-Windows-WHEA-Logger'; EventId = 20; Category = 'HardwareWhea'; Classification = 'Hardware Investigation Required'; AutoRepair = 'No'; Summary = 'WHEA hardware error report 20. Evidence collection and guidance only; no fake repair.'; RepairAction = 'None'; PreviousState = 'Missing'; Guidance = @() }
    [pscustomobject]@{ Key = 'system_ntfs_55'; LogName = 'System'; ProviderName = 'Ntfs'; EventId = 55; Category = 'Storage'; Classification = 'Conditionally Repairable'; AutoRepair = 'Conditional'; Summary = 'NTFS event 55. Filesystem diagnostic with cautious guidance for repair scheduling, no automatic reboot.'; RepairAction = 'FilesystemDiagnostic'; PreviousState = 'Missing'; Guidance = @() }
    [pscustomobject]@{ Key = 'system_ntfs_98'; LogName = 'System'; ProviderName = 'Ntfs'; EventId = 98; Category = 'Storage'; Classification = 'Conditionally Repairable'; AutoRepair = 'Conditional'; Summary = 'NTFS event 98. Filesystem diagnostic with cautious guidance for repair scheduling, no automatic reboot.'; RepairAction = 'FilesystemDiagnostic'; PreviousState = 'Missing'; Guidance = @() }
    [pscustomobject]@{ Key = 'system_ntfs_140'; LogName = 'System'; ProviderName = 'Ntfs'; EventId = 140; Category = 'Storage'; Classification = 'Conditionally Repairable'; AutoRepair = 'Conditional'; Summary = 'NTFS event 140. Filesystem diagnostic with cautious guidance for repair scheduling, no automatic reboot.'; RepairAction = 'FilesystemDiagnostic'; PreviousState = 'Missing'; Guidance = @() }
    [pscustomobject]@{ Key = 'system_service_control_manager_7000'; LogName = 'System'; ProviderName = 'Service Control Manager'; EventId = 7000; Category = 'Services'; Classification = 'Conditionally Repairable'; AutoRepair = 'Conditional'; Summary = 'Service Control Manager event 7000. Identifies the affected service and reports current service state before any action.'; RepairAction = 'ServiceDiagnostic'; PreviousState = 'Missing'; Guidance = @('Do not modify unrelated services.', 'Use -Repair only after reviewing the affected service and startup type.') }
    [pscustomobject]@{ Key = 'system_service_control_manager_7001'; LogName = 'System'; ProviderName = 'Service Control Manager'; EventId = 7001; Category = 'Services'; Classification = 'Conditionally Repairable'; AutoRepair = 'Conditional'; Summary = 'Service Control Manager event 7001. Identifies the affected service and reports current service state before any action.'; RepairAction = 'ServiceDiagnostic'; PreviousState = 'Missing'; Guidance = @('Do not modify unrelated services.', 'Use -Repair only after reviewing the affected service and startup type.') }
    [pscustomobject]@{ Key = 'system_service_control_manager_7009'; LogName = 'System'; ProviderName = 'Service Control Manager'; EventId = 7009; Category = 'Services'; Classification = 'Diagnostic'; AutoRepair = 'No'; Summary = 'Service Control Manager event 7009. Identifies the affected service and reports current service state before any action.'; RepairAction = 'None'; PreviousState = 'Missing'; Guidance = @('Do not modify unrelated services.', 'Use -Repair only after reviewing the affected service and startup type.') }
    [pscustomobject]@{ Key = 'system_service_control_manager_7011'; LogName = 'System'; ProviderName = 'Service Control Manager'; EventId = 7011; Category = 'Services'; Classification = 'Diagnostic'; AutoRepair = 'No'; Summary = 'Service Control Manager event 7011. Identifies the affected service and reports current service state before any action.'; RepairAction = 'None'; PreviousState = 'Missing'; Guidance = @('Do not modify unrelated services.', 'Use -Repair only after reviewing the affected service and startup type.') }
    [pscustomobject]@{ Key = 'system_service_control_manager_7023'; LogName = 'System'; ProviderName = 'Service Control Manager'; EventId = 7023; Category = 'Services'; Classification = 'Conditionally Repairable'; AutoRepair = 'Conditional'; Summary = 'Service Control Manager event 7023. Identifies the affected service and reports current service state before any action.'; RepairAction = 'ServiceDiagnostic'; PreviousState = 'Missing'; Guidance = @('Do not modify unrelated services.', 'Use -Repair only after reviewing the affected service and startup type.') }
    [pscustomobject]@{ Key = 'system_service_control_manager_7024'; LogName = 'System'; ProviderName = 'Service Control Manager'; EventId = 7024; Category = 'Services'; Classification = 'Conditionally Repairable'; AutoRepair = 'Conditional'; Summary = 'Service Control Manager event 7024. Identifies the affected service and reports current service state before any action.'; RepairAction = 'ServiceDiagnostic'; PreviousState = 'Missing'; Guidance = @('Do not modify unrelated services.', 'Use -Repair only after reviewing the affected service and startup type.') }
    [pscustomobject]@{ Key = 'system_service_control_manager_7030'; LogName = 'System'; ProviderName = 'Service Control Manager'; EventId = 7030; Category = 'Services'; Classification = 'Diagnostic'; AutoRepair = 'No'; Summary = 'Service Control Manager event 7030. Identifies the affected service and reports current service state before any action.'; RepairAction = 'None'; PreviousState = 'Existing / Needs Improvement'; Guidance = @('Do not modify unrelated services.', 'Use -Repair only after reviewing the affected service and startup type.') }
    [pscustomobject]@{ Key = 'system_service_control_manager_7031'; LogName = 'System'; ProviderName = 'Service Control Manager'; EventId = 7031; Category = 'Services'; Classification = 'Conditionally Repairable'; AutoRepair = 'Conditional'; Summary = 'Service Control Manager event 7031. Identifies the affected service and reports current service state before any action.'; RepairAction = 'ServiceDiagnostic'; PreviousState = 'Missing'; Guidance = @('Do not modify unrelated services.', 'Use -Repair only after reviewing the affected service and startup type.') }
    [pscustomobject]@{ Key = 'system_service_control_manager_7034'; LogName = 'System'; ProviderName = 'Service Control Manager'; EventId = 7034; Category = 'Services'; Classification = 'Conditionally Repairable'; AutoRepair = 'Conditional'; Summary = 'Service Control Manager event 7034. Identifies the affected service and reports current service state before any action.'; RepairAction = 'ServiceDiagnostic'; PreviousState = 'Missing'; Guidance = @('Do not modify unrelated services.', 'Use -Repair only after reviewing the affected service and startup type.') }
    [pscustomobject]@{ Key = 'system_service_control_manager_7045'; LogName = 'System'; ProviderName = 'Service Control Manager'; EventId = 7045; Category = 'Services'; Classification = 'Diagnostic'; AutoRepair = 'No'; Summary = 'Service Control Manager event 7045. Identifies the affected service and reports current service state before any action.'; RepairAction = 'None'; PreviousState = 'Missing'; Guidance = @('Do not modify unrelated services.', 'Use -Repair only after reviewing the affected service and startup type.') }
    [pscustomobject]@{ Key = 'system_user32_1074'; LogName = 'System'; ProviderName = 'User32'; EventId = 1074; Category = 'PowerBoot'; Classification = 'Diagnostic'; AutoRepair = 'No'; Summary = 'Planned restart or shutdown initiated by a user, process, or service.'; RepairAction = 'None'; PreviousState = 'Missing'; Guidance = @() }
    [pscustomobject]@{ Key = 'system_storahci_129'; LogName = 'System'; ProviderName = 'storahci'; EventId = 129; Category = 'Storage'; Classification = 'Diagnostic'; AutoRepair = 'No'; Summary = 'storahci controller timeout event 129. Diagnostic only; may indicate controller, firmware, driver, power, or device latency.'; RepairAction = 'None'; PreviousState = 'Missing'; Guidance = @() }
    [pscustomobject]@{ Key = 'system_stornvme_129'; LogName = 'System'; ProviderName = 'stornvme'; EventId = 129; Category = 'Storage'; Classification = 'Diagnostic'; AutoRepair = 'No'; Summary = 'stornvme controller timeout event 129. Diagnostic only; may indicate controller, firmware, driver, power, or device latency.'; RepairAction = 'None'; PreviousState = 'Missing'; Guidance = @() }
)

function Get-PowerToolEventCatalog {
    [CmdletBinding()]
    param([string]$Key)
    if ([string]::IsNullOrWhiteSpace($Key)) { return $script:PowerToolEventCatalog }
    $item = $script:PowerToolEventCatalog | Where-Object { $_.Key -eq $Key } | Select-Object -First 1
    if (-not $item) { throw "Unknown PowerTool event key: $Key" }
    return $item
}

function ConvertTo-PowerToolEventDataMap {
    [CmdletBinding()]
    param([Parameter(Mandatory)]$Event)
    $map = [ordered]@{}
    try {
        [xml]$xml = $Event.ToXml()
        $index = 0
        foreach ($data in $xml.Event.EventData.Data) {
            $name = if ($data.Name) { [string]$data.Name } else { "Data$index" }
            if (-not $map.Contains($name)) { $map[$name] = [string]$data.'#text' }
            $index++
        }
    }
    catch { }
    return $map
}

function Get-PowerToolEventTextValue {
    [CmdletBinding()]
    param(
        [System.Collections.IDictionary]$Data,
        [string[]]$Names
    )
    foreach ($name in $Names) {
        if ($Data.ContainsKey($name) -and -not [string]::IsNullOrWhiteSpace([string]$Data[$name])) {
            return [string]$Data[$name]
        }
    }
    return $null
}

function Get-PowerToolMatchingEvents {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]$CatalogItem,
        [int]$DaysBack = 30,
        [int]$MaxEvents = 50
    )
    $start = (Get-Date).AddDays(-[Math]::Abs($DaysBack))
    $filter = @{ LogName = $CatalogItem.LogName; Id = [int]$CatalogItem.EventId; StartTime = $start }
    if ($CatalogItem.ProviderName -ne '*') { $filter.ProviderName = $CatalogItem.ProviderName }
    try {
        @(Get-WinEvent -FilterHashtable $filter -MaxEvents $MaxEvents -ErrorAction Stop)
    }
    catch [System.Diagnostics.Eventing.Reader.EventLogNotFoundException] { @() }
    catch [System.Diagnostics.Eventing.Reader.EventLogException] { @() }
    catch { throw }
}

function Get-PowerToolServiceEvidence {
    [CmdletBinding()]
    param($Event)
    $data = ConvertTo-PowerToolEventDataMap -Event $Event
    $serviceName = Get-PowerToolEventTextValue -Data $data -Names @('param1','ServiceName','service','Data0')
    $service = $null
    if ($serviceName) {
        try { $service = Get-Service -Name $serviceName -ErrorAction Stop }
        catch {
            try { $service = Get-Service -DisplayName $serviceName -ErrorAction Stop }
            catch { }
        }
    }
    [pscustomobject]@{
        ServiceName = $serviceName
        ServiceStatus = if ($service) { $service.Status } else { $null }
        ServiceStartType = if ($service) { $service.StartType } else { $null }
        ServiceDisplayName = if ($service) { $service.DisplayName } else { $null }
        ErrorText = Get-PowerToolEventTextValue -Data $data -Names @('param2','ErrorCode','Data1')
    }
}

function Get-PowerToolApplicationEvidence {
    [CmdletBinding()]
    param($Event)
    $data = ConvertTo-PowerToolEventDataMap -Event $Event
    [pscustomobject]@{
        Application = Get-PowerToolEventTextValue -Data $data -Names @('AppName','param1','Data0')
        ApplicationVersion = Get-PowerToolEventTextValue -Data $data -Names @('AppVersion','param2','Data1')
        Module = Get-PowerToolEventTextValue -Data $data -Names @('ModuleName','param3','Data2')
        ExceptionCode = Get-PowerToolEventTextValue -Data $data -Names @('ExceptionCode','param7','Data6')
        ProcessId = Get-PowerToolEventTextValue -Data $data -Names @('ProcessId','param9','Data8')
    }
}

function Get-PowerToolDeviceEvidence {
    [CmdletBinding()]
    param($Event)
    $data = ConvertTo-PowerToolEventDataMap -Event $Event
    $instanceId = Get-PowerToolEventTextValue -Data $data -Names @('DeviceInstanceId','DeviceInstanceID','InstanceId','param1','Data0')
    $device = $null
    if ($instanceId -and (Get-Command Get-PnpDevice -ErrorAction SilentlyContinue)) {
        try { $device = Get-PnpDevice -InstanceId $instanceId -ErrorAction Stop } catch { }
    }
    [pscustomobject]@{
        DeviceInstanceId = $instanceId
        DeviceName = if ($device) { $device.FriendlyName } else { $null }
        DeviceStatus = if ($device) { $device.Status } else { $null }
        DeviceClass = if ($device) { $device.Class } else { $null }
        ProblemCode = Get-PowerToolEventTextValue -Data $data -Names @('Problem','ProblemCode','Data1')
    }
}

function Get-PowerToolDnsEvidence {
    [CmdletBinding()]
    param($Event)
    $data = ConvertTo-PowerToolEventDataMap -Event $Event
    $dnsServers = @()
    if (Get-Command Get-DnsClientServerAddress -ErrorAction SilentlyContinue) {
        try { $dnsServers = @(Get-DnsClientServerAddress -AddressFamily IPv4,IPv6 -ErrorAction Stop | Where-Object { $_.ServerAddresses }) } catch { }
    }
    $service = $null
    try { $service = Get-Service -Name Dnscache -ErrorAction Stop } catch { }
    [pscustomobject]@{
        QueryName = Get-PowerToolEventTextValue -Data $data -Names @('QueryName','param1','Data0')
        DnsClientService = if ($service) { $service.Status } else { $null }
        ConfiguredServers = ($dnsServers | ForEach-Object { '{0}: {1}' -f $_.InterfaceAlias, ($_.ServerAddresses -join ',') }) -join '; '
    }
}

function Get-PowerToolFrequencySummary {
    [CmdletBinding()]
    param([object[]]$Events)
    $now = Get-Date
    [pscustomobject]@{
        Total = @($Events).Count
        Last24Hours = @($Events | Where-Object { $_.TimeCreated -ge $now.AddHours(-24) }).Count
        Last7Days = @($Events | Where-Object { $_.TimeCreated -ge $now.AddDays(-7) }).Count
        Last30Days = @($Events | Where-Object { $_.TimeCreated -ge $now.AddDays(-30) }).Count
        FirstOccurrence = @($Events | Sort-Object TimeCreated | Select-Object -First 1).TimeCreated
        LatestOccurrence = @($Events | Sort-Object TimeCreated -Descending | Select-Object -First 1).TimeCreated
    }
}

function Write-PowerToolEventOutput {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]$CatalogItem,
        [Parameter(Mandatory)][object[]]$Events,
        [switch]$Repair
    )
    $stylePath = Join-Path -Path (Split-Path -Parent $PSScriptRoot) -ChildPath '..\lib\PowerToolStyle.ps1'
    $stylePath = [System.IO.Path]::GetFullPath($stylePath)
    if (Test-Path -LiteralPath $stylePath) { . $stylePath }
    Initialize-PowerToolConsole

    Write-PowerToolSection -Title ('Event Viewer: {0} {1}' -f $CatalogItem.ProviderName, $CatalogItem.EventId)
    Write-PowerToolItem -Label 'Log' -Value $CatalogItem.LogName
    Write-PowerToolItem -Label 'Provider' -Value $CatalogItem.ProviderName
    Write-PowerToolItem -Label 'Event ID' -Value ([string]$CatalogItem.EventId)
    Write-PowerToolItem -Label 'Classification' -Value $CatalogItem.Classification -Color Yellow
    Write-PowerToolItem -Label 'Auto repair' -Value $CatalogItem.AutoRepair
    Write-PowerToolStatus -Type Info -Message $CatalogItem.Summary

    if (-not $Events -or $Events.Count -eq 0) {
        Write-PowerToolStatus -Type Success -Message 'No matching events were found in the selected time window.'
        return [pscustomobject]@{ Result = 'NoProblemDetected'; Key = $CatalogItem.Key; Count = 0 }
    }

    $frequency = Get-PowerToolFrequencySummary -Events $Events
    Write-PowerToolSection -Title 'Frequency'
    Write-PowerToolItem -Label 'Total' -Value ([string]$frequency.Total)
    Write-PowerToolItem -Label 'Last 24 hours' -Value ([string]$frequency.Last24Hours)
    Write-PowerToolItem -Label 'Last 7 days' -Value ([string]$frequency.Last7Days)
    Write-PowerToolItem -Label 'Last 30 days' -Value ([string]$frequency.Last30Days)
    Write-PowerToolItem -Label 'First occurrence' -Value ([string]$frequency.FirstOccurrence)
    Write-PowerToolItem -Label 'Latest occurrence' -Value ([string]$frequency.LatestOccurrence)

    $latest = @($Events | Sort-Object TimeCreated -Descending | Select-Object -First 1)[0]
    Write-PowerToolSection -Title 'Latest Event Evidence'
    Write-PowerToolItem -Label 'Record ID' -Value ([string]$latest.RecordId)
    Write-PowerToolItem -Label 'Time' -Value ([string]$latest.TimeCreated)
    Write-PowerToolItem -Label 'Machine' -Value ([string]$latest.MachineName)

    switch ($CatalogItem.Category) {
        'Services' {
            $evidence = Get-PowerToolServiceEvidence -Event $latest
            Write-PowerToolItem -Label 'Service' -Value ([string]$evidence.ServiceName) -Color Cyan
            Write-PowerToolItem -Label 'Display name' -Value ([string]$evidence.ServiceDisplayName)
            Write-PowerToolItem -Label 'Status' -Value ([string]$evidence.ServiceStatus)
            Write-PowerToolItem -Label 'Start type' -Value ([string]$evidence.ServiceStartType)
            Write-PowerToolItem -Label 'Error detail' -Value ([string]$evidence.ErrorText)
        }
        'DriversDevices' {
            $evidence = Get-PowerToolDeviceEvidence -Event $latest
            Write-PowerToolItem -Label 'Device instance' -Value ([string]$evidence.DeviceInstanceId) -Color Cyan
            Write-PowerToolItem -Label 'Device name' -Value ([string]$evidence.DeviceName)
            Write-PowerToolItem -Label 'Device status' -Value ([string]$evidence.DeviceStatus)
            Write-PowerToolItem -Label 'Device class' -Value ([string]$evidence.DeviceClass)
            Write-PowerToolItem -Label 'Problem code' -Value ([string]$evidence.ProblemCode)
        }
        'NetworkDns' {
            $evidence = Get-PowerToolDnsEvidence -Event $latest
            Write-PowerToolItem -Label 'Query name' -Value ([string]$evidence.QueryName) -Color Cyan
            Write-PowerToolItem -Label 'DNS Client' -Value ([string]$evidence.DnsClientService)
            Write-PowerToolItem -Label 'DNS servers' -Value ([string]$evidence.ConfiguredServers)
        }
        'Application' {
            $evidence = Get-PowerToolApplicationEvidence -Event $latest
            Write-PowerToolItem -Label 'Application' -Value ([string]$evidence.Application) -Color Cyan
            Write-PowerToolItem -Label 'Version' -Value ([string]$evidence.ApplicationVersion)
            Write-PowerToolItem -Label 'Module' -Value ([string]$evidence.Module)
            Write-PowerToolItem -Label 'Exception' -Value ([string]$evidence.ExceptionCode)
            Write-PowerToolItem -Label 'Process ID' -Value ([string]$evidence.ProcessId)
        }
        default {
            $data = ConvertTo-PowerToolEventDataMap -Event $latest
            $shown = 0
            foreach ($key in $data.Keys) {
                if ($shown -ge 8) { break }
                Write-PowerToolItem -Label $key -Value ([string]$data[$key])
                $shown++
            }
        }
    }

    Write-PowerToolSection -Title 'Safety Decision'
    if ($CatalogItem.AutoRepair -eq 'No') {
        Write-PowerToolStatus -Type Warning -Message 'Automatic repair is not appropriate for this event. Diagnostic evidence and guidance were produced instead.'
    }
    elseif ($Repair) {
        Write-PowerToolStatus -Type Warning -Message 'Repair mode was requested, but this handler only performs guarded diagnostics unless a safe target-specific action is implemented.'
    }
    else {
        Write-PowerToolStatus -Type Info -Message 'Run with -Repair only after reviewing the affected component and confirming the action is safe.'
    }

    foreach ($line in $CatalogItem.Guidance) { Write-PowerToolStatus -Type Info -Message $line }

    $result = if ($CatalogItem.Classification -match 'Hardware') { 'HardwareInvestigationRequired' } elseif ($CatalogItem.Classification -match 'Security') { 'SecurityInvestigationRequired' } elseif ($CatalogItem.AutoRepair -eq 'No') { 'DiagnosticCompleted' } else { 'ManualConfirmationRequired' }
    return [pscustomobject]@{ Result = $result; Key = $CatalogItem.Key; Count = $frequency.Total; Latest = $frequency.LatestOccurrence }
}


function Start-PowerToolEventTranscript {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$EventKey)
    if ($script:PowerToolEventTranscriptStarted) { return }
    try {
        $logRoot = Join-Path -Path $PSScriptRoot -ChildPath 'logs'
        New-Item -ItemType Directory -Path $logRoot -Force | Out-Null
        $stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
        $safeKey = $EventKey -replace '[^A-Za-z0-9_.-]', '_'
        $logPath = Join-Path -Path $logRoot -ChildPath ("event_{0}_{1}.log" -f $safeKey, $stamp)
        Start-Transcript -Path $logPath -Append -ErrorAction Stop | Out-Null
        $script:PowerToolEventTranscriptStarted = $true
    }
    catch {
        $script:PowerToolEventTranscriptStarted = $false
        Write-Warning ("Unable to start diagnostic transcript: {0}" -f $_.Exception.Message)
    }
}

function Stop-PowerToolEventTranscript {
    [CmdletBinding()]
    param()
    if (-not $script:PowerToolEventTranscriptStarted) { return }
    try { Stop-Transcript | Out-Null } catch { }
    $script:PowerToolEventTranscriptStarted = $false
}

function Invoke-PowerToolEventDiagnostic {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$EventKey,
        [ValidateRange(1,3650)][int]$DaysBack = 30,
        [ValidateRange(1,500)][int]$MaxEvents = 50,
        [switch]$Repair
    )
    $item = Get-PowerToolEventCatalog -Key $EventKey
    Start-PowerToolEventTranscript -EventKey $EventKey
    try {
        $events = Get-PowerToolMatchingEvents -CatalogItem $item -DaysBack $DaysBack -MaxEvents $MaxEvents
        Write-PowerToolEventOutput -CatalogItem $item -Events $events -Repair:$Repair
    }
    finally {
        Stop-PowerToolEventTranscript
    }
}
