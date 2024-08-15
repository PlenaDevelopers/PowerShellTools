# Script para ativar a visualização de extensões de arquivos
param (
    [string]$valor = "1" # "0" - Não Mostrar | "1" - Mostrar 
)

# Cabeçalho
#----------------------------------------------------------------------------------------------
Write-Host "╔" -NoNewline -ForegroundColor Cyan
Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
Write-Host "╗" -ForegroundColor Cyan  

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Operação") -NoNewline
Write-Host ("{0,-86} " -f "Definir opções de arquivos") -NoNewline -ForegroundColor Yellow
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
# Defina o caminho para o Registro do Windows
$registryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"

# Defina o nome do valor no registro
$valueName = "HideFileExt"

# Verifique se o parâmetro é válido
if ($valor -ne "0" -and $valor -ne "1") {
    Write-Host "║" -NoNewline -ForegroundColor Red
    Write-Host ("{0,-30} : " -f " Erro") -NoNewline
    Write-Host ("{0,-86} " -f "Parâmetro inválido! Use '0' para Não Mostrar ou '1' para Mostrar") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
    exit
}

# Defina o valor de acordo com o parâmetro
$regValue = [int]$valor

# Verifique se o caminho do registro existe
if (Test-Path $registryPath) {
    # Crie ou atualize o valor no registro
    Set-ItemProperty -Path $registryPath -Name $valueName -Value $regValue
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Opção") -NoNewline
    Write-Host ("{0,-86} " -f "Visualizar extensões de arquivos ativada") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Opção") -NoNewline
    Write-Host ("{0,-86} " -f "Visualizar extensões de arquivos não ativada") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
}

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