# Script para mostrar a versão do Windows no Desktop
param (
    [string]$valor = "1" #"0" - Não Mostrar | "1" - Mostrar 
)

# Cabeçalho
#----------------------------------------------------------------------------------------------
Write-Host "╔" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
write-host "╗" -ForegroundColor Cyan  
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Operação") -NoNewline
Write-Host ("{0,-86} " -f "Mostrar versão do Windows no Desktop") -NoNewline -ForegroundColor Yellow
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
# Defina o caminho do Registro e os valores
$regPath = "HKCU:\Control Panel\Desktop"
$regName = "PaintDesktopVersion"

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

# Verifique se a chave do Registro existe
if (-not (Test-Path $regPath)) {
    # Crie a chave do Registro se não existir
    New-Item -Path $regPath -Force
}

# Atualize ou crie o valor do Registro
Write-Host "║" -NoNewline -ForegroundColor Cyan
if ($regValue -eq 1) {
    Write-Host ("{0,-30} : " -f " Definindo valor") -NoNewline
    Write-Host ("{0,-86} " -f "Mostrar versão do Windows") -NoNewline -ForegroundColor White
} else {
    Write-Host ("{0,-30} : " -f " Definindo valor") -NoNewline
    Write-Host ("{0,-86} " -f "Não mostrar versão do Windows") -NoNewline -ForegroundColor White
}
Write-Host "║" -ForegroundColor Cyan

Set-ItemProperty -Path $regPath -Name $regName -Value $regValue

# Atualizar a configuração do sistema para aplicar a mudança imediatamente
RUNDLL32.EXE USER32.DLL,UpdatePerUserSystemParameters 1, True
Stop-Process -Name explorer -Force
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
