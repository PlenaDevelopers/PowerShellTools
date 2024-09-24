# Script PowerShell para reiniciar o sistema e entrar no BIOS/UEFI
#-------------------------------------------------------------

Write-Host "Reiniciando o sistema e entrando na configuração de BIOS/UEFI..." -ForegroundColor Cyan

# Executa o comando de shutdown com parâmetros para reiniciar e entrar no firmware
shutdown /r /fw /t 1

Write-Host "O sistema será reiniciado em 1 segundo..." -ForegroundColor Green

#-------------------------------------------------------------
