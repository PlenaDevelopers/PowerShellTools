# Definindo o intervalo máximo para a barra de progresso
$intervaloMaximo = 100

#Final do Script
Write-Host "╠" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
write-host "╣" -ForegroundColor Cyan  

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Processo")   -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-86} " -f "Reiniciando Computador") -NoNewline -ForegroundColor Cyan
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

Write-Host "╚" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
write-host "╝" -ForegroundColor Cyan 

# Loop para atualizar a barra de progresso
for ($i = 1; $i -le $intervaloMaximo; $i++) {
    # Calcula o percentual completo
    $percentualCompleto = ($i / $intervaloMaximo) * 100

    # Atualiza a barra de progresso
    Write-Progress -Activity "Preparando-se para reiniciar o sistema" -Status "Aguarde..." -PercentComplete $percentualCompleto

    # Aguarda um curto período para simular o processamento
    Start-Sleep -Milliseconds 50
}

# Limpa a barra de progresso ao finalizar
Write-Progress -Activity "Processando" -Status "Concluído" -Completed

Restart-Computer -Force