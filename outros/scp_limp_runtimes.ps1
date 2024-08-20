#Script que remove todas as versões do Microsoft Visual Runtimes
Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "Microsoft Visual C++*" } | ForEach-Object { $_.Uninstall() }
