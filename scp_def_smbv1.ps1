# Script para ativar o "Suporte a Compartilhamentos de Arquivos SMBv1"
# Cabeçalho
#----------------------------------------------------------------------------------------------
Write-Host "╔" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
write-host "╗" -ForegroundColor Cyan  

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Configurar Serviço") -NoNewline
Write-Host ("{0,-86} " -f "SMB v1") -NoNewline -ForegroundColor Yellow
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
# Obter o status do SMBv1
$featureStatus = Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol

# Verificar se o SMBv1 está habilitado
if ($featureStatus.State -eq 'Enabled') {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " SMB Versão 1") -NoNewline
    Write-Host ("{0,-86} " -f "Já está habilitado") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan
}
else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " SMB Versão 1") -NoNewline
    Write-Host ("{0,-86} " -f "Não está habilitado") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan

    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Tarefa") -NoNewline -ForegroundColor cyan
    Write-Host ("{0,-86} " -f "Habilitar o Serviço") -NoNewline -ForegroundColor cyan
    Write-Host "║" -ForegroundColor Cyan

    Write-Host "║" -NoNewline -ForegroundColor Cyan
    write-host ("═" * 120) -NoNewline -ForegroundColor gray
    Write-Host "║" -ForegroundColor Cyan

    # Habilitar o recurso sem reiniciar e suprimir mensagens de aviso
    $null = Enable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -All -NoRestart 2>&1
    
    # Obter o status do SMBv1
    $featureStatus = Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol

    # Verificar se o SMBv1 está habilitado
    if ($featureStatus.State -eq 'Enabled') {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f " SMB Versão 1") -NoNewline
        Write-Host ("{0,-86} " -f "Habilitado") -NoNewline -ForegroundColor Green
        Write-Host "║" -ForegroundColor Cyan
    }
    else {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f " SMB Versão 1") -NoNewline
        Write-Host ("{0,-86} " -f "Não está habilitado") -NoNewline -ForegroundColor Green
        Write-Host "║" -ForegroundColor Cyan
    }
}

rundll32.exe user32.dll, UpdatePerUserSystemParameters
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
