# Script para instalar utilitários
# Cabeçalho
#----------------------------------------------------------------------------------------------
Write-Host "╔" -NoNewline -ForegroundColor Cyan
Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
Write-Host "╗" -ForegroundColor Cyan  

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Operação") -NoNewline
Write-Host ("{0,-86} " -f "Remover aplicativos pré-instalados") -NoNewline -ForegroundColor Yellow
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

# URL do instalador do 7-Zip
#----------------------------------------------------------------------------------------------
$url = "https://www.7-zip.org/a/7z1900-x64.exe"
$installerPath = "C:\Temp\7z_installer.exe"
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Aplicativo") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} "   -f "7-zip" ) -NoNewline -ForegroundColor Cyan
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " URL") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} "   -f "$url" ) -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Arquivo Temporário") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} "   -f "$installerPath" ) -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan
# Criar o diretório se não existir
$directory = [System.IO.Path]::GetDirectoryName($installerPath)
if (-not (Test-Path $directory -PathType Container)) {
    New-Item -ItemType Directory -Path $directory | Out-Null
}
# Baixar o instalador com exibição de progresso
Invoke-WebRequest -Uri $url -OutFile $installerPath -UseBasicParsing
# Executar a instalação silenciosa
Start-Process -FilePath $installerPath -ArgumentList "/S" -Wait
# Remover o instalador após a instalação (opcional)
Remove-Item -Path $installerPath
Write-Host "║" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor gray
Write-Host "║" -ForegroundColor Cyan
#----------------------------------------------------------------------------------------------

# URL do instalador do AnyDesk
#----------------------------------------------------------------------------------------------
$url = "https://download.anydesk.com/AnyDesk.exe"
$installerPath = "C:\Temp\AnyDesk_Installer.exe"
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Aplicativo") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} "   -f "Anydesk" ) -NoNewline -ForegroundColor Cyan
Write-Host "║" -ForegroundColor Cyan
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " URL") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} "   -f "$url" ) -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Arquivo Temporário") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} "   -f "$installerPath" ) -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan
# Criar o diretório se não existir
$directory = [System.IO.Path]::GetDirectoryName($installerPath)
if (-not (Test-Path $directory -PathType Container)) {
    New-Item -ItemType Directory -Path $directory | Out-Null
}
# Baixar o instalador com exibição de progresso
Invoke-WebRequest -Uri $url -OutFile $installerPath -UseBasicParsing
# Caminho de instalação do AnyDesk
$installPath = "C:\Program Files (x86)\AnyDesk"
# Instalação do AnyDesk
Start-Process -FilePath $installerPath -ArgumentList "--install `"$installPath`" --start-with-win --silent --create-shortcuts --create-desktop-icon" -Wait

# Registrar a chave de licença
$licenseKey = "licence_keyABC"
$processStartInfo = New-Object System.Diagnostics.ProcessStartInfo
$processStartInfo.FileName = "$installPath\AnyDesk.exe"
$processStartInfo.Arguments = "--register-licence"
$processStartInfo.RedirectStandardInput = $true
$processStartInfo.UseShellExecute = $false
$processStartInfo.CreateNoWindow = $true

$process = New-Object System.Diagnostics.Process
$process.StartInfo = $processStartInfo
$process.Start() | Out-Null
$process.StandardInput.WriteLine($licenseKey)
$process.WaitForExit()

# Definir senha do AnyDesk
$password = "password123"
$processStartInfo.Arguments = "--set-password"

# Criar um novo objeto Process para a segunda execução
$process = New-Object System.Diagnostics.Process
$process.StartInfo = $processStartInfo
$process.Start() | Out-Null
$process.StandardInput.WriteLine($password)
$process.WaitForExit()
# Remover o instalador após a instalação (opcional)
Remove-Item -Path $installerPath
Write-Host "║" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor gray
Write-Host "║" -ForegroundColor Cyan
#----------------------------------------------------------------------------------------------

# URL do instalador do Google Chrome
#----------------------------------------------------------------------------------------------
$url = "https://dl.google.com/chrome/install/375.126/chrome_installer.exe"
$installerPath = "C:\Temp\Chrome_Installer.exe"
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Aplicativo") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} "   -f "Google Chrome" ) -NoNewline -ForegroundColor Cyan
Write-Host "║" -ForegroundColor Cyan
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " URL") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} "   -f "$url" ) -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Arquivo Temporário") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} "   -f "$installerPath" ) -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan
# Criar o diretório se não existir
$directory = [System.IO.Path]::GetDirectoryName($installerPath)
if (-not (Test-Path $directory -PathType Container)) {
    New-Item -ItemType Directory -Path $directory | Out-Null
}
# Baixar o instalador com exibição de progresso
Invoke-WebRequest -Uri $url -OutFile $installerPath -UseBasicParsing
# Executar a instalação silenciosa
Start-Process -FilePath $installerPath -ArgumentList "/silent /install" -Wait
# Remover o instalador após a instalação (opcional)
Remove-Item -Path $installerPath
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