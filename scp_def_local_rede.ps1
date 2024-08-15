# Script para alterar o "Local da Rede"
# Cabeçalho
#----------------------------------------------------------------------------------------------
Write-Host "╔" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
write-host "╗" -ForegroundColor Cyan  

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Configurar") -NoNewline
Write-Host ("{0,-86} " -f "Local da Rede") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Copyright") -NoNewline
Write-Host ("{0,-86} " -f "2023 - Evandro Campanhã") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Script") -NoNewline
Write-Host ("{0,-86} " -f $MyInvocation.MyCommand.Path) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

Write-Host "╠" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
write-host "╣" -ForegroundColor Cyan
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
# Obter o perfil da conexão de rede
$connectionProfile = Get-NetConnectionProfile

# Verificar o tipo de rede
if ($connectionProfile.NetworkCategory -eq 'Public') {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Tipo de Rede") -NoNewline
    Write-Host ("{0,-86} " -f "Pública") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan
}
elseif ($connectionProfile.NetworkCategory -eq 'Private') {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Tipo de Rede") -NoNewline
    Write-Host ("{0,-86} " -f "Privada") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan
}
else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Tipo de Rede") -NoNewline
    Write-Host ("{0,-86} " -f "Desconhecida") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan
}

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Tarefa") -NoNewline -ForegroundColor cyan
Write-Host ("{0,-86} " -f "Alterar Local da Rede") -NoNewline -ForegroundColor cyan
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor gray
Write-Host "║" -ForegroundColor Cyan

Set-NetConnectionProfile –NetworkCategory Private

# Obter o perfil da conexão de rede
$connectionProfile = Get-NetConnectionProfile

# Verificar o tipo de rede
if ($connectionProfile.NetworkCategory -eq 'Public') {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Tipo de Rede") -NoNewline
    Write-Host ("{0,-86} " -f "Pública") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan
}
elseif ($connectionProfile.NetworkCategory -eq 'Private') {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Tipo de Rede") -NoNewline
    Write-Host ("{0,-86} " -f "Privada") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan
}
else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Tipo de Rede") -NoNewline
    Write-Host ("{0,-86} " -f "Desconhecida") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan
}
#----------------------------------------------------------------------------------------------

# Reiniciar O Windows Explorer
rundll32.exe user32.dll, UpdatePerUserSystemParameters
get-process explorer | Stop-Process -Force
#----------------------------------------------------------------------------------------------

# Rodape
#----------------------------------------------------------------------------------------------
Write-Host "╠" -NoNewline -ForegroundColor Cyan
Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
Write-Host "╣" -ForegroundColor Cyan  

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Processo") -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-86} " -f "Finalizado") -NoNewline -ForegroundColor Cyan
Write-Host "║" -ForegroundColor Cyan

Write-Host "╚" -NoNewline -ForegroundColor Cyan
Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
Write-Host "╝" -ForegroundColor Cyan