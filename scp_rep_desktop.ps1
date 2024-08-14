# Detectar o perfil do usuário atual
$perfil_usuario = [System.Environment]::GetFolderPath('UserProfile')

# Encontrar a pasta "Desktop" do usuário
$pastaDesktop = [System.Environment]::GetFolderPath('Desktop')

# Liberar o desktop
Write-Host "╔" -NoNewline -ForegroundColor Cyan
Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
Write-Host "╗" -ForegroundColor Cyan  
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Operação") -NoNewline
Write-Host ("{0,-86} " -f "Limpar Desktop") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Yellow
Write-Host ("{0,-30} : " -f "Copyright") -NoNewline
Write-Host ("{0,-86} " -f "2023 - Evandro Campanhã") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Yellow

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Script") -NoNewline
Write-Host ("{0,-86} " -f $MyInvocation.MyCommand.Path) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

Write-Host "╠" -NoNewline -ForegroundColor Cyan
Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
Write-Host "╣" -ForegroundColor Cyan

# Exibir o caminho da pasta do perfil
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Pasta do Perfil") -NoNewline
Write-Host ("{0,-86} " -f $perfil_usuario) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

# Caminho da pasta "Backup de Atalhos" no Desktop
$pastaAtalhosAntigos = Join-Path $pastaDesktop "Backup de Atalhos"

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Pasta") -NoNewline
Write-Host ("{0,-86} " -f $pastaAtalhosAntigos) -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan

# Verificar se a pasta "Backup de Atalhos" existe, senão criar
if (-not (Test-Path -Path $pastaAtalhosAntigos -PathType Container)) {
    $null = New-Item -Path $pastaAtalhosAntigos -ItemType Directory
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Pasta") -NoNewline
    Write-Host ("{0,-86} " -f "Criada") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Green
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Pasta") -NoNewline
    Write-Host ("{0,-86} " -f "Já existia") -NoNewline -ForegroundColor Yellow
    Write-Host "║" -ForegroundColor Cyan
}

# Mover arquivos para a pasta "Backup de Atalhos"
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Tarefa") -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-86} " -f "Mover Arquivos") -NoNewline -ForegroundColor Cyan
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("═" * 120) -NoNewline -ForegroundColor Gray
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Tipo de Arquivo") -NoNewline
Write-Host ("{0,-86} " -f "Atalhos Locais") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan

Get-ChildItem -Path "$pastaDesktop\*.lnk" | Move-Item -Destination $pastaAtalhosAntigos -Force

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Tipo de Arquivo") -NoNewline
Write-Host ("{0,-86} " -f "Atalhos da Internet") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan

Get-ChildItem -Path "$pastaDesktop\*.url" | Move-Item -Destination $pastaAtalhosAntigos -Force

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Tipo de Arquivo") -NoNewline
Write-Host ("{0,-86} " -f "Conexões RDP") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan

Get-ChildItem -Path "$pastaDesktop\*.rdp" | Move-Item -Destination $pastaAtalhosAntigos -Force

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Tarefa") -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-86} " -f "Organizar") -NoNewline -ForegroundColor Cyan
Write-Host "║" -ForegroundColor Cyan

# Caminho do Registro para ícones na área de trabalho
$desktopIconsRegistryPath = "HKCU:\Software\Microsoft\Windows\Shell\Bags\1\Desktop"

# Valor 0 para desativar o Auto Arrange, 1 para ativar
$autoArrangeValue = 1

# Criar ou atualizar a entrada no Registro
$null = New-ItemProperty -Path $desktopIconsRegistryPath -Name "AutoArrange" -Value $autoArrangeValue -PropertyType DWORD -Force

# Reiniciar o processo do Explorer para aplicar as alterações
Stop-Process -Name explorer -Force

# Final do Script
Write-Host "╠" -NoNewline -ForegroundColor Cyan
Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
Write-Host "╣" -ForegroundColor Cyan  

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Processo") -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-86} " -f "Finalizado") -NoNewline -ForegroundColor Cyan
Write-Host "║" -ForegroundColor Cyan

Write-Host "╚" -NoNewline -ForegroundColor Cyan
Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
Write-Host "╝" -ForegroundColor Cyan