# [Gerenciar Spooler de Impressão]
#----------------------------------------------------------------------------------------------
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Gerenciando Spooler") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "Parando, limpando e reiniciando.") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan

try {
    # Parar o serviço de spooler
    Write-Host "║ Parando o serviço de spooler..." -ForegroundColor Yellow
    Stop-Service -Name Spooler -Force -ErrorAction Stop

    # Caminho da pasta de trabalhos de impressão
    $spoolerPath = Join-Path $env:SystemRoot "System32\spool\PRINTERS"

    # Verificar e limpar a pasta
    if (Test-Path $spoolerPath) {
        Write-Host "║ Limpando trabalhos de impressão..." -ForegroundColor Yellow
        Get-ChildItem -Path $spoolerPath -Recurse | Remove-Item -Force -ErrorAction SilentlyContinue
        Write-Host "║ Trabalhos de impressão removidos com sucesso." -ForegroundColor Green
    } else {
        Write-Host "║ Caminho do spooler não encontrado: $spoolerPath" -ForegroundColor Red
    }

    # Reiniciar o serviço de spooler
    Write-Host "║ Reiniciando o serviço de spooler..." -ForegroundColor Yellow
    Start-Service -Name Spooler -ErrorAction Stop
    Write-Host "║ Serviço de spooler reiniciado com sucesso." -ForegroundColor Green
} catch {
    Write-Host "║ Erro ao gerenciar o spooler: $_" -ForegroundColor Red
}

# Rodapé
Write-Host "║ Operação concluída." -ForegroundColor Cyan
