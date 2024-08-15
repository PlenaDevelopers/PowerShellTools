#Script que remove a caixa de pesquisa
param (
    [string]$acao = "0" # 0 para desativar, 1 para ativar
)

# Cabeçalho
#----------------------------------------------------------------------------------------------
Write-Host "╔" -NoNewline -ForegroundColor Cyan
Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
Write-Host "╗" -ForegroundColor Cyan  

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Definir") -NoNewline
Write-Host ("{0,-86} " -f "Barra de Pesquisa") -NoNewline -ForegroundColor Yellow
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
# Defina o caminho do Registro e os valores
$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"
$regName = "SearchboxTaskbarMode"

if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}

# Valor a ser configurado (0 para desativar e 1 para ativar)
if ($acao -eq "0") {
    $regValue = 0 # Desativar
} else {
    $regValue = 2 # Ativar
}

# Define o valor no Registro
Set-ItemProperty -Path $regPath -Name $regName -Value $regValue

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " $regName") -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-86} " -f  $regValue) -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan

# Verifica se o processo do Windows Explorer está em execução
$explorerProcess = Get-Process -Name explorer -ErrorAction SilentlyContinue

# Se o processo não estiver em execução, inicie-o
if (-not $explorerProcess) {
    Start-Process explorer
}
#----------------------------------------------------------------------------------------------

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