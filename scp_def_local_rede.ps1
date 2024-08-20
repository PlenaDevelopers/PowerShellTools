# Script para alterar o "Local da Rede"

# Cabecalho
#----------------------------------------------------------------------------------------------
# Obter o diretório do script atual
$scriptName = [System.IO.Path]::GetFileName($MyInvocation.MyCommand.Path)
$CurrentScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path

# Construir o caminho completo para o script 'scp_script_cabecalho.ps1'
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_script_cabecalho.ps1"

& $CabecalhoScriptPath -Script $scriptName -Titulo "Definir local da rede"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
# Obter o perfil da conexão de rede
$connectionProfile = Get-NetConnectionProfile

# Verificar o tipo de rede
if ($connectionProfile.NetworkCategory -eq 'Public') {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Tipo de Rede") -NoNewline
    Write-Host ("{0,-86} " -f "Pública") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan
}
elseif ($connectionProfile.NetworkCategory -eq 'Private') {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Tipo de Rede") -NoNewline
    Write-Host ("{0,-86} " -f "Privada") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan
}
else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Tipo de Rede") -NoNewline
    Write-Host ("{0,-86} " -f "Desconhecida") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan
}

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Tarefa") -NoNewline -ForegroundColor cyan
Write-Host ("{0,-86} " -f "Alterar Local da Rede - Privada") -NoNewline -ForegroundColor cyan
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
    Write-Host ("{0,-30} : " -f "Tipo de Rede") -NoNewline
    Write-Host ("{0,-86} " -f "Pública") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan
}
elseif ($connectionProfile.NetworkCategory -eq 'Private') {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Tipo de Rede") -NoNewline
    Write-Host ("{0,-86} " -f "Privada") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan
}
else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Tipo de Rede") -NoNewline
    Write-Host ("{0,-86} " -f "Desconhecida") -NoNewline -ForegroundColor Green
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