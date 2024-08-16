# Script para atualizar o Net. Framework
# Cabeçalho
#----------------------------------------------------------------------------------------------
Write-Host "╔" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
write-host "╗" -ForegroundColor Cyan  

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Atualizar") -NoNewline
Write-Host ("{0,-86} " -f "Visual C+ Runtimes") -NoNewline -ForegroundColor Yellow
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
# Obtém o diretório atual do script
$currentScriptDirectory = $PSScriptRoot
# Adiciona o subdiretório "updates"
$updatesDirectory = Join-Path $currentScriptDirectory "updates\visual_runtimes"
# Se precisar do caminho completo do script
$currentScriptPath = $MyInvocation.MyCommand.Path

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Diretorio das Atualizações") -NoNewline
Write-Host ("{0,-86} "   -f $updatesDirectory) -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan
Write-Host "╠" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
write-host "╣" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Tarefa") -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-86} "   -f "Arquivo") -NoNewline -ForegroundColor Cyan
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor White
write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
Write-Host "║" -ForegroundColor Cyan

# Visual C 2005
#----------------------------------------------------------------------------------------------
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Instalando") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "Visual C 2005") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan

$vcredist2005Path = Join-Path $updatesDirectory "vcredist2005_x64.exe"

if (Test-Path $vcredist2005Path) {
    Start-Process -FilePath $vcredist2005Path -ArgumentList "/q" -Wait
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Aviso") -NoNewline -ForegroundColor Yellow
    Write-Host ("{0,-86} " -f "Visual C 2005 não encontrado no diretório.") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
}

# Visual C 2008
#----------------------------------------------------------------------------------------------
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Instalando") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "Visual C 2008") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan

$vcredist2008Path = Join-Path $updatesDirectory "vcredist2008_x64.exe"

if (Test-Path $vcredist2008Path) {
    Start-Process -FilePath $vcredist2008Path -ArgumentList "/q" -Wait
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Aviso") -NoNewline -ForegroundColor Yellow
    Write-Host ("{0,-86} " -f "Visual C 2008 não encontrado no diretório.") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
}

# Visual C 2010
#----------------------------------------------------------------------------------------------
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Instalando") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "Visual C 2010") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan

$vcredist2010Path = Join-Path $updatesDirectory "vcredist2010_x64.exe"

if (Test-Path $vcredist2010Path) {
    Start-Process -FilePath $vcredist2010Path -ArgumentList "/q" -Wait
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Aviso") -NoNewline -ForegroundColor Yellow
    Write-Host ("{0,-86} " -f "Visual C 2010 não encontrado no diretório.") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
}

# Visual C 2012
#----------------------------------------------------------------------------------------------
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Instalando") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "Visual C 2012") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan

$vcredist2012Path = Join-Path $updatesDirectory "vcredist2012_x64.exe"

if (Test-Path $vcredist2012Path) {
    Start-Process -FilePath $vcredist2012Path -ArgumentList "/q" -Wait
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Aviso") -NoNewline -ForegroundColor Yellow
    Write-Host ("{0,-86} " -f "Visual C 2012 não encontrado no diretório.") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
}

# Visual C 2013
#----------------------------------------------------------------------------------------------
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Instalando") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "Visual C 2013") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan

$vcredist2013Path = Join-Path $updatesDirectory "vcredist2013_x64.exe"

if (Test-Path $vcredist2013Path) {
    Start-Process -FilePath $vcredist2013Path -ArgumentList "/q" -Wait
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Aviso") -NoNewline -ForegroundColor Yellow
    Write-Host ("{0,-86} " -f "Visual C 2013 não encontrado no diretório.") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
}

# Visual C 2015 / 2017 / 2019 / 2022
#----------------------------------------------------------------------------------------------
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Instalando") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "Visual C 2015 / 2017 / 2019 / 2022") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan

$vcredist2015_2022Path = Join-Path $updatesDirectory "vcredist2015_2017_2019_2022_x64.exe"

if (Test-Path $vcredist2015_2022Path) {
    Start-Process -FilePath $vcredist2015_2022Path -ArgumentList "/q" -Wait
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Aviso") -NoNewline -ForegroundColor Yellow
    Write-Host ("{0,-86} " -f "Visual C 2015 / 2017 / 2019 / 2022 não encontrado no diretório.") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
}

# Visual C Universal
#----------------------------------------------------------------------------------------------
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Instalando") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "Visual C Universal") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan

$visualCUniversalPath = Join-Path $updatesDirectory "Windows8.1-KB2999226-x64.msu"

if (Test-Path $visualCUniversalPath) {
    Start-Process -FilePath $visualCUniversalPath -ArgumentList "/quiet" -Wait
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Aviso") -NoNewline -ForegroundColor Yellow
    Write-Host ("{0,-86} " -f "Visual C Universal não encontrado no diretório.") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
}
#----------------------------------------------------------------------------------------------

# Aplicando alterações
#----------------------------------------------------------------------------------------------
# Aplicar alterações
rundll32.exe user32.dll, UpdatePerUserSystemParameters

# Verificar se o processo explorer está em execução
$explorerProcess = Get-Process -Name explorer -ErrorAction SilentlyContinue

if ($explorerProcess) {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Reiniciando Processo") -NoNewline
    Write-Host ("{0,-86} " -f "Windows Explorer") -NoNewline -ForegroundColor Cyan
    Write-Host "║" -ForegroundColor Cyan
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Start-Process explorer -WindowStyle Hidden
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Iniciando Processo") -NoNewline
    Write-Host ("{0,-86} " -f "Windows Explorer") -NoNewline -ForegroundColor Cyan
    Write-Host "║" -ForegroundColor Cyan
    Start-Process explorer -WindowStyle Hidden
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