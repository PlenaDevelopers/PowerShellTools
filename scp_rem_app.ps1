Write-Host "╔" -NoNewline -ForegroundColor Cyan
Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
Write-Host "╗" -ForegroundColor Cyan  
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Operação") -NoNewline
Write-Host ("{0,-86} " -f "Remover aplicativos pré-instalados") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Yellow
Write-Host ("{0,-30} : " -f " Copyright") -NoNewline
Write-Host ("{0,-86} " -f "2023 - Evandro Campanhã") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Yellow

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


$AppRemoveList = @()

$AppRemoveList += @("*LinkedInForWindows*")

$AppRemoveList += @("*windowsphone*")

$AppRemoveList += @("*BingWeather*")

$AppRemoveList += @("*DesktopAppInstaller*")

$AppRemoveList += @("*GetHelp*")

$AppRemoveList += @("*Getstarted*")

$AppRemoveList += @("*Messaging*")

$AppRemoveList += @("*Microsoft3DViewer*")

$AppRemoveList += @("*MicrosoftOfficeHub*")

$AppRemoveList += @("*MicrosoftSolitaireCollection*")

$AppRemoveList += @("*solitairecollection*")

$AppRemoveList += @("*MicrosoftStickyNotes*")

$AppRemoveList += @("*MixedReality.Portal*")

$AppRemoveList += @("*Office.Desktop.Access*")

$AppRemoveList += @("*Office.Desktop.Excel*")

$AppRemoveList += @("*Office.Desktop.Outlook*")

$AppRemoveList += @("*Office.Desktop.Powerpoint*")

$AppRemoveList += @("*Office.Desktop.Publisher*")

$AppRemoveList += @("*Office.Desktop.Word*")

$AppRemoveList += @("*Office.Desktop*")

$AppRemoveList += @("*Office.onenote*")

$AppRemoveList += @("*Office.Sway*")

$AppRemoveList += @("*OneConnect*")

$AppRemoveList += @("*Print3D*")

$AppRemoveList += @("*ScreenSketch*")

$AppRemoveList += @("*Skype*")

$AppRemoveList += @("*Spotify*")

$AppRemoveList += @("*Windowscommunicationsapps*")

$AppRemoveList += @("*WindowsFeedbackHub*")

$AppRemoveList += @("*WindowsMaps*")

$AppRemoveList += @("*WindowsAlarms*")

$AppRemoveList += @("*YourPhone*")

$AppRemoveList += @("*One*")

$AppRemoveList += @("*Advertising.xaml*")

$AppRemoveList += @("*Advertising.xaml*") #intentionally listed twice

$AppRemoveList += @("*OfficeLens*")

$AppRemoveList += @("*BingNews*")

$AppRemoveList += @("*WindowsMaps*")

$AppRemoveList += @("*NetworkSpeedTest*")

$AppRemoveList += @("*Microsoft3DViewer*")

$AppRemoveList += @("*CommsPhone*")

$AppRemoveList += @("*3DBuilder*")

$AppRemoveList += @("*CBSPreview*")

$AppRemoveList += @("*king.com.CandyCrush*")

$AppRemoveList += @("*nordcurrent*")

$AppRemoveList += @("*Facebook*")

$AppRemoveList += @("*MinecraftUWP*")

$AppRemoveList += @("*Netflix*")

$AppRemoveList += @("*RoyalRevolt2*")

$AppRemoveList += @("*bingsports*")

$AppRemoveList += @("*Lenovo*")

$AppRemoveList += @("*DellCustomerConnect*")

$AppRemoveList += @("*DellDigitalDelivery*")

$AppRemoveList += @("*DellPowerManager*")

$AppRemoveList += @("*MyDell*")

$AppRemoveList += @("*DellMobileConnect*")

$AppRemoveList += @("*DellFreeFallDataProtection*")

$AppRemoveList += @("*DropboxOEM*")

$AppRemoveList += @("*zunemusic*")

$AppRemoveList += @("*zunevideo*")

$AppRemoveList += @("*windowscommunicationapps*")

$AppRemoveList += @("*xboxapp*")

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Operação") -NoNewline
Write-Host ("{0,-86} "   -f "Remover aplicativos pré-instalados" ) -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan

ForEach ($x in $AppRemoveList) {

$provisionedPackage = Get-AppxProvisionedPackage -Online | Where DisplayName -like $x

if ($provisionedPackage -ne $null) {

$appName = $provisionedPackage.DisplayName
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Aplicativo") -NoNewline
Write-Host ("{0,-86} "   -f $appName ) -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan

$null=Get-AppxProvisionedPackage -Online | Where DisplayName -like $x | Remove-AppxProvisionedPackage -online
$appPath="$Env:LOCALAPPDATA\Packages\$Appremovelist*"
$null=remove-item $appPath -Recurse -Force -Erroraction SilentlyContinue

}
}

Write-Host "║" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor gray
Write-Host "║" -ForegroundColor Cyan
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Operação") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} "   -f "Remover OneDrive" ) -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan

$onedrivePath = [System.IO.Path]::Combine($env:LOCALAPPDATA, 'Microsoft', 'OneDrive', 'OneDrive.exe')

if (Test-Path $onedrivePath) {

ps onedrive | Stop-Process -Force
start-process "$env:windir\SysWOW64\OneDriveSetup.exe" "/uninstall"

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " OneDrive") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} "   -f "Removido" ) -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan
} else {
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " OneDrive") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} "   -f "Não está instalado" ) -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan
}

Write-Host "║" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor gray
Write-Host "║" -ForegroundColor Cyan
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Instalado") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} "   -f "Calculadora do Windows" ) -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan

Get-AppxPackage -allusers *windowscalculator* | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register “$($_.InstallLocation)\AppXManifest.xml”}

Write-Host "║" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor gray
Write-Host "║" -ForegroundColor Cyan
# URL do instalador do 7-Zip
$url = "https://www.7-zip.org/a/7z1900-x64.exe"
$installerPath = "C:\Temp\7z_installer.exe"
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Instalado") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} "   -f "7-zip" ) -NoNewline -ForegroundColor Yellow
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

# URL do instalador do AnyDesk
$url = "https://download.anydesk.com/AnyDesk.exe"
$installerPath = "C:\Temp\AnyDesk_Installer.exe"
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Instalado") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} "   -f "Anydesk" ) -NoNewline -ForegroundColor Yellow
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

# URL do instalador do Google Chrome
$url = "https://dl.google.com/chrome/install/375.126/chrome_installer.exe"
$installerPath = "C:\Temp\Chrome_Installer.exe"
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Instalado") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} "   -f "Google Chrome" ) -NoNewline -ForegroundColor Yellow
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

# Reiniciar o Explorer para aplicar as alterações
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue

#Final do Script
Write-Host "╠" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
write-host "╣" -ForegroundColor Cyan  

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Processo")   -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-86} "   -f "Finalizado") -NoNewline -ForegroundColor Cyan
Write-Host "║" -ForegroundColor Cyan

Write-Host "╚" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
write-host "╝" -ForegroundColor Cyan 