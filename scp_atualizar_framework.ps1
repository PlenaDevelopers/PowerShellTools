Write-Host "╔" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
write-host "╗" -ForegroundColor Cyan  
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Atualizar") -NoNewline
Write-Host ("{0,-86} " -f "NET Framework") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Yellow
Write-Host ("{0,-30} : " -f " Copyright") -NoNewline
Write-Host ("{0,-86} " -f "2023 - Evandro Campanhã") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Yellow

$computerName = (Get-ComputerInfo).CsName
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Computador") -NoNewline
Write-Host ("{0,-86} " -f $computerName) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Script") -NoNewline
Write-Host ("{0,-86} " -f $MyInvocation.MyCommand.Path) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

Write-Host "╠" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
write-host "╣" -ForegroundColor Cyan

# Obtém o diretório atual do script
$currentScriptDirectory = $PSScriptRoot
# Adiciona o subdiretório "updates"
$updatesDirectory = Join-Path $currentScriptDirectory "updates\framework"
# Se precisar do caminho completo do script
$currentScriptPath = $MyInvocation.MyCommand.Path

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Diretorio das Atualizações") -NoNewline
Write-Host ("{0,-86} " -f $updatesDirectory) -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan
Write-Host "╠" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
write-host "╣" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Tarefa") -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-86} " -f "Arquivo") -NoNewline -ForegroundColor Cyan
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor White
write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Instalando") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "NET Framework 3.5") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan
Start-Process -FilePath $updatesDirectory\"dotnetfx35.exe" -ArgumentList "/quiet" -Wait

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Instalando") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "NET Framework 4.5") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan
Start-Process -FilePath $updatesDirectory\"Net-Framework 4.5.exe" -ArgumentList "/quiet" -Wait

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Instalando") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "NET Framework 4.6") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan
Start-Process -FilePath $updatesDirectory\"Net-Framework 4.6.exe" -ArgumentList "/quiet" -Wait

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Instalando") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "NET Framework 4.6.1") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan
Start-Process -FilePath $updatesDirectory\"Net-Framework 4.6.1.exe" -ArgumentList "/quiet" -Wait

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Instalando") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "NET Framework 4.7.1") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan
Start-Process -FilePath $updatesDirectory\"Net-Framework 4.7.1.exe" -ArgumentList "/quiet" -Wait

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Instalando") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "NET Framework 4.7.2") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan
Start-Process -FilePath $updatesDirectory\"Net-Framework 4.7.2.exe" -ArgumentList "/quiet" -Wait

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Instalando") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "NET Framework 4.7.3") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan
Start-Process -FilePath $updatesDirectory\"Net-Framework 4.7.3.exe" -ArgumentList "/quiet" -Wait

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Instalando") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "NET Framework 4.8") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan
Start-Process -FilePath $updatesDirectory\"Net-Framework 4.8.exe" -ArgumentList "/quiet" -Wait

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Instalando") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "NET Framework 4.8.1") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan
Start-Process -FilePath $updatesDirectory\"Net-Framework 4.8.1.exe" -ArgumentList "/quiet" -Wait

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