# Script para atualizar o Net. Framework

# Cabecalho
#----------------------------------------------------------------------------------------------
# Obter o diretório do script atual
$scriptName = [System.IO.Path]::GetFileName($MyInvocation.MyCommand.Path)
$CurrentScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path

# Construir o caminho completo para o script 'scp_script_cabecalho.ps1'
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_script_cabecalho.ps1"

& $CabecalhoScriptPath -Script $scriptName -Titulo "Atualizar Net. Framework"
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
Write-Host ("{0,-30} : " -f "Diretorio das Atualizações") -NoNewline
Write-Host ("{0,-86} " -f $updatesDirectory) -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan

Write-Host "╠" -NoNewline -ForegroundColor Cyan
Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
Write-Host "╣" -ForegroundColor Cyan

# Framework 3.5
#----------------------------------------------------------------------------------------------
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Instalando") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "NET Framework 3.5") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan

$netFrameworkPath = Join-Path $updatesDirectory "dotnetfx35.exe"

if (Test-Path $netFrameworkPath) {
    Start-Process -FilePath $netFrameworkPath -ArgumentList "/quiet" -Wait
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Aviso") -NoNewline -ForegroundColor Yellow
    Write-Host ("{0,-86} " -f "NET Framework 3.5 não encontrado no diretório.") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
}

# Framework 4.5
#----------------------------------------------------------------------------------------------
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Instalando") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "NET Framework 4.5") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan

$netFrameworkPath = Join-Path $updatesDirectory "Net-Framework 4.5.exe"

if (Test-Path $netFrameworkPath) {
    Start-Process -FilePath $netFrameworkPath -ArgumentList "/quiet" -Wait
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Aviso") -NoNewline -ForegroundColor Yellow
    Write-Host ("{0,-86} " -f "NET Framework 4.5 não encontrado no diretório.") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
}

# Framework 4.6
#----------------------------------------------------------------------------------------------
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Instalando") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "NET Framework 4.6") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan

$netFrameworkPath = Join-Path $updatesDirectory "Net-Framework 4.6.exe"

if (Test-Path $netFrameworkPath) {
    Start-Process -FilePath $netFrameworkPath -ArgumentList "/quiet" -Wait
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Aviso") -NoNewline -ForegroundColor Yellow
    Write-Host ("{0,-86} " -f "NET Framework 4.6 não encontrado no diretório.") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
}

# Framework 4.6.1
#----------------------------------------------------------------------------------------------
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Instalando") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "NET Framework 4.6.1") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan

$netFrameworkPath = Join-Path $updatesDirectory "Net-Framework 4.6.1.exe"

if (Test-Path $netFrameworkPath) {
    Start-Process -FilePath $netFrameworkPath -ArgumentList "/quiet" -Wait
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Aviso") -NoNewline -ForegroundColor Yellow
    Write-Host ("{0,-86} " -f "NET Framework 4.6.1 não encontrado no diretório.") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
}

# Framework 4.7.1
#----------------------------------------------------------------------------------------------
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Instalando") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "NET Framework 4.7.1") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan

$netFrameworkPath = Join-Path $updatesDirectory "Net-Framework 4.7.1.exe"

if (Test-Path $netFrameworkPath) {
    Start-Process -FilePath $netFrameworkPath -ArgumentList "/quiet" -Wait
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Aviso") -NoNewline -ForegroundColor Yellow
    Write-Host ("{0,-86} " -f "NET Framework 4.7.1 não encontrado no diretório.") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
}

# Framework 4.7.2
#----------------------------------------------------------------------------------------------
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Instalando") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "NET Framework 4.7.2") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan

$netFrameworkPath = Join-Path $updatesDirectory "Net-Framework 4.7.2.exe"

if (Test-Path $netFrameworkPath) {
    Start-Process -FilePath $netFrameworkPath -ArgumentList "/quiet" -Wait
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Aviso") -NoNewline -ForegroundColor Yellow
    Write-Host ("{0,-86} " -f "NET Framework 4.7.2 não encontrado no diretório.") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
}

# Framework 4.7.3
#----------------------------------------------------------------------------------------------
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Instalando") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "NET Framework 4.7.3") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan

$netFrameworkPath = Join-Path $updatesDirectory "Net-Framework 4.7.3.exe"

if (Test-Path $netFrameworkPath) {
    Start-Process -FilePath $netFrameworkPath -ArgumentList "/quiet" -Wait
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Aviso") -NoNewline -ForegroundColor Yellow
    Write-Host ("{0,-86} " -f "NET Framework 4.7.3 não encontrado no diretório.") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
}

# Framework 4.8
#----------------------------------------------------------------------------------------------
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Instalando") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "NET Framework 4.8") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan

$netFrameworkPath = Join-Path $updatesDirectory "Net-Framework 4.8.exe"

if (Test-Path $netFrameworkPath) {
    Start-Process -FilePath $netFrameworkPath -ArgumentList "/quiet" -Wait
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Aviso") -NoNewline -ForegroundColor Yellow
    Write-Host ("{0,-86} " -f "NET Framework 4.8 não encontrado no diretório.") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
}

# Framework 4.8.1
#----------------------------------------------------------------------------------------------
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Instalando") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "NET Framework 4.8.1") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan

$netFrameworkPath = Join-Path $updatesDirectory "Net-Framework 4.8.1.exe"

if (Test-Path $netFrameworkPath) {
    Start-Process -FilePath $netFrameworkPath -ArgumentList "/quiet" -Wait
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Aviso") -NoNewline -ForegroundColor Yellow
    Write-Host ("{0,-86} " -f "NET Framework 4.8.1 não encontrado no diretório.") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
}
#----------------------------------------------------------------------------------------------

# Aplicando alterações
#----------------------------------------------------------------------------------------------
rundll32.exe user32.dll, UpdatePerUserSystemParameters
#----------------------------------------------------------------------------------------------

# Rodape
#----------------------------------------------------------------------------------------------
# Obter o diretório do script atual
$CurrentScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path

# Construir o caminho completo para o script 'scp_script_rodape.ps1'
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_script_rodape.ps1"

& $CabecalhoScriptPath
#----------------------------------------------------------------------------------------------