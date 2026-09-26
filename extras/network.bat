@echo off
title Correcao SMB 0x80004005

echo ============================================================
echo FLEX IT - CORRECAO 0x80004005
echo ============================================================

echo.
echo [1] Removendo conexoes antigas...
net use * /delete /y

echo.
echo [2] Limpando credenciais...
cmdkey /delete:PDV002
cmdkey /delete:192.0.2.10

echo.
echo [3] Ativando SMB1...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$null = Enable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -All -NoRestart -ErrorAction SilentlyContinue"

echo.
echo [4] Ativando Guest Logon...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-SmbClientConfiguration -EnableInsecureGuestLogons $true -Force"

echo.
echo [5] Desativando assinatura SMB...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v RequireSecuritySignature /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v EnableSecuritySignature /t REG_DWORD /d 0 /f

echo.
echo [6] Ajustando politica NTLM...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v LmCompatibilityLevel /t REG_DWORD /d 1 /f

echo.
echo [7] Liberando compartilhamento...
netsh advfirewall firewall set rule group="Compartilhamento de Arquivos e Impressoras" new enable=Yes

echo.
echo ============================================================
echo REINICIE O COMPUTADOR
echo ============================================================
pause
