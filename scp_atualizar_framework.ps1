# Script para atualizar o Net. Framework
# Cabeçalho
#----------------------------------------------------------------------------------------------
Write-Host "╔" -NoNewline -ForegroundColor Cyan
Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
Write-Host "╗" -ForegroundColor Cyan  

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Atualizar") -NoNewline
Write-Host ("{0,-86} " -f "NET Framework") -NoNewline -ForegroundColor Yellow
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
Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
Write-Host "╣" -ForegroundColor Cyan
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
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
Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
Write-Host "╣" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Tarefa") -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-86} " -f "Arquivo") -NoNewline -ForegroundColor Cyan
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("═" * 120) -NoNewline -ForegroundColor Gray
Write-Host "║" -ForegroundColor Cyan

# Framework 3.5
#----------------------------------------------------------------------------------------------
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Instalando") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "NET Framework 3.5") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan

$netFrameworkPath = Join-Path $updatesDirectory "dotnetfx35.exe"

if (Test-Path $netFrameworkPath) {
    Start-Process -FilePath $netFrameworkPath -ArgumentList "/quiet" -Wait
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Aviso") -NoNewline -ForegroundColor Yellow
    Write-Host ("{0,-86} " -f "NET Framework 3.5 não encontrado no diretório.") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
}

# Framework 4.5
#----------------------------------------------------------------------------------------------
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Instalando") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "NET Framework 4.5") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan

$netFrameworkPath = Join-Path $updatesDirectory "Net-Framework 4.5.exe"

if (Test-Path $netFrameworkPath) {
    Start-Process -FilePath $netFrameworkPath -ArgumentList "/quiet" -Wait
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Aviso") -NoNewline -ForegroundColor Yellow
    Write-Host ("{0,-86} " -f "NET Framework 4.5 não encontrado no diretório.") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
}

# Framework 4.6
#----------------------------------------------------------------------------------------------
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Instalando") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "NET Framework 4.6") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan

$netFrameworkPath = Join-Path $updatesDirectory "Net-Framework 4.6.exe"

if (Test-Path $netFrameworkPath) {
    Start-Process -FilePath $netFrameworkPath -ArgumentList "/quiet" -Wait
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Aviso") -NoNewline -ForegroundColor Yellow
    Write-Host ("{0,-86} " -f "NET Framework 4.6 não encontrado no diretório.") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
}

# Framework 4.6.1
#----------------------------------------------------------------------------------------------
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Instalando") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "NET Framework 4.6.1") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan

$netFrameworkPath = Join-Path $updatesDirectory "Net-Framework 4.6.1.exe"

if (Test-Path $netFrameworkPath) {
    Start-Process -FilePath $netFrameworkPath -ArgumentList "/quiet" -Wait
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Aviso") -NoNewline -ForegroundColor Yellow
    Write-Host ("{0,-86} " -f "NET Framework 4.6.1 não encontrado no diretório.") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
}

# Framework 4.7.1
#----------------------------------------------------------------------------------------------
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Instalando") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "NET Framework 4.7.1") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan

$netFrameworkPath = Join-Path $updatesDirectory "Net-Framework 4.7.1.exe"

if (Test-Path $netFrameworkPath) {
    Start-Process -FilePath $netFrameworkPath -ArgumentList "/quiet" -Wait
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Aviso") -NoNewline -ForegroundColor Yellow
    Write-Host ("{0,-86} " -f "NET Framework 4.7.1 não encontrado no diretório.") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
}

# Framework 4.7.2
#----------------------------------------------------------------------------------------------
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Instalando") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "NET Framework 4.7.2") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan

$netFrameworkPath = Join-Path $updatesDirectory "Net-Framework 4.7.2.exe"

if (Test-Path $netFrameworkPath) {
    Start-Process -FilePath $netFrameworkPath -ArgumentList "/quiet" -Wait
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Aviso") -NoNewline -ForegroundColor Yellow
    Write-Host ("{0,-86} " -f "NET Framework 4.7.2 não encontrado no diretório.") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
}

# Framework 4.7.3
#----------------------------------------------------------------------------------------------
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Instalando") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "NET Framework 4.7.3") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan

$netFrameworkPath = Join-Path $updatesDirectory "Net-Framework 4.7.3.exe"

if (Test-Path $netFrameworkPath) {
    Start-Process -FilePath $netFrameworkPath -ArgumentList "/quiet" -Wait
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Aviso") -NoNewline -ForegroundColor Yellow
    Write-Host ("{0,-86} " -f "NET Framework 4.7.3 não encontrado no diretório.") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
}

# Framework 4.8
#----------------------------------------------------------------------------------------------
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Instalando") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "NET Framework 4.8") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan

$netFrameworkPath = Join-Path $updatesDirectory "Net-Framework 4.8.exe"

if (Test-Path $netFrameworkPath) {
    Start-Process -FilePath $netFrameworkPath -ArgumentList "/quiet" -Wait
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Aviso") -NoNewline -ForegroundColor Yellow
    Write-Host ("{0,-86} " -f "NET Framework 4.8 não encontrado no diretório.") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
}

# Framework 4.8.1
#----------------------------------------------------------------------------------------------
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Instalando") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "NET Framework 4.8.1") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan

$netFrameworkPath = Join-Path $updatesDirectory "Net-Framework 4.8.1.exe"

if (Test-Path $netFrameworkPath) {
    Start-Process -FilePath $netFrameworkPath -ArgumentList "/quiet" -Wait
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Aviso") -NoNewline -ForegroundColor Yellow
    Write-Host ("{0,-86} " -f "NET Framework 4.8.1 não encontrado no diretório.") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
}
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