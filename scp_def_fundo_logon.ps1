# Script para alterar o plano de fundo da tela de bloqueio
param (
    [string]$imagemCaminho = "$PSScriptRoot\wallpaper\wallpaper_default.jpg"
)

# Caminho do registro para configurar a tela de bloqueio
$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Lock Screen\"
$regName = "Creative"

# Verifica se o caminho do registro existe
if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}

# Define o caminho da imagem como o valor no registro
Set-ItemProperty -Path $regPath -Name $regName -Value $imagemCaminho

# Interface amigável com bordas no estilo dos scripts anteriores

Write-Host "╔" -NoNewline -ForegroundColor Cyan
Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
Write-Host "╗" -ForegroundColor Cyan  

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Definir") -NoNewline
Write-Host ("{0,-86} " -f "Plano de Fundo da Tela de Bloqueio") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Caminho da Imagem") -NoNewline
Write-Host ("{0,-86} " -f $imagemCaminho) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

$computerName = (Get-ComputerInfo).CsName
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Computador") -NoNewline
Write-Host ("{0,-86} " -f $computerName) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Script") -NoNewline
Write-Host ("{0,-86} " -f $MyInvocation.MyCommand.Path) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

Write-Host "╠" -NoNewline -ForegroundColor Cyan
Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
Write-Host "╣" -ForegroundColor Cyan  

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Aplicando Configuração") -NoNewline -ForegroundColor Red
Write-Host ("{0,-86} " -f $regName+ " = " + $imagemCaminho) -NoNewline -ForegroundColor Red
Write-Host "║" -ForegroundColor Cyan

# Final do Script
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
