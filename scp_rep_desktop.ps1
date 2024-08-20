# Script para fazer backup dos ícones da "Área de Trabalho"
# Cabecalho
#----------------------------------------------------------------------------------------------
# Obter o diretório do script atual
$scriptName = [System.IO.Path]::GetFileName($MyInvocation.MyCommand.Path)
$CurrentScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path

# Construir o caminho completo para o script 'scp_script_cabecalho.ps1'
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_script_cabecalho.ps1"

& $CabecalhoScriptPath -Script $scriptName -Titulo "Reparar Desktop"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
# Detectar o perfil do usuário atual
$perfil_usuario = [System.Environment]::GetFolderPath('UserProfile')

# Encontrar a pasta "Desktop" do usuário
$pastaDesktop = [System.Environment]::GetFolderPath('Desktop')

# Exibir o caminho da pasta do perfil
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Pasta do Perfil") -NoNewline
Write-Host ("{0,-86} " -f $perfil_usuario) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

# Caminho da pasta "Backup de Atalhos" no Desktop
$pastaAtalhosAntigos = Join-Path $pastaDesktop "Backup de Atalhos"

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Pasta") -NoNewline
Write-Host ("{0,-86} " -f $pastaAtalhosAntigos) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

# Verificar se a pasta "Backup de Atalhos" existe, senão criar
if (-not (Test-Path -Path $pastaAtalhosAntigos -PathType Container)) {
    $null = New-Item -Path $pastaAtalhosAntigos -ItemType Directory
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Status") -NoNewline
    Write-Host ("{0,-86} " -f "Criada") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Green
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Status") -NoNewline
    Write-Host ("{0,-86} " -f "Já existia") -NoNewline -ForegroundColor Yellow
    Write-Host "║" -ForegroundColor Cyan
}

# Mover arquivos para a pasta "Backup de Atalhos"
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Tarefa") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "Mover Arquivos") -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("═" * 120) -NoNewline -ForegroundColor Gray
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Tipo de Arquivo") -NoNewline
Write-Host ("{0,-86} " -f "Atalhos Locais (*.lnk)") -NoNewline -ForegroundColor white
Write-Host "║" -ForegroundColor Cyan

Get-ChildItem -Path "$pastaDesktop\*.lnk" | Move-Item -Destination $pastaAtalhosAntigos -Force

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Tipo de Arquivo") -NoNewline
Write-Host ("{0,-86} " -f "Atalhos da Internet (*.url)") -NoNewline -ForegroundColor white
Write-Host "║" -ForegroundColor Cyan

Get-ChildItem -Path "$pastaDesktop\*.url" | Move-Item -Destination $pastaAtalhosAntigos -Force

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Tipo de Arquivo") -NoNewline
Write-Host ("{0,-86} " -f "Conexões RDP (*.rdp)") -NoNewline -ForegroundColor white
Write-Host "║" -ForegroundColor Cyan

Get-ChildItem -Path "$pastaDesktop\*.rdp" | Move-Item -Destination $pastaAtalhosAntigos -Force
#----------------------------------------------------------------------------------------------

# Aplicando alterações
#----------------------------------------------------------------------------------------------
# Aplicar alterações
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