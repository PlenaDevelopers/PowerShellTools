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
- `extras/`: additional utilities and specialized scripts.
- `optimized_windows7/`: Windows 7 specific maintenance scripts.
- `lib/`: shared helpers.

## Notes

The repository intentionally avoids customer-specific configuration. Use parameters or local copies outside version control when a deployment needs private names, credentials, addresses, or network paths.
## Event Viewer diagnostics

Event Viewer diagnostics are available under `extras/event_viewer_fixes/` as standalone `Fix-*.ps1` files. Each script can be downloaded and run by itself, identifies events by Log, Provider, and Event ID, and performs diagnostics or guarded remediation only when technically appropriate. See `docs/event-viewer-diagnostics.md` and `docs/event-viewer-audit.csv`.
