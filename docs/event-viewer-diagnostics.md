# Event Viewer Standalone Diagnostics

Event Viewer tools in `extras/event_viewer_fixes/` are standalone `.ps1` files. Each file contains its own event identity, query logic, diagnostics, safety decision, and limited remediation where safe.

Events are identified by `Log + Provider + Event ID`; Event ID alone is not treated as unique.

No script requires `PowerTool.EventViewer.ps1`, another `.ps1`, custom modules, repository metadata, Internet access, or a cloned PowerShellTools repository.

## Supported standalone scripts

| Log | Provider | Event ID | Classification | Script |
|---|---|---:|---|---|
| Application | .NET Runtime | 1026 | Diagnostic | `extras/event_viewer_fixes/Fix-Application-DotNet-Runtime-1026.ps1` |
| Application | Application Error | 1000 | Diagnostic | `extras/event_viewer_fixes/Fix-Application-Application-Error-1000.ps1` |
| Application | Application Hang | 1002 | Diagnostic | `extras/event_viewer_fixes/Fix-Application-Application-Hang-1002.ps1` |
| Application | MsiInstaller | 11707 | Diagnostic | `extras/event_viewer_fixes/Fix-Application-MsiInstaller-11707.ps1` |
| Application | MsiInstaller | 11708 | Diagnostic | `extras/event_viewer_fixes/Fix-Application-MsiInstaller-11708.ps1` |
| Application | Windows Error Reporting | 1001 | Diagnostic | `extras/event_viewer_fixes/Fix-Application-Windows-Error-Reporting-1001.ps1` |
| Security | Microsoft-Windows-Security-Auditing | 1102 | Security Investigation Required | `extras/event_viewer_fixes/Fix-Security-Microsoft-Windows-Security-Auditing-1102.ps1` |
| Security | Microsoft-Windows-Security-Auditing | 4624 | Informational | `extras/event_viewer_fixes/Fix-Security-Microsoft-Windows-Security-Auditing-4624.ps1` |
| Security | Microsoft-Windows-Security-Auditing | 4625 | Security Investigation Required | `extras/event_viewer_fixes/Fix-Security-Microsoft-Windows-Security-Auditing-4625.ps1` |
| Security | Microsoft-Windows-Security-Auditing | 4634 | Informational | `extras/event_viewer_fixes/Fix-Security-Microsoft-Windows-Security-Auditing-4634.ps1` |
| Security | Microsoft-Windows-Security-Auditing | 4647 | Informational | `extras/event_viewer_fixes/Fix-Security-Microsoft-Windows-Security-Auditing-4647.ps1` |
| Security | Microsoft-Windows-Security-Auditing | 4648 | Security Investigation Required | `extras/event_viewer_fixes/Fix-Security-Microsoft-Windows-Security-Auditing-4648.ps1` |
| Security | Microsoft-Windows-Security-Auditing | 4672 | Security Investigation Required | `extras/event_viewer_fixes/Fix-Security-Microsoft-Windows-Security-Auditing-4672.ps1` |
| Security | Microsoft-Windows-Security-Auditing | 4688 | Security Investigation Required | `extras/event_viewer_fixes/Fix-Security-Microsoft-Windows-Security-Auditing-4688.ps1` |
| Security | Microsoft-Windows-Security-Auditing | 4720 | Security Investigation Required | `extras/event_viewer_fixes/Fix-Security-Microsoft-Windows-Security-Auditing-4720.ps1` |
| Security | Microsoft-Windows-Security-Auditing | 4726 | Security Investigation Required | `extras/event_viewer_fixes/Fix-Security-Microsoft-Windows-Security-Auditing-4726.ps1` |
| Security | Microsoft-Windows-Security-Auditing | 4732 | Security Investigation Required | `extras/event_viewer_fixes/Fix-Security-Microsoft-Windows-Security-Auditing-4732.ps1` |
| Security | Microsoft-Windows-Security-Auditing | 4733 | Security Investigation Required | `extras/event_viewer_fixes/Fix-Security-Microsoft-Windows-Security-Auditing-4733.ps1` |
| Security | Microsoft-Windows-Security-Auditing | 4740 | Security Investigation Required | `extras/event_viewer_fixes/Fix-Security-Microsoft-Windows-Security-Auditing-4740.ps1` |
| System | * | 243 | Diagnostic | `extras/event_viewer_fixes/Fix-System-Event-243.ps1` |
| System | Disk | 7 | Hardware Investigation Required | `extras/event_viewer_fixes/Fix-System-Disk-7.ps1` |
| System | Disk | 11 | Hardware Investigation Required | `extras/event_viewer_fixes/Fix-System-Disk-11.ps1` |
| System | Disk | 15 | Hardware Investigation Required | `extras/event_viewer_fixes/Fix-System-Disk-15.ps1` |
| System | Disk | 51 | Hardware Investigation Required | `extras/event_viewer_fixes/Fix-System-Disk-51.ps1` |
| System | Disk | 153 | Hardware Investigation Required | `extras/event_viewer_fixes/Fix-System-Disk-153.ps1` |
| System | Disk | 157 | Diagnostic | `extras/event_viewer_fixes/Fix-System-Disk-157.ps1` |
| System | EventLog | 6005 | Informational | `extras/event_viewer_fixes/Fix-System-EventLog-6005.ps1` |
| System | EventLog | 6006 | Informational | `extras/event_viewer_fixes/Fix-System-EventLog-6006.ps1` |
| System | EventLog | 6008 | Diagnostic | `extras/event_viewer_fixes/Fix-System-EventLog-6008.ps1` |
| System | EventLog | 6009 | Informational | `extras/event_viewer_fixes/Fix-System-EventLog-6009.ps1` |
| System | Microsoft-Windows-DNS-Client | 1014 | Conditionally Repairable | `extras/event_viewer_fixes/Fix-System-Microsoft-Windows-DNS-Client-1014.ps1` |
| System | Microsoft-Windows-DriverFrameworks-UserMode | 10110 | Diagnostic | `extras/event_viewer_fixes/Fix-System-Microsoft-Windows-DriverFrameworks-UserMode-10110.ps1` |
| System | Microsoft-Windows-DriverFrameworks-UserMode | 10111 | Diagnostic | `extras/event_viewer_fixes/Fix-System-Microsoft-Windows-DriverFrameworks-UserMode-10111.ps1` |
| System | Microsoft-Windows-Kernel-General | 12 | Informational | `extras/event_viewer_fixes/Fix-System-Microsoft-Windows-Kernel-General-12.ps1` |
| System | Microsoft-Windows-Kernel-General | 13 | Informational | `extras/event_viewer_fixes/Fix-System-Microsoft-Windows-Kernel-General-13.ps1` |
| System | Microsoft-Windows-Kernel-PnP | 219 | Diagnostic | `extras/event_viewer_fixes/Fix-System-Microsoft-Windows-Kernel-PnP-219.ps1` |
| System | Microsoft-Windows-Kernel-Power | 41 | Diagnostic | `extras/event_viewer_fixes/Fix-System-Microsoft-Windows-Kernel-Power-41.ps1` |
| System | Microsoft-Windows-WER-SystemErrorReporting | 1001 | Diagnostic | `extras/event_viewer_fixes/Fix-System-Microsoft-Windows-WER-SystemErrorReporting-1001.ps1` |
| System | Microsoft-Windows-WHEA-Logger | 1 | Hardware Investigation Required | `extras/event_viewer_fixes/Fix-System-Microsoft-Windows-WHEA-Logger-1.ps1` |
| System | Microsoft-Windows-WHEA-Logger | 17 | Diagnostic | `extras/event_viewer_fixes/Fix-System-Microsoft-Windows-WHEA-Logger-17.ps1` |
| System | Microsoft-Windows-WHEA-Logger | 18 | Hardware Investigation Required | `extras/event_viewer_fixes/Fix-System-Microsoft-Windows-WHEA-Logger-18.ps1` |
| System | Microsoft-Windows-WHEA-Logger | 19 | Diagnostic | `extras/event_viewer_fixes/Fix-System-Microsoft-Windows-WHEA-Logger-19.ps1` |
| System | Microsoft-Windows-WHEA-Logger | 20 | Hardware Investigation Required | `extras/event_viewer_fixes/Fix-System-Microsoft-Windows-WHEA-Logger-20.ps1` |
| System | Ntfs | 55 | Conditionally Repairable | `extras/event_viewer_fixes/Fix-System-Ntfs-55.ps1` |
| System | Ntfs | 98 | Conditionally Repairable | `extras/event_viewer_fixes/Fix-System-Ntfs-98.ps1` |
| System | Ntfs | 140 | Conditionally Repairable | `extras/event_viewer_fixes/Fix-System-Ntfs-140.ps1` |
| System | Service Control Manager | 7000 | Conditionally Repairable | `extras/event_viewer_fixes/Fix-System-Service-Control-Manager-7000.ps1` |
| System | Service Control Manager | 7001 | Conditionally Repairable | `extras/event_viewer_fixes/Fix-System-Service-Control-Manager-7001.ps1` |
| System | Service Control Manager | 7009 | Diagnostic | `extras/event_viewer_fixes/Fix-System-Service-Control-Manager-7009.ps1` |
| System | Service Control Manager | 7011 | Diagnostic | `extras/event_viewer_fixes/Fix-System-Service-Control-Manager-7011.ps1` |
| System | Service Control Manager | 7023 | Conditionally Repairable | `extras/event_viewer_fixes/Fix-System-Service-Control-Manager-7023.ps1` |
| System | Service Control Manager | 7024 | Conditionally Repairable | `extras/event_viewer_fixes/Fix-System-Service-Control-Manager-7024.ps1` |
| System | Service Control Manager | 7030 | Diagnostic | `extras/event_viewer_fixes/Fix-System-Service-Control-Manager-7030.ps1` |
| System | Service Control Manager | 7031 | Conditionally Repairable | `extras/event_viewer_fixes/Fix-System-Service-Control-Manager-7031.ps1` |
| System | Service Control Manager | 7034 | Conditionally Repairable | `extras/event_viewer_fixes/Fix-System-Service-Control-Manager-7034.ps1` |
| System | Service Control Manager | 7045 | Diagnostic | `extras/event_viewer_fixes/Fix-System-Service-Control-Manager-7045.ps1` |
| System | User32 | 1074 | Diagnostic | `extras/event_viewer_fixes/Fix-System-User32-1074.ps1` |
| System | storahci | 129 | Diagnostic | `extras/event_viewer_fixes/Fix-System-storahci-129.ps1` |
| System | stornvme | 129 | Diagnostic | `extras/event_viewer_fixes/Fix-System-stornvme-129.ps1` |

## Safety rules

- Storage scripts never format, initialize, partition, erase volumes, modify RAID, replace drivers from the Internet, or suppress events.
- WHEA scripts report hardware evidence and do not claim fake repair.
- Security scripts collect investigation evidence and do not change passwords, unlock accounts, or clear logs.
- DNS scripts preserve configured DNS servers and do not inject public DNS.
- Service scripts identify the affected service before any targeted start attempt and do not enable every disabled service.
- Power and boot scripts correlate related events and do not reboot automatically.
