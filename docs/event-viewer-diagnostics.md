# Event Viewer Diagnostics

PowerTool Event Viewer support is based on `Log + Provider + Event ID`. Event IDs are not treated as globally unique.

The scripts in `extras/event_viewer_fixes/` are discovered by the existing PowerTool menu. Each event-specific script calls the shared `PowerTool.EventViewer.ps1` engine, which performs detection, frequency analysis, evidence extraction, safety classification, and reporting.

Automatic repair is intentionally conservative. Hardware, storage, WHEA, security, crash, and shutdown events produce diagnostics and remediation guidance instead of broad reset commands.

## Supported catalog

| Log | Provider | Event ID | Classification | Auto Repair | Script |
|---|---|---:|---|---|---|
| Application | .NET Runtime | 1026 | Diagnostic | No | `extras/event_viewer_fixes/tool_event_application_dotnet_runtime_1026.ps1` |
| Application | Application Error | 1000 | Diagnostic | No | `extras/event_viewer_fixes/tool_event_application_application_error_1000.ps1` |
| Application | Application Hang | 1002 | Diagnostic | No | `extras/event_viewer_fixes/tool_event_application_application_hang_1002.ps1` |
| Application | MsiInstaller | 11707 | Diagnostic | No | `extras/event_viewer_fixes/tool_event_application_msiinstaller_11707.ps1` |
| Application | MsiInstaller | 11708 | Diagnostic | No | `extras/event_viewer_fixes/tool_event_application_msiinstaller_11708.ps1` |
| Application | Windows Error Reporting | 1001 | Diagnostic | No | `extras/event_viewer_fixes/tool_event_application_windows_error_reporting_1001.ps1` |
| Security | Microsoft-Windows-Security-Auditing | 1102 | Security Investigation Required | No | `extras/event_viewer_fixes/tool_event_security_microsoft_windows_security_auditing_1102.ps1` |
| Security | Microsoft-Windows-Security-Auditing | 4624 | Informational | No | `extras/event_viewer_fixes/tool_event_security_microsoft_windows_security_auditing_4624.ps1` |
| Security | Microsoft-Windows-Security-Auditing | 4625 | Security Investigation Required | No | `extras/event_viewer_fixes/tool_event_security_microsoft_windows_security_auditing_4625.ps1` |
| Security | Microsoft-Windows-Security-Auditing | 4634 | Informational | No | `extras/event_viewer_fixes/tool_event_security_microsoft_windows_security_auditing_4634.ps1` |
| Security | Microsoft-Windows-Security-Auditing | 4647 | Informational | No | `extras/event_viewer_fixes/tool_event_security_microsoft_windows_security_auditing_4647.ps1` |
| Security | Microsoft-Windows-Security-Auditing | 4648 | Security Investigation Required | No | `extras/event_viewer_fixes/tool_event_security_microsoft_windows_security_auditing_4648.ps1` |
| Security | Microsoft-Windows-Security-Auditing | 4672 | Security Investigation Required | No | `extras/event_viewer_fixes/tool_event_security_microsoft_windows_security_auditing_4672.ps1` |
| Security | Microsoft-Windows-Security-Auditing | 4688 | Security Investigation Required | No | `extras/event_viewer_fixes/tool_event_security_microsoft_windows_security_auditing_4688.ps1` |
| Security | Microsoft-Windows-Security-Auditing | 4720 | Security Investigation Required | No | `extras/event_viewer_fixes/tool_event_security_microsoft_windows_security_auditing_4720.ps1` |
| Security | Microsoft-Windows-Security-Auditing | 4726 | Security Investigation Required | No | `extras/event_viewer_fixes/tool_event_security_microsoft_windows_security_auditing_4726.ps1` |
| Security | Microsoft-Windows-Security-Auditing | 4732 | Security Investigation Required | No | `extras/event_viewer_fixes/tool_event_security_microsoft_windows_security_auditing_4732.ps1` |
| Security | Microsoft-Windows-Security-Auditing | 4733 | Security Investigation Required | No | `extras/event_viewer_fixes/tool_event_security_microsoft_windows_security_auditing_4733.ps1` |
| Security | Microsoft-Windows-Security-Auditing | 4740 | Security Investigation Required | No | `extras/event_viewer_fixes/tool_event_security_microsoft_windows_security_auditing_4740.ps1` |
| System | * | 243 | Diagnostic | No | `extras/event_viewer_fixes/tool_event_243.ps1` |
| System | Disk | 7 | Hardware Investigation Required | No | `extras/event_viewer_fixes/tool_event_system_disk_7.ps1` |
| System | Disk | 11 | Hardware Investigation Required | No | `extras/event_viewer_fixes/tool_event_system_disk_11.ps1` |
| System | Disk | 15 | Hardware Investigation Required | No | `extras/event_viewer_fixes/tool_event_system_disk_15.ps1` |
| System | Disk | 51 | Hardware Investigation Required | No | `extras/event_viewer_fixes/tool_event_system_disk_51.ps1` |
| System | Disk | 153 | Hardware Investigation Required | No | `extras/event_viewer_fixes/tool_event_system_disk_153.ps1` |
| System | Disk | 157 | Diagnostic | No | `extras/event_viewer_fixes/tool_event_system_disk_157.ps1` |
| System | EventLog | 6005 | Informational | No | `extras/event_viewer_fixes/tool_event_system_eventlog_6005.ps1` |
| System | EventLog | 6006 | Informational | No | `extras/event_viewer_fixes/tool_event_system_eventlog_6006.ps1` |
| System | EventLog | 6008 | Diagnostic | No | `extras/event_viewer_fixes/tool_event_system_eventlog_6008.ps1` |
| System | EventLog | 6009 | Informational | No | `extras/event_viewer_fixes/tool_event_system_eventlog_6009.ps1` |
| System | Microsoft-Windows-DNS-Client | 1014 | Conditionally Repairable | Conditional | `extras/event_viewer_fixes/tool_event_system_dns_client_events_1014.ps1` |
| System | Microsoft-Windows-DriverFrameworks-UserMode | 10110 | Diagnostic | No | `extras/event_viewer_fixes/tool_event_system_driverframeworks_usermode_10110.ps1` |
| System | Microsoft-Windows-DriverFrameworks-UserMode | 10111 | Diagnostic | No | `extras/event_viewer_fixes/tool_event_system_driverframeworks_usermode_10111.ps1` |
| System | Microsoft-Windows-Kernel-General | 12 | Informational | No | `extras/event_viewer_fixes/tool_event_system_kernel_general_12.ps1` |
| System | Microsoft-Windows-Kernel-General | 13 | Informational | No | `extras/event_viewer_fixes/tool_event_system_kernel_general_13.ps1` |
| System | Microsoft-Windows-Kernel-PnP | 219 | Diagnostic | No | `extras/event_viewer_fixes/tool_event_system_kernel_pnp_219.ps1` |
| System | Microsoft-Windows-Kernel-Power | 41 | Diagnostic | No | `extras/event_viewer_fixes/tool_event_system_kernel_power_41.ps1` |
| System | Microsoft-Windows-WER-SystemErrorReporting | 1001 | Diagnostic | No | `extras/event_viewer_fixes/tool_event_system_wer_bugcheck_1001.ps1` |
| System | Microsoft-Windows-WHEA-Logger | 1 | Hardware Investigation Required | No | `extras/event_viewer_fixes/tool_event_system_whea_logger_1.ps1` |
| System | Microsoft-Windows-WHEA-Logger | 17 | Diagnostic | No | `extras/event_viewer_fixes/tool_event_system_whea_logger_17.ps1` |
| System | Microsoft-Windows-WHEA-Logger | 18 | Hardware Investigation Required | No | `extras/event_viewer_fixes/tool_event_system_whea_logger_18.ps1` |
| System | Microsoft-Windows-WHEA-Logger | 19 | Diagnostic | No | `extras/event_viewer_fixes/tool_event_system_whea_logger_19.ps1` |
| System | Microsoft-Windows-WHEA-Logger | 20 | Hardware Investigation Required | No | `extras/event_viewer_fixes/tool_event_system_whea_logger_20.ps1` |
| System | Ntfs | 55 | Conditionally Repairable | Conditional | `extras/event_viewer_fixes/tool_event_system_ntfs_55.ps1` |
| System | Ntfs | 98 | Conditionally Repairable | Conditional | `extras/event_viewer_fixes/tool_event_system_ntfs_98.ps1` |
| System | Ntfs | 140 | Conditionally Repairable | Conditional | `extras/event_viewer_fixes/tool_event_system_ntfs_140.ps1` |
| System | Service Control Manager | 7000 | Conditionally Repairable | Conditional | `extras/event_viewer_fixes/tool_event_system_service_control_manager_7000.ps1` |
| System | Service Control Manager | 7001 | Conditionally Repairable | Conditional | `extras/event_viewer_fixes/tool_event_system_service_control_manager_7001.ps1` |
| System | Service Control Manager | 7009 | Diagnostic | No | `extras/event_viewer_fixes/tool_event_system_service_control_manager_7009.ps1` |
| System | Service Control Manager | 7011 | Diagnostic | No | `extras/event_viewer_fixes/tool_event_system_service_control_manager_7011.ps1` |
| System | Service Control Manager | 7023 | Conditionally Repairable | Conditional | `extras/event_viewer_fixes/tool_event_system_service_control_manager_7023.ps1` |
| System | Service Control Manager | 7024 | Conditionally Repairable | Conditional | `extras/event_viewer_fixes/tool_event_system_service_control_manager_7024.ps1` |
| System | Service Control Manager | 7030 | Diagnostic | No | `extras/event_viewer_fixes/tool_event_7030.ps1` |
| System | Service Control Manager | 7031 | Conditionally Repairable | Conditional | `extras/event_viewer_fixes/tool_event_system_service_control_manager_7031.ps1` |
| System | Service Control Manager | 7034 | Conditionally Repairable | Conditional | `extras/event_viewer_fixes/tool_event_system_service_control_manager_7034.ps1` |
| System | Service Control Manager | 7045 | Diagnostic | No | `extras/event_viewer_fixes/tool_event_system_service_control_manager_7045.ps1` |
| System | User32 | 1074 | Diagnostic | No | `extras/event_viewer_fixes/tool_event_system_user32_1074.ps1` |
| System | storahci | 129 | Diagnostic | No | `extras/event_viewer_fixes/tool_event_system_storahci_129.ps1` |
| System | stornvme | 129 | Diagnostic | No | `extras/event_viewer_fixes/tool_event_system_stornvme_129.ps1` |


## Safety notes

- Service events identify the affected service before any action is considered.
- Driver and device events collect device instance evidence and do not uninstall devices.
- Disk, NTFS, and controller events do not format, initialize, partition, or claim that filesystem repair fixes physical media.
- WHEA events are hardware reports and are not automatically repaired.
- DNS 1014 diagnostics do not replace corporate DNS servers with public resolvers.
- Security events are classified for investigation; normal audit events are not treated as repairable errors.

## Common parameters

Each event wrapper accepts:

```powershell
-DaysBack 30
-MaxEvents 50
-Repair
```

`-Repair` is guarded. Most handlers remain diagnostic-only unless the catalog marks the event as conditionally repairable and the affected component can be safely identified.
