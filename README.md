# Powershell Tools

Powershell Tools is a generic collection of Windows administration scripts for workstation setup, maintenance, repair, cleanup, networking, Windows installation helpers, and legacy Windows 7 optimization.

## What changed in this migration

- The repository is now the single working folder.
- Script and folder names were converted to English.
- Customer-specific startup scripts were removed.
- A generic workstation setup script replaced the old customer-specific launchers.
- Known customer names, private IP examples, and sample passwords were replaced with generic placeholders.
- Console output now has a shared visual helper in `lib/PowerToolStyle.ps1`.

## Requirements

- Windows 10, Windows 11, or the Windows Server version targeted by the selected script.
- Windows Powershell 5.1 or later.
- Administrator privileges for scripts that change system settings.

## Usage

Run the menu:

```powershell
.\start.ps1
```

Run the generic workstation setup:

```powershell
.\setup_workstation.ps1
```

Some scripts change registry keys, services, firewall rules, shares, Windows setup files, or local policies. Review a script before running it in production.

## Layout

- Root scripts: common maintenance and configuration tasks.
- `extras/`: standalone utilities and specialized troubleshooting scripts.
- `extras/event_viewer_fixes/`: standalone Event Viewer scripts named `Fix-*.ps1`.
- `docs/`: catalogs, audits, and technical documentation.
- `optimized_windows7/`: legacy Windows 7 maintenance scripts.
- `lib/`: shared helpers used by the menu/application layer.

## Repository Tree

Current tracked repository contents: **359 files**, including **335 PowerShell scripts** and **59 standalone Event Viewer scripts**.

<details>
<summary>Open full tree with brief descriptions</summary>

```text
├── docs/ - Documentation, catalogs, and audit tables.
│   ├── event-viewer-audit.csv - Repository file.
│   ├── event-viewer-diagnostics.md - Event Viewer Standalone Diagnostics.
│   ├── standalone-tools-catalog.md - Standalone Tool Catalog.
│   └── tool-expansion-audit.csv - Repository file.
├── extras/ - Standalone utilities and specialized troubleshooting tools discovered by the menu.
│   ├── event_viewer_fixes/ - Standalone Windows Event Viewer diagnostic and repair scripts.
│   │   ├── Fix-Application-Application-Error-1000.ps1 - Fix Application Application Error 1000.
│   │   ├── Fix-Application-Application-Hang-1002.ps1 - Fix Application Application Hang 1002.
│   │   ├── Fix-Application-DotNet-Runtime-1026.ps1 - Fix Application .NET Runtime 1026.
│   │   ├── Fix-Application-MsiInstaller-11707.ps1 - Fix Application MsiInstaller 11707.
│   │   ├── Fix-Application-MsiInstaller-11708.ps1 - Fix Application MsiInstaller 11708.
│   │   ├── Fix-Application-Windows-Error-Reporting-1001.ps1 - Fix Application Windows Error Reporting 1001.
│   │   ├── Fix-Security-Microsoft-Windows-Security-Auditing-1102.ps1 - Fix Security Microsoft-Windows-Security-Auditing 1102.
│   │   ├── Fix-Security-Microsoft-Windows-Security-Auditing-4624.ps1 - Fix Security Microsoft-Windows-Security-Auditing 4624.
│   │   ├── Fix-Security-Microsoft-Windows-Security-Auditing-4625.ps1 - Fix Security Microsoft-Windows-Security-Auditing 4625.
│   │   ├── Fix-Security-Microsoft-Windows-Security-Auditing-4634.ps1 - Fix Security Microsoft-Windows-Security-Auditing 4634.
│   │   ├── Fix-Security-Microsoft-Windows-Security-Auditing-4647.ps1 - Fix Security Microsoft-Windows-Security-Auditing 4647.
│   │   ├── Fix-Security-Microsoft-Windows-Security-Auditing-4648.ps1 - Fix Security Microsoft-Windows-Security-Auditing 4648.
│   │   ├── Fix-Security-Microsoft-Windows-Security-Auditing-4672.ps1 - Fix Security Microsoft-Windows-Security-Auditing 4672.
│   │   ├── Fix-Security-Microsoft-Windows-Security-Auditing-4688.ps1 - Fix Security Microsoft-Windows-Security-Auditing 4688.
│   │   ├── Fix-Security-Microsoft-Windows-Security-Auditing-4720.ps1 - Fix Security Microsoft-Windows-Security-Auditing 4720.
│   │   ├── Fix-Security-Microsoft-Windows-Security-Auditing-4726.ps1 - Fix Security Microsoft-Windows-Security-Auditing 4726.
│   │   ├── Fix-Security-Microsoft-Windows-Security-Auditing-4732.ps1 - Fix Security Microsoft-Windows-Security-Auditing 4732.
│   │   ├── Fix-Security-Microsoft-Windows-Security-Auditing-4733.ps1 - Fix Security Microsoft-Windows-Security-Auditing 4733.
│   │   ├── Fix-Security-Microsoft-Windows-Security-Auditing-4740.ps1 - Fix Security Microsoft-Windows-Security-Auditing 4740.
│   │   ├── Fix-System-Disk-11.ps1 - Fix System Disk 11.
│   │   ├── Fix-System-Disk-15.ps1 - Fix System Disk 15.
│   │   ├── Fix-System-Disk-153.ps1 - Fix System Disk 153.
│   │   ├── Fix-System-Disk-157.ps1 - Fix System Disk 157.
│   │   ├── Fix-System-Disk-51.ps1 - Fix System Disk 51.
│   │   ├── Fix-System-Disk-7.ps1 - Fix System Disk 7.
│   │   ├── Fix-System-Event-243.ps1 - Fix System * 243.
│   │   ├── Fix-System-EventLog-6005.ps1 - Fix System EventLog 6005.
│   │   ├── Fix-System-EventLog-6006.ps1 - Fix System EventLog 6006.
│   │   ├── Fix-System-EventLog-6008.ps1 - Fix System EventLog 6008.
│   │   ├── Fix-System-EventLog-6009.ps1 - Fix System EventLog 6009.
│   │   ├── Fix-System-Microsoft-Windows-DNS-Client-1014.ps1 - Fix System Microsoft-Windows-DNS-Client 1014.
│   │   ├── Fix-System-Microsoft-Windows-DriverFrameworks-UserMode-10110.ps1 - Fix System Microsoft-Windows-DriverFrameworks-UserMode 10110.
│   │   ├── Fix-System-Microsoft-Windows-DriverFrameworks-UserMode-10111.ps1 - Fix System Microsoft-Windows-DriverFrameworks-UserMode 10111.
│   │   ├── Fix-System-Microsoft-Windows-Kernel-General-12.ps1 - Fix System Microsoft-Windows-Kernel-General 12.
│   │   ├── Fix-System-Microsoft-Windows-Kernel-General-13.ps1 - Fix System Microsoft-Windows-Kernel-General 13.
│   │   ├── Fix-System-Microsoft-Windows-Kernel-PnP-219.ps1 - Fix System Microsoft-Windows-Kernel-PnP 219.
│   │   ├── Fix-System-Microsoft-Windows-Kernel-Power-41.ps1 - Fix System Microsoft-Windows-Kernel-Power 41.
│   │   ├── Fix-System-Microsoft-Windows-WER-SystemErrorReporting-1001.ps1 - Fix System Microsoft-Windows-WER-SystemErrorReporting 1001.
│   │   ├── Fix-System-Microsoft-Windows-WHEA-Logger-1.ps1 - Fix System Microsoft-Windows-WHEA-Logger 1.
│   │   ├── Fix-System-Microsoft-Windows-WHEA-Logger-17.ps1 - Fix System Microsoft-Windows-WHEA-Logger 17.
│   │   ├── Fix-System-Microsoft-Windows-WHEA-Logger-18.ps1 - Fix System Microsoft-Windows-WHEA-Logger 18.
│   │   ├── Fix-System-Microsoft-Windows-WHEA-Logger-19.ps1 - Fix System Microsoft-Windows-WHEA-Logger 19.
│   │   ├── Fix-System-Microsoft-Windows-WHEA-Logger-20.ps1 - Fix System Microsoft-Windows-WHEA-Logger 20.
│   │   ├── Fix-System-Ntfs-140.ps1 - Fix System Ntfs 140.
│   │   ├── Fix-System-Ntfs-55.ps1 - Fix System Ntfs 55.
│   │   ├── Fix-System-Ntfs-98.ps1 - Fix System Ntfs 98.
│   │   ├── Fix-System-Service-Control-Manager-7000.ps1 - Fix System Service Control Manager 7000.
│   │   ├── Fix-System-Service-Control-Manager-7001.ps1 - Fix System Service Control Manager 7001.
│   │   ├── Fix-System-Service-Control-Manager-7009.ps1 - Fix System Service Control Manager 7009.
│   │   ├── Fix-System-Service-Control-Manager-7011.ps1 - Fix System Service Control Manager 7011.
│   │   ├── Fix-System-Service-Control-Manager-7023.ps1 - Fix System Service Control Manager 7023.
│   │   ├── Fix-System-Service-Control-Manager-7024.ps1 - Fix System Service Control Manager 7024.
│   │   ├── Fix-System-Service-Control-Manager-7030.ps1 - Fix System Service Control Manager 7030.
│   │   ├── Fix-System-Service-Control-Manager-7031.ps1 - Fix System Service Control Manager 7031.
│   │   ├── Fix-System-Service-Control-Manager-7034.ps1 - Fix System Service Control Manager 7034.
│   │   ├── Fix-System-Service-Control-Manager-7045.ps1 - Fix System Service Control Manager 7045.
│   │   ├── Fix-System-storahci-129.ps1 - Fix System storahci 129.
│   │   ├── Fix-System-stornvme-129.ps1 - Fix System stornvme 129.
│   │   └── Fix-System-User32-1074.ps1 - Fix System User32 1074.
│   ├── resources/ - Theme, appearance, and support resources used by visual tools.
│   │   ├── ease_of_access_themes/ - Ease of Access theme resource files.
│   │   │   ├── hc1.theme - Repository file.
│   │   │   ├── hc2.theme - Repository file.
│   │   │   ├── hcblack.theme - Repository file.
│   │   │   └── hcwhite.theme - Repository file.
│   │   └── themes/ - Windows theme resource files.
│   │       ├── aero/ - Repository subfolder.
│   │       │   ├── pt_br/ - Repository subfolder.
│   │       │   │   ├── aero.msstyles.mui - Repository file.
│   │       │   │   └── aerolite.msstyles.mui - Repository file.
│   │       │   ├── shell/ - Repository subfolder.
│   │       │   │   └── normalcolor/ - Repository subfolder.
│   │       │   │       ├── en_us/ - Repository subfolder.
│   │       │   │       │   └── shellstyle.dll.mui - Repository file.
│   │       │   │       └── shellstyle.dll - Repository file.
│   │       │   ├── aero.msstyles - Repository file.
│   │       │   └── aerolite.msstyles - Repository file.
│   │       ├── aero.theme - Repository file.
│   │       ├── light.theme - Repository file.
│   │       ├── spotlight.theme - Repository file.
│   │       ├── theme1.theme - Repository file.
│   │       └── theme2.theme - Repository file.
│   ├── visual/ - Visual wrappers and guided UI variants for selected tools.
│   │   └── tool_install_windows_10_visual.ps1 - Interface visual isolada para instalar Windows 10 Professional.
│   ├── network.bat - Batch helper for network-related tasks.
│   ├── readme_tool_format_windows_remote.md - Formatacao remota via AnyDesk.
│   ├── tool_activate_office_new.ps1 - Ativar Microsoft Office Novo.
│   ├── tool_activate_windows7.ps1 - Ativar Windows 7.
│   ├── tool_add_bookmark_chrome.ps1 - Adicionar Favorito no Chrome.
│   ├── tool_analyze_disk_space.ps1 - Analyze disk-space consumption.
│   ├── tool_analyze_open_ports.ps1 - Display listening ports and responsible processes.
│   ├── tool_analyze_processes.ps1 - Analyze running processes.
│   ├── tool_analyze_recent_changes.ps1 - Analyze recent Windows changes timeline.
│   ├── tool_analyze_routes.ps1 - Analyze Windows routing table.
│   ├── tool_analyze_startup.ps1 - Analyze startup applications.
│   ├── tool_audit_environment_variables.ps1 - Audit environment variables and PATH.
│   ├── tool_audit_local_administrators.ps1 - Audit local Administrators membership.
│   ├── tool_audit_local_users.ps1 - Audit local accounts.
│   ├── tool_audit_password_policy.ps1 - Audit password and lockout policy.
│   ├── tool_audit_scheduled_tasks.ps1 - Audit scheduled tasks.
│   ├── tool_audit_secure_boot_tpm.ps1 - Audit Secure Boot and TPM.
│   ├── tool_backup_drivers.ps1 - Back up third-party Windows drivers.
│   ├── tool_check_windows11_compatibility.ps1 - Evaluate Windows 11 compatibility.
│   ├── tool_clean_anydesk.ps1 - Limpar AnyDesk.
│   ├── tool_clean_bootmenu_flexit.ps1 - Limpar Boot Menu FlexIT.
│   ├── tool_clean_browser_chrome.ps1 - Limpar Navegacao do Chrome.
│   ├── tool_clean_browser_edge.ps1 - Limpar Navegacao do Edge.
│   ├── tool_clean_browser_explorer.ps1 - Limpar Navegacao do Internet Explorer.
│   ├── tool_clean_browser_firefox.ps1 - Limpar Navegacao do Firefox.
│   ├── tool_clean_chrome.ps1 - Limpar Google Chrome.
│   ├── tool_clean_edge.ps1 - Limpar Microsoft Edge.
│   ├── tool_clean_edge_alternate.ps1 - Limpar Microsoft Edge Alternativo.
│   ├── tool_clean_firefox.ps1 - Limpar Mozilla Firefox.
│   ├── tool_clean_firefox_alternate.ps1 - Limpar Mozilla Firefox Alternativo.
│   ├── tool_clean_java.ps1 - Limpar Java.
│   ├── tool_clean_log_events.ps1 - Limpar Logs de Eventos.
│   ├── tool_clean_office.ps1 - Limpar Microsoft Office.
│   ├── tool_clean_onedrive.ps1 - Limpar OneDrive.
│   ├── tool_clean_recycle_bin.ps1 - Limpar Lixeira.
│   ├── tool_clean_recycle_bin_alternate.ps1 - Limpar Lixeira Alternativo.
│   ├── tool_clean_runtimes.ps1 - Limpar Runtimes.
│   ├── tool_clean_spooler.ps1 - Limpar Spooler de Impressao.
│   ├── tool_collect_support_diagnostics.ps1 - Collect support diagnostics package.
│   ├── tool_compare_system_snapshot.ps1 - Create and compare system snapshots.
│   ├── tool_configure_acesso_remote_windows_10.ps1 - Configurar Access Remoto Windows 10.
│   ├── tool_connect_iscsi.ps1 - Conectar iSCSI.
│   ├── tool_convert_image.ps1 - Converter Imagem.
│   ├── tool_convert_image_batch.ps1 - Converter Imagens em Lote.
│   ├── tool_create_folder.ps1 - Criar Folder.
│   ├── tool_create_folder_batch.ps1 - Criar Folders em Lote.
│   ├── tool_create_folder_god_mode.ps1 - Criar Folder God Mode.
│   ├── tool_create_users_batch.ps1 - Criar Usuarios em Lote.
│   ├── tool_delete_files_desktop.ps1 - Apagar Arquivos da Area de Trabalho.
│   ├── tool_delete_files_windows.ps1 - Apagar Arquivos do Windows.
│   ├── tool_desktop_bloquear_alteracoes.ps1 - Bloquear Alteracoes da Area de Trabalho.
│   ├── tool_detect_high_cpu.ps1 - Detect sustained high CPU processes.
│   ├── tool_detect_high_memory.ps1 - Detect high memory consumers.
│   ├── tool_detect_problem_devices.ps1 - Find Device Manager problem devices.
│   ├── tool_detect_proxy.ps1 - Detect Windows proxy configuration.
│   ├── tool_detect_temporary_profile.ps1 - Detect temporary profile evidence.
│   ├── tool_detect_unsigned_drivers.ps1 - Identify unsigned driver conditions.
│   ├── tool_diagnostic_audio.ps1 - Analyze audio device state.
│   ├── tool_diagnostic_bluetooth.ps1 - Analyze Bluetooth state.
│   ├── tool_diagnostic_bsod.ps1 - Analyze available BSOD evidence.
│   ├── tool_diagnostic_defender.ps1 - Analyze Microsoft Defender status.
│   ├── tool_diagnostic_disk_health.ps1 - General disk health diagnostic.
│   ├── tool_diagnostic_dns.ps1 - Analyze DNS configuration and resolution.
│   ├── tool_diagnostic_firewall.ps1 - Analyze Windows Firewall.
│   ├── tool_diagnostic_gpu.ps1 - Analyze GPU and display driver state.
│   ├── tool_diagnostic_internet.ps1 - Diagnose Internet connectivity path.
│   ├── tool_diagnostic_ip_conflict.ps1 - Detect evidence of IP conflicts.
│   ├── tool_diagnostic_network.ps1 - Comprehensive network diagnostic.
│   ├── tool_diagnostic_network_printer.ps1 - Analyze network printer connectivity.
│   ├── tool_diagnostic_ntfs.ps1 - Analyze NTFS health.
│   ├── tool_diagnostic_nvme.ps1 - NVMe-focused diagnostic.
│   ├── tool_diagnostic_pending_reboot.ps1 - Detect Windows pending reboot indicators.
│   ├── tool_diagnostic_rdp.ps1 - Analyze Remote Desktop configuration.
│   ├── tool_diagnostic_smart.ps1 - Analyze SMART information exposed by Windows.
│   ├── tool_diagnostic_smb.ps1 - Analyze SMB configuration and evidence.
│   ├── tool_diagnostic_unexpected_shutdown.ps1 - Correlate unexpected shutdown evidence.
│   ├── tool_diagnostic_usb.ps1 - Analyze USB devices and controllers.
│   ├── tool_diagnostic_user_profile.ps1 - Analyze Windows user profile health.
│   ├── tool_diagnostic_vpn.ps1 - Diagnose Windows-native VPN configuration.
│   ├── tool_diagnostic_vss.ps1 - Diagnose Volume Shadow Copy.
│   ├── tool_diagnostic_webcam.ps1 - Analyze webcam and camera privacy state.
│   ├── tool_diagnostic_wifi.ps1 - Analyze Wi-Fi state.
│   ├── tool_diagnostic_windows_health.ps1 - Comprehensive Windows health diagnostic.
│   ├── tool_disable_creative_cloud.ps1 - Desabilitar Adobe Creative Cloud.
│   ├── tool_disable_office_click.ps1 - Desabilitar Office Click To Run.
│   ├── tool_disconnect_users.ps1 - Desconectar Usuarios.
│   ├── tool_enable_microsoft_edge_lite.ps1 - Habilitar Microsoft Edge Lite.
│   ├── tool_enable_snmp.ps1 - Habilitar SNMP.
│   ├── tool_enable_snmp_alternate.ps1 - Habilitar SNMP Alternativo.
│   ├── tool_enable_windows_defender.ps1 - Habilitar Windows Defender.
│   ├── tool_export_drivers.ps1 - Exportar Drivers.
│   ├── tool_export_network_configuration.ps1 - Export network configuration report.
│   ├── tool_find_duplicate_files.ps1 - Find duplicate files safely.
│   ├── tool_find_file_lock.ps1 - Find likely process locking a file.
│   ├── tool_find_large_files.ps1 - Find large files safely.
│   ├── tool_firewall_firebird.ps1 - Criar Regra de Firewall do Firebird.
│   ├── tool_firewall_firebird_alternate.ps1 - Criar Regra de Firewall do Firebird Alternativa.
│   ├── tool_fix_erro_8194.ps1 - Corrigir Erro 8194.
│   ├── tool_fix_event_dcom.ps1 - Corrigir Evento DCOM.
│   ├── tool_format_windows_remote.ps1 - Preparar Formatacao Remota do Windows.
│   ├── tool_install_7zip.ps1 - Instalar 7-Zip.
│   ├── tool_install_anydesk.ps1 - Instalar AnyDesk.
│   ├── tool_install_app.ps1 - Instalar Aplicativo.
│   ├── tool_install_chrome.ps1 - Instalar Google Chrome.
│   ├── tool_install_client_ssh_windows_10.ps1 - Instalar Cliente SSH no Windows 10.
│   ├── tool_install_client_ssh_windows_2012.ps1 - Instalar Cliente SSH no Windows Server 2012.
│   ├── tool_install_directx.ps1 - Instalar DirectX.
│   ├── tool_install_fonts.ps1 - Instalar Fontes.
│   ├── tool_install_gdrive.ps1 - Instalar Google Drive.
│   ├── tool_install_onedrive.ps1 - Instalar OneDrive.
│   ├── tool_install_skype.ps1 - Instalar Skype.
│   ├── tool_install_teams.ps1 - Instalar Microsoft Teams.
│   ├── tool_install_windows_10.ps1 - Instalar Windows 10 Professional.
│   ├── tool_install_windows_11.ps1 - Instalar Windows 11 Professional.
│   ├── tool_install_windows_7.ps1 - Instalar Windows 7 Professional.
│   ├── tool_install_windows_server_2016.ps1 - Instalar Windows Server 2016 Standard.
│   ├── tool_install_windows_server_2019.ps1 - Instalar Windows Server 2019 Standard.
│   ├── tool_install_windows_server_2022.ps1 - Instalar Windows Server 2022 Standard.
│   ├── tool_install_windows_server_2025.ps1 - Instalar Windows Server 2025 Standard.
│   ├── tool_install_zoom.ps1 - Instalar Zoom.
│   ├── tool_inventory_cpu.ps1 - Inventory CPU information.
│   ├── tool_inventory_drivers.ps1 - Inventory installed drivers.
│   ├── tool_inventory_ram.ps1 - Inventory RAM modules.
│   ├── tool_list_editions_iso_windows.ps1 - Listar edicoes disponiveis em uma ISO do Windows.
│   ├── tool_list_wifi.ps1 - Listar Redes Wi-Fi.
│   ├── tool_monitor_connections.ps1 - Monitor active TCP connections.
│   ├── tool_monitor_wifi_signal.ps1 - Monitor Wi-Fi signal over time.
│   ├── tool_open_chrome_kiosk.ps1 - Abrir Chrome em Modo Kiosk.
│   ├── tool_open_explorer_simple.ps1 - Abrir Explorer Simples.
│   ├── tool_open_manager_certificates.ps1 - Abrir Gerenciador de Certificados.
│   ├── tool_open_manager_devices.ps1 - Abrir Gerenciador de Dispositivos.
│   ├── tool_open_manager_disks.ps1 - Abrir Gerenciador de Discos.
│   ├── tool_open_manager_events.ps1 - Abrir Gerenciador de Eventos.
│   ├── tool_open_manager_services.ps1 - Abrir Gerenciador de Servicos.
│   ├── tool_open_manager_users.ps1 - Abrir Gerenciador de Usuarios.
│   ├── tool_optimize_tcp.ps1 - Otimizar TCP.
│   ├── tool_optimize_tcp_alternate.ps1 - This Script desuboptimize a lot W10 & W11 TCP Settings.
│   ├── tool_organize_files.ps1 - Organizar Arquivos.
│   ├── tool_port_forwarding_upnp.ps1 - Configurar Redirecionamento UPnP.
│   ├── tool_process_create.ps1 - Gerar Relatorio de Processs.
│   ├── tool_process_stop.ps1 - Encerrar Process.
│   ├── tool_query_serial_oem_windows.ps1 - Exibir Serial OEM do Windows.
│   ├── tool_query_serial_windows.ps1 - Exibir Serial do Windows.
│   ├── tool_registry_backup.ps1 - Criar Backup do Registro.
│   ├── tool_remove_bloatware.ps1 - Remover Bloatware.
│   ├── tool_remove_mappings.ps1 - Remover Mapeamentos.
│   ├── tool_remove_printers.ps1 - Remover Impressoras.
│   ├── tool_remove_shares.ps1 - Remover Compartilhamentos.
│   ├── tool_remove_skype.ps1 - Remover Skype.
│   ├── tool_remove_tiles_live.ps1 - Remover Blocos Dinamicos.
│   ├── tool_rename_files_batch.ps1 - Renomear Arquivos em Lote.
│   ├── tool_repair_desktop.ps1 - Reparar Area de Trabalho.
│   ├── tool_repair_desktop_icones.ps1 - Reparar Icones da Area de Trabalho.
│   ├── tool_repair_dns.ps1 - Safe DNS remediation.
│   ├── tool_repair_menu_start.ps1 - Reparar Menu Iniciar.
│   ├── tool_repair_microsoft_store.ps1 - Repair Microsoft Store infrastructure.
│   ├── tool_repair_rdp_server.ps1 - Reparar Servidor RDP.
│   ├── tool_repair_windows.ps1 - Reparar Windows.
│   ├── tool_repair_windows_alternate.ps1 - Reparar Windows Alternativo.
│   ├── tool_repair_windows_search.ps1 - Diagnose and repair Windows Search.
│   ├── tool_repair_windows_system.ps1 - Intelligent Windows system integrity repair.
│   ├── tool_repair_windows_update.ps1 - Diagnose and repair Windows Update.
│   ├── tool_report_battery_health.ps1 - Generate battery health information.
│   ├── tool_report_system_information.ps1 - Generate comprehensive system report.
│   ├── tool_restart_bios.ps1 - Reiniciar na BIOS.
│   ├── tool_restart_computer.ps1 - Reiniciar Computador.
│   ├── tool_restore_appearance.ps1 - Restaurar Aparencia.
│   ├── tool_restore_appearance_alternate.ps1 - Restaurar Aparencia Alternativo.
│   ├── tool_restore_browsers.ps1 - Restaurar Navegadores.
│   ├── tool_restore_drivers.ps1 - Restore drivers from backup.
│   ├── tool_run_command_ssh.ps1 - Executar Comando SSH.
│   ├── tool_scanner_network.ps1 - Escanear Rede.
│   ├── tool_scanner_ports.ps1 - Escanear Portas.
│   ├── tool_search_registry_windows.ps1 - Pesquisar Registro do Windows.
│   ├── tool_set_autologin.ps1 - Configurar Login Automatico.
│   ├── tool_set_color_destaque.ps1 - Definir Cor de Destaque.
│   ├── tool_set_cortana.ps1 - Configurar Cortana.
│   ├── tool_set_desktop_auto_arrange.ps1 - Definir Auto Organizacao da Area de Trabalho.
│   ├── tool_set_dns_sql.ps1 - Definir DNS SQL.
│   ├── tool_set_drive_primary_name.ps1 - Definir Nome do Disco Primario.
│   ├── tool_set_drive_primary_paging.ps1 - Definir Paginacao do Disco Primario.
│   ├── tool_set_drive_secondary_name.ps1 - Definir Nome do Disco Secundario.
│   ├── tool_set_drive_secondary_paging.ps1 - Definir Paginacao do Disco Secundario.
│   ├── tool_set_edge_modo_ie.ps1 - Configurar Modo IE no Microsoft Edge.
│   ├── tool_set_escala_dpi.ps1 - Definir Escala DPI.
│   ├── tool_set_firewall_rule.ps1 - Criar Regra de Firewall.
│   ├── tool_set_gamedvr.ps1 - Configurar Game DVR.
│   ├── tool_set_history_atividade.ps1 - Configurar Historico de Atividade.
│   ├── tool_set_logon_automatico.ps1 - Configurar Logon Automatico.
│   ├── tool_set_menu_start.ps1 - Definir Menu Iniciar.
│   ├── tool_set_office_click_to_run.ps1 - Configurar Office Click To Run.
│   ├── tool_set_plan_background.ps1 - Definir Plano de Fundo.
│   ├── tool_set_rule_firewall.ps1 - Criar Regra de Firewall.
│   ├── tool_set_security_network_lanmanager.ps1 - Configurar Seguranca de Rede Lan Manager.
│   ├── tool_set_sense_storage.ps1 - Configurar Sensor de Armazenamento.
│   ├── tool_set_sense_wifi.ps1 - Configurar Sensor Wi-Fi.
│   ├── tool_set_share_windows_10.ps1 - Definir Compartilhamento Windows 10.
│   ├── tool_set_share_windows_11.ps1 - Definir Compartilhamento Windows 11.
│   ├── tool_set_share_windows_server.ps1 - Definir Compartilhamento Windows Server.
│   ├── tool_set_telemetry.ps1 - Configurar Telemetria.
│   ├── tool_set_teredo.ps1 - Configurar Teredo.
│   ├── tool_set_theme_dark.ps1 - Definir Tema Escuro.
│   ├── tool_set_theme_dark_alternate.ps1 - Definir Tema Escuro Alternativo.
│   ├── tool_set_theme_default.ps1 - Definir Tema Padrao.
│   ├── tool_set_theme_default_alternate.ps1 - Definir Tema Padrao Alternativo.
│   ├── tool_set_tracking_location.ps1 - Configurar Rastreamento de Localizacao.
│   ├── tool_set_user_descricao.ps1 - Definir Descricao do Usuario.
│   ├── tool_set_user_name.ps1 - Definir Nome do Usuario.
│   ├── tool_set_volume.ps1 - Definir Volume.
│   ├── tool_set_windows_defender.ps1 - Configurar Windows Defender.
│   ├── tool_set_windows_update.ps1 - Configurar Windows Update.
│   ├── tool_size_folders.ps1 - Calcular Tamanho de Folders.
│   ├── tool_template_footer_visual.ps1 - Modelo de Rodape Visual.
│   ├── tool_template_footer_visual_alternate_raiz.ps1 - Modelo de Rodape Visual Alternativo.
│   ├── tool_template_header_visual.ps1 - Modelo de Header Visual.
│   ├── tool_template_header_visual_alternate_raiz.ps1 - Modelo de Header Visual Alternativo.
│   ├── tool_unlock.ps1 - Desbloquear Arquivos.
│   ├── tool_update_drivers.ps1 - Atualizar Drivers.
│   ├── tool_update_drivers_wupdate.ps1 - Atualizar Drivers pelo Windows Update.
│   ├── tool_update_powershell.ps1 - Atualizar Powershell.
│   └── tool_wifi_saved.ps1 - Listar Wi-Fi Salvos.
├── lib/ - Shared helpers used by the PowerShellTools application.
│   └── PowerToolStyle.ps1 - Powertoolstyle.
├── optimized_windows7/ - Legacy Windows 7 optimization and maintenance scripts.
│   ├── lib_win7.ps1 - Biblioteca Windows 7.
│   ├── readme.txt - Plain-text notes or legacy documentation.
│   ├── start_windows7_otimizado.ps1 - Iniciar Windows 7 Otimizado.
│   ├── tool_win7_install_chrome.ps1 - Windows 7 Instalar Chrome.
│   ├── tool_win7_limpeza_rapida.ps1 - Windows 7 Limpeza Rapida.
│   ├── tool_win7_network_tcp.ps1 - Windows 7 Otimizar Rede TCP.
│   ├── tool_win7_power_desempenho.ps1 - Windows 7 Energia e Desempenho.
│   ├── tool_win7_repair_sistema.ps1 - Windows 7 Reparar Sistema.
│   ├── tool_win7_reverter_default.ps1 - Windows 7 Reverter Padrao.
│   ├── tool_win7_services_rapidos.ps1 - Windows 7 Servicos Rapidos.
│   └── tool_win7_visual_desempenho.ps1 - Windows 7 Visual e Desempenho.
├── README.md - Main GitHub description, usage notes, and repository map.
├── setup_workstation.ps1 - Generic workstation setup orchestrator.
├── start.bat - Batch launcher for the main PowerShell menu.
├── start.ps1 - Main PowerShellTools menu launcher.
├── tool_activate_office.ps1 - Ativar Microsoft Office.
├── tool_activate_windows.ps1 - Ativar Windows.
├── tool_remove_app.ps1 - Remover Aplicativos Pre Instalados.
├── tool_remove_files_temporary.ps1 - Clean temporary files.
├── tool_remove_history_theme.ps1 - Remover Historico de Cores do Windows.
├── tool_remove_tiles_live.ps1 - Remover Blocos Dinamicos do Menu Iniciar.
├── tool_repair_bug_printer_1.ps1 - Corrigir Bug 0x0000011b de Impressoras.
├── tool_repair_desktop.ps1 - Reparar Area de Trabalho.
├── tool_repair_encryption_credssp.ps1 - Reparar Criptografia CredSSP.
├── tool_repair_logons_insecure.ps1 - Configurar Logons Inseguros.
├── tool_restore_colors_theme.ps1 - Restaurar Cores do Tema do Windows.
├── tool_restore_wallpaper_theme.ps1 - Restaurar Wallpaper Padrao do Windows.
├── tool_set_anydesk_password.ps1 - Definir Senha do AnyDesk.
├── tool_set_background_logon.ps1 - Definir Fundo da Tela de Logon.
├── tool_set_computer_name.ps1 - Definir Nome do Computador.
├── tool_set_desktop_auto_arrange.ps1 - Definir Auto Organizacao da Area de Trabalho.
├── tool_set_desktop_background.ps1 - Definir Fundo da Area de Trabalho.
├── tool_set_desktop_color.ps1 - Definir Cor da Area de Trabalho.
├── tool_set_desktop_version.ps1 - Exibir Versao do Windows na Area de Trabalho.
├── tool_set_file_rdp.ps1 - Criar Arquivo de Conexao RDP.
├── tool_set_files_extensoes.ps1 - Exibir Extensoes de Arquivos.
├── tool_set_location_network.ps1 - Definir Local da Rede.
├── tool_set_name_drive_c.ps1 - Definir Nome do Disco C.
├── tool_set_name_drive_d.ps1 - Definir Nome do Disco D.
├── tool_set_plan_power.ps1 - Definir Plano de Energia.
├── tool_set_protocol_dhcp.ps1 - Habilitar Protocolo DHCP.
├── tool_set_protocol_ipv6.ps1 - Configurar Protocolo IPv6.
├── tool_set_server_ntp.ps1 - Set NTP server.
├── tool_set_service_link_tracking.ps1 - Configurar Servico Link Distribuido.
├── tool_set_service_registry_remote.ps1 - Configurar Servico Registro Remoto.
├── tool_set_service_spooler.ps1 - Configurar Servico Spooler de Impressao.
├── tool_set_service_themes.ps1 - Configurar Servico Temas.
├── tool_set_share.ps1 - Configurar Compartilhamento de Rede.
├── tool_set_smbv1.ps1 - Configurar Suporte SMBv1.
├── tool_set_support.ps1 - Definir Informacoes de Suporte.
├── tool_set_taskbar_news.ps1 - Configurar Noticias e Interesses da Barra de Tasks.
├── tool_set_taskbar_search.ps1 - Configurar Pesquisa da Barra de Tasks.
├── tool_set_user_name.ps1 - Definir Nome do Usuario.
├── tool_set_viewer_images.ps1 - Habilitar Visualizador Classico de Imagens.
├── tool_start_backup.ps1 - Iniciar System backup.
├── tool_update_framework.ps1 - Atualizar Microsoft .NET Framework.
├── tool_update_runtime.ps1 - Atualizar Microsoft Visual C Runtimes.
└── tool_update_script.ps1 - Atualizar PowerTool.
```

</details>


## Notes

The repository intentionally avoids customer-specific configuration. Use parameters or local copies outside version control when a deployment needs private names, credentials, addresses, or network paths.
## Event Viewer diagnostics

Event Viewer diagnostics are available under `extras/event_viewer_fixes/` as standalone `Fix-*.ps1` files. Each script can be downloaded and run by itself, identifies events by Log, Provider, and Event ID, and performs diagnostics or guarded remediation only when technically appropriate. See `docs/event-viewer-diagnostics.md` and `docs/event-viewer-audit.csv`.

## Standalone tool library

PowerShellTools includes a standalone Windows troubleshooting library under `extras/`. These scripts can be launched from the PowerShellTools menu or downloaded individually from GitHub and run by themselves. See `docs/standalone-tools-catalog.md` and `docs/tool-expansion-audit.csv` for the full catalog, administrator requirements, and read-only/repair status.
