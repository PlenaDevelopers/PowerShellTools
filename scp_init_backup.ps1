# Cabeçalho
#----------------------------------------------------------------------------------------------
Write-Host "╔" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
write-host "╗" -ForegroundColor Cyan  

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Backup") -NoNewline
Write-Host ("{0,-86} " -f "Fazer Backup do Windows") -NoNewline -ForegroundColor Yellow
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

# Obtém a data e hora atual
$dataHoraAtual = Get-Date -Format "dd/MM/yyyy-HH:mm:ss"

# Define a descrição para o ponto de restauração
$descricaoPontoRestauracao = "$dataHoraAtual - Ponto de Restauração by Plena Souções"

function Test-ServiceExists {
    param (
        [string]$serviceName
    )

    try {
        $service = Get-Service -Name $serviceName -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

# Exemplo de uso:
$serviceName = "srservice"  # Substitua pelo nome do serviço desejado
if (Test-ServiceExists -serviceName $serviceName) {
    # Tenta criar um ponto de restauração do sistema
    try {
        $null = Checkpoint-Computer -Description $descricaoPontoRestauracao -RestorePointType "MODIFY_SETTINGS"
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f " Tarefa") -NoNewline -ForegroundColor White
        Write-Host ("{0,-86} " -f "Ponto de Restauração criado com sucesso") -NoNewline -ForegroundColor Green
        Write-Host "║" -ForegroundColor Cyan
        }
        catch {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f " Erro") -NoNewline -ForegroundColor Red
        Write-Host ("{0,-86} " -f "Erro ao criar ponto de restauração: $_") -NoNewline -ForegroundColor Red
        Write-Host "║" -ForegroundColor Cyan
        }
} else {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f " Erro") -NoNewline -ForegroundColor Red
        Write-Host ("{0,-86} " -f "O serviço $serviceName não existe.") -NoNewline -ForegroundColor Red
        Write-Host "║" -ForegroundColor Cyan
}

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