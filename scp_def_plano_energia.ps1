Write-Host "╔" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
write-host "╗" -ForegroundColor Cyan  

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Operação") -NoNewline
Write-Host ("{0,-86} " -f "Alterar plano de energia") -NoNewline -ForegroundColor Yellow
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

# Define a política de suspensão para "Nunca"
powercfg /change standby-timeout-ac 0
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Suspender PC") -NoNewline -ForegroundColor White
    Write-Host ("{0,-86} " -f "Nunca") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan

# Define a política de suspensão para "Nunca" quando estiver usando bateria
powercfg /change standby-timeout-dc 0
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Suspender PC (Bateria)") -NoNewline -ForegroundColor White
    Write-Host ("{0,-86} " -f "Nunca") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan

# Desativa o desligamento do monitor ao usar energia AC
powercfg /change monitor-timeout-ac 0
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Desligar Monitor") -NoNewline -ForegroundColor White
    Write-Host ("{0,-86} " -f "Nunca") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan

# Desativa o desligamento do monitor ao usar bateria
powercfg /change monitor-timeout-dc 0
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Desligar Monitor (Bateria)") -NoNewline -ForegroundColor White
    Write-Host ("{0,-86} " -f "Nunca") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan

rundll32.exe user32.dll, UpdatePerUserSystemParameters

#Final do Script
Write-Host "╠" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
write-host "╣" -ForegroundColor Cyan  

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Processo")   -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-86} " -f "Finalizado") -NoNewline -ForegroundColor Cyan
Write-Host "║" -ForegroundColor Cyan

Write-Host "╚" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
write-host "╝" -ForegroundColor Cyan 