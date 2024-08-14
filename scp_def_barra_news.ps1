# Defina os valores do Registro
$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds"
$regName = "ShellFeedsTaskbarViewMode"
$regValue = 2  # 2 para desativar

# Início do Script
Write-Host "╔" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
write-host "╗" -ForegroundColor Cyan  

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Definir") -NoNewline
Write-Host ("{0,-86} " -f "Barra de News") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Yellow
Write-Host ("{0,-30} : " -f " Copyright") -NoNewline
Write-Host ("{0,-86} " -f "2023 - Evandro Campanhã") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Yellow

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Script") -NoNewline
Write-Host ("{0,-86} " -f $MyInvocation.MyCommand.Path) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

Write-Host "╠" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
write-host "╣" -ForegroundColor Cyan

# Verifica se o caminho do Registro existe
if (Test-Path $regPath) {
    # Define o valor no Registro
    Set-ItemProperty -Path $regPath -Name $regName -Value $regValue
    
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Definindo") -NoNewline -ForegroundColor Red
    Write-Host ("{0,-86} " -f "$regName = $regValue") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Erro") -NoNewline -ForegroundColor Red
    Write-Host ("{0,-86} " -f "Caminho do Registro não encontrado: $regPath") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
}

# Atualiza as configurações para refletir as mudanças
rundll32.exe user32.dll, UpdatePerUserSystemParameters

# Opcional: Reiniciar o processo do Windows Explorer
Stop-Process -Name explorer -Force
Start-Sleep -Seconds 2

# Final do Script
Write-Host "╠" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
write-host "╣" -ForegroundColor Cyan  

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Processo") -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-86} " -f "Finalizado") -NoNewline -ForegroundColor Cyan
Write-Host "║" -ForegroundColor Cyan

Write-Host "╚" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
write-host "╝" -ForegroundColor Cyan 
