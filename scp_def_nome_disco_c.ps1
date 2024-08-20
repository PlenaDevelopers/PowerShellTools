# Script para alterar o rótulo da "Unidade C"

# Cabecalho
#----------------------------------------------------------------------------------------------
# Obter o diretório do script atual
$scriptName = [System.IO.Path]::GetFileName($MyInvocation.MyCommand.Path)
$CurrentScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path

# Construir o caminho completo para o script 'scp_script_cabecalho.ps1'
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_script_cabecalho.ps1"

& $CabecalhoScriptPath -Script $scriptName -Titulo "Renomear disco primário"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
$novoRotulo = "windows"

# Obtém a letra da unidade onde o Windows está instalado
$windowsDrive = $env:SystemDrive.TrimEnd(':') # Remove o ':' do final

# Obtém o volume da unidade do sistema
$volume = Get-Volume | Where-Object { $_.DriveLetter -eq $windowsDrive }

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Disco") -NoNewline
Write-Host ("{0,-86} " -f $volume.FileSystemLabel) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Sistema de Arquivos") -NoNewline
Write-Host ("{0,-86} " -f $volume.FileSystem) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("═" * 120) -NoNewline -ForegroundColor gray
Write-Host "║" -ForegroundColor Cyan

# Renomeia o rótulo do volume
Set-Volume -DriveLetter $volume.DriveLetter -NewFileSystemLabel $novoRotulo

# Adiciona um pequeno atraso (por exemplo, 1 segundo)
Start-Sleep -Seconds 3

# Atualiza as configurações do sistema (opcional)
rundll32.exe user32.dll, UpdatePerUserSystemParameters

# Recupera o novo nome do volume
$novoNome = (Get-Volume -DriveLetter $volume.DriveLetter).FileSystemLabel

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Nome Anterior") -NoNewline
Write-Host ("{0,-86} " -f $volume.FileSystemLabel) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Novo Nome") -NoNewline
Write-Host ("{0,-86} " -f $novoNome) -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan
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