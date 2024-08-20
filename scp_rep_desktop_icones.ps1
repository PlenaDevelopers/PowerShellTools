# Script para reparar Ícones do Desktop
# Cabeçalho
#----------------------------------------------------------------------------------------------
Write-Host "╔" -NoNewline -ForegroundColor Cyan
Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
Write-Host "╗" -ForegroundColor Cyan  

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Operação") -NoNewline
Write-Host ("{0,-86} " -f "Reparar Desktop") -NoNewline -ForegroundColor Yellow
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
# Caminho do Registro para as configurações da área de trabalho
$desktopIconsRegistryPath = "HKCU:\Software\Microsoft\Windows\Shell\Bags\1\Desktop"
$desktopIconsRegistryPathBase = "HKCU:\Software\Microsoft\Windows\Shell\Bags"
$desktopIconsBagMRUPath = "HKCU:\Software\Microsoft\Windows\Shell\BagMRU"
$displaySettingsRegistryPath = "HKCU:\Control Panel\Desktop"

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Chave") -NoNewline
Write-Host ("{0,-86} " -f $desktopIconsRegistryPath) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

# Remover chaves relacionadas a layouts de ícones
$null = Remove-Item -Path $desktopIconsRegistryPathBase -Recurse -ErrorAction SilentlyContinue
$null = Remove-Item -Path $desktopIconsBagMRUPath -Recurse -ErrorAction SilentlyContinue

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Chaves") -NoNewline
Write-Host ("{0,-86} " -f "Removidas") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan

# Remover chaves relacionadas a configurações de exibição
$null = Remove-ItemProperty -Path $displaySettingsRegistryPath -Name "Wallpaper" -ErrorAction SilentlyContinue
$null = Remove-ItemProperty -Path $displaySettingsRegistryPath -Name "WallpaperStyle" -ErrorAction SilentlyContinue

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Chaves") -NoNewline
Write-Host ("{0,-86} " -f "Restauradas") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan

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