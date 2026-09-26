# Standalone Tool Catalog

These public tools are designed to run from PowerShellTools and also as standalone `.ps1` files downloaded individually from GitHub.

| Tool | Category | Admin | Mode | Purpose |
|---|---|---|---|---|
| `tool_diagnostic_windows_health.ps1` | Windows | No | Read-only | Comprehensive Windows health diagnostic. |
| `tool_repair_windows_system.ps1` | Repair | Yes | Repair | Intelligent Windows system integrity repair. |
| `tool_repair_windows_update.ps1` | Repair | Yes | Repair | Diagnose and repair Windows Update. |
| `tool_diagnostic_pending_reboot.ps1` | Windows | No | Read-only | Detect Windows pending reboot indicators. |
| `tool_diagnostic_bsod.ps1` | Windows | No | Read-only | Analyze available BSOD evidence. |
| `tool_diagnostic_unexpected_shutdown.ps1` | Windows | No | Read-only | Correlate unexpected shutdown evidence. |
| `tool_diagnostic_disk_health.ps1` | Storage | No | Read-only | General disk health diagnostic. |
| `tool_diagnostic_smart.ps1` | Storage | No | Read-only | Analyze SMART information exposed by Windows. |
| `tool_diagnostic_nvme.ps1` | Storage | No | Read-only | NVMe-focused diagnostic. |
| `tool_analyze_disk_space.ps1` | Storage | No | Read-only | Analyze disk-space consumption. |
| `tool_find_large_files.ps1` | Storage | No | Read-only | Find large files safely. |
| `tool_find_duplicate_files.ps1` | Storage | No | Read-only | Find duplicate files safely. |
| `tool_diagnostic_ntfs.ps1` | Storage | No | Read-only | Analyze NTFS health. |
| `tool_diagnostic_vss.ps1` | Storage | No | Read-only | Diagnose Volume Shadow Copy. |
| `tool_diagnostic_network.ps1` | Network | No | Read-only | Comprehensive network diagnostic. |
| `tool_diagnostic_dns.ps1` | Network | No | Read-only | Analyze DNS configuration and resolution. |
| `tool_repair_dns.ps1` | Network | Yes | Repair | Safe DNS remediation. |
| `tool_diagnostic_ip_conflict.ps1` | Network | No | Read-only | Detect evidence of IP conflicts. |
| `tool_diagnostic_internet.ps1` | Network | No | Read-only | Diagnose Internet connectivity path. |
| `tool_diagnostic_wifi.ps1` | Network | No | Read-only | Analyze Wi-Fi state. |
| `tool_monitor_wifi_signal.ps1` | Network | No | Read-only | Monitor Wi-Fi signal over time. |
| `tool_analyze_routes.ps1` | Network | No | Read-only | Analyze Windows routing table. |
| `tool_analyze_open_ports.ps1` | Network | No | Read-only | Display listening ports and responsible processes. |
| `tool_monitor_connections.ps1` | Network | No | Read-only | Monitor active TCP connections. |
| `tool_detect_proxy.ps1` | Network | No | Read-only | Detect Windows proxy configuration. |
| `tool_diagnostic_vpn.ps1` | Network | No | Read-only | Diagnose Windows-native VPN configuration. |
| `tool_diagnostic_smb.ps1` | Network | No | Read-only | Analyze SMB configuration and evidence. |
| `tool_diagnostic_rdp.ps1` | Network | No | Read-only | Analyze Remote Desktop configuration. |
| `tool_diagnostic_firewall.ps1` | Network | No | Read-only | Analyze Windows Firewall. |
| `tool_diagnostic_network_printer.ps1` | Network | No | Read-only | Analyze network printer connectivity. |
| `tool_export_network_configuration.ps1` | Network | No | Read-only | Export network configuration report. |
| `tool_inventory_drivers.ps1` | Hardware | No | Read-only | Inventory installed drivers. |
| `tool_detect_problem_devices.ps1` | Hardware | No | Read-only | Find Device Manager problem devices. |
| `tool_detect_unsigned_drivers.ps1` | Hardware | No | Read-only | Identify unsigned driver conditions. |
| `tool_backup_drivers.ps1` | Hardware | Yes | Repair | Back up third-party Windows drivers. |
| `tool_restore_drivers.ps1` | Hardware | Yes | Repair | Restore drivers from backup. |
| `tool_diagnostic_gpu.ps1` | Hardware | No | Read-only | Analyze GPU and display driver state. |
| `tool_diagnostic_audio.ps1` | Hardware | No | Read-only | Analyze audio device state. |
| `tool_diagnostic_bluetooth.ps1` | Hardware | No | Read-only | Analyze Bluetooth state. |
| `tool_diagnostic_webcam.ps1` | Hardware | No | Read-only | Analyze webcam and camera privacy state. |
| `tool_diagnostic_usb.ps1` | Hardware | No | Read-only | Analyze USB devices and controllers. |
| `tool_report_battery_health.ps1` | Hardware | No | Read-only | Generate battery health information. |
| `tool_inventory_ram.ps1` | Hardware | No | Read-only | Inventory RAM modules. |
| `tool_inventory_cpu.ps1` | Hardware | No | Read-only | Inventory CPU information. |
| `tool_analyze_startup.ps1` | Performance | No | Read-only | Analyze startup applications. |
| `tool_audit_scheduled_tasks.ps1` | Performance | No | Read-only | Audit scheduled tasks. |
| `tool_analyze_processes.ps1` | Performance | No | Read-only | Analyze running processes. |
| `tool_detect_high_cpu.ps1` | Performance | No | Read-only | Detect sustained high CPU processes. |
| `tool_detect_high_memory.ps1` | Performance | No | Read-only | Detect high memory consumers. |
| `tool_find_file_lock.ps1` | Performance | No | Read-only | Find likely process locking a file. |
| `tool_repair_windows_search.ps1` | Windows | Yes | Repair | Diagnose and repair Windows Search. |
| `tool_repair_microsoft_store.ps1` | Windows | Yes | Repair | Repair Microsoft Store infrastructure. |
| `tool_audit_environment_variables.ps1` | User Environment | No | Read-only | Audit environment variables and PATH. |
| `tool_diagnostic_user_profile.ps1` | User Environment | No | Read-only | Analyze Windows user profile health. |
| `tool_detect_temporary_profile.ps1` | User Environment | No | Read-only | Detect temporary profile evidence. |
| `tool_audit_local_users.ps1` | Security | No | Read-only | Audit local accounts. |
| `tool_audit_local_administrators.ps1` | Security | No | Read-only | Audit local Administrators membership. |
| `tool_audit_password_policy.ps1` | Security | No | Read-only | Audit password and lockout policy. |
| `tool_diagnostic_defender.ps1` | Security | No | Read-only | Analyze Microsoft Defender status. |
| `tool_audit_secure_boot_tpm.ps1` | Security | No | Read-only | Audit Secure Boot and TPM. |
| `tool_check_windows11_compatibility.ps1` | Security | No | Read-only | Evaluate Windows 11 compatibility. |
| `tool_report_system_information.ps1` | Support | No | Read-only | Generate comprehensive system report. |
| `tool_collect_support_diagnostics.ps1` | Support | No | Read-only | Collect support diagnostics package. |
| `tool_compare_system_snapshot.ps1` | Support | No | Read-only | Create and compare system snapshots. |
| `tool_analyze_recent_changes.ps1` | Support | No | Read-only | Analyze recent Windows changes timeline. |

## Standalone Use

Download a single script and run it with Windows PowerShell 5.1 or newer:

```powershell
.\tool_diagnostic_windows_health.ps1
```

Read-only tools do not intentionally modify the system. Repair tools perform bounded, evidence-driven remediation and report what they changed.

Diagnostic reports may include technical identifiers such as computer names, usernames, IP addresses, installed software, driver versions, event messages, hardware serials, and domain names. The tools are designed not to collect passwords, browser tokens, private keys, Wi-Fi plaintext passwords, or personal document contents.
