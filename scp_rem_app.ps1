# Script para remover aplicativos pré-instalados
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
$AppRemoveList = @(
    "*LinkedInForWindows*",
    "*windowsphone*",
    "*BingWeather*",
    "*DesktopAppInstaller*",
    "*GetHelp*",
    "*Getstarted*",
    "*Messaging*",
    "*Microsoft3DViewer*",
    "*MicrosoftOfficeHub*",
    "*MicrosoftSolitaireCollection*",
    "*solitairecollection*",
    "*MicrosoftStickyNotes*",
    "*MixedReality.Portal*",
    "*Office.Desktop.Access*",
    "*Office.Desktop.Excel*",
    "*Office.Desktop.Outlook*",
    "*Office.Desktop.Powerpoint*",
    "*Office.Desktop.Publisher*",
    "*Office.Desktop.Word*",
    "*Office.Desktop*",
    "*Office.onenote*",
    "*Office.Sway*",
    "*OneConnect*",
    "*Print3D*",
    "*ScreenSketch*",
    "*Skype*",
    "*Spotify*",
    "*Windowscommunicationsapps*",
    "*WindowsFeedbackHub*",
    "*WindowsMaps*",
    "*WindowsAlarms*",
    "*YourPhone*",
    "*One*",
    "*Advertising.xaml*",
    "*OfficeLens*",
    "*BingNews*",
    "*NetworkSpeedTest*",
    "*CommsPhone*",
    "*3DBuilder*",
    "*CBSPreview*",
    "*king.com.CandyCrush*",
    "*nordcurrent*",
    "*Facebook*",
    "*MinecraftUWP*",
    "*Netflix*",
    "*RoyalRevolt2*",
    "*bingsports*",
    "*Lenovo*",
    "*DellCustomerConnect*",
    "*DellDigitalDelivery*",
    "*DellPowerManager*",
    "*MyDell*",
    "*DellMobileConnect*",
    "*DellFreeFallDataProtection*",
    "*DropboxOEM*",
    "*zunemusic*",
    "*zunevideo*",
    "*windowscommunicationapps*",
    "*xboxapp*"
)

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Operação") -NoNewline
Write-Host ("{0,-86} " -f "Remover aplicativos pré-instalados") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan

ForEach ($x in $AppRemoveList) {
    $provisionedPackage = Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like $x }

    if ($provisionedPackage -ne $null) {
        $appName = $provisionedPackage.DisplayName
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f " Aplicativo") -NoNewline
        Write-Host ("{0,-86} " -f $appName) -NoNewline -ForegroundColor Yellow
        Write-Host "║" -ForegroundColor Cyan

        $null = Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like $x } | Remove-AppxProvisionedPackage -Online
        $appPath = "$Env:LOCALAPPDATA\Packages\$x*"
        $null = Remove-Item -Path $appPath -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("═" * 120) -NoNewline -ForegroundColor Gray
Write-Host "║" -ForegroundColor Cyan
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Operação") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "Remover OneDrive") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan

$onedrivePath = [System.IO.Path]::Combine($env:LOCALAPPDATA, 'Microsoft', 'OneDrive', 'OneDrive.exe')

if (Test-Path $onedrivePath) {
    Stop-Process -Name onedrive -Force -ErrorAction SilentlyContinue
    Start-Process "$env:windir\SysWOW64\OneDriveSetup.exe" "/uninstall"
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " OneDrive") -NoNewline -ForegroundColor White
    Write-Host ("{0,-86} " -f "Removido") -NoNewline -ForegroundColor Yellow
    Write-Host "║" -ForegroundColor Cyan
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " OneDrive") -NoNewline -ForegroundColor White
    Write-Host ("{0,-86} " -f "Não está instalado") -NoNewline -ForegroundColor Yellow
    Write-Host "║" -ForegroundColor Cyan
}

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("═" * 120) -NoNewline -ForegroundColor Gray
Write-Host "║" -ForegroundColor Cyan
#----------------------------------------------------------------------------------------------

# Aplicando alterações
#----------------------------------------------------------------------------------------------
# Aplicar alterações
rundll32.exe user32.dll, UpdatePerUserSystemParameters

# Verificar se o processo explorer está em execução
$explorerProcess = Get-Process -Name explorer -ErrorAction SilentlyContinue

if ($explorerProcess) {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Reiniciando Processo") -NoNewline
    Write-Host ("{0,-86} " -f "Windows Explorer") -NoNewline -ForegroundColor Cyan
    Write-Host "║" -ForegroundColor Cyan
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Start-Process explorer -WindowStyle Hidden
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Iniciando Processo") -NoNewline
    Write-Host ("{0,-86} " -f "Windows Explorer") -NoNewline -ForegroundColor Cyan
    Write-Host "║" -ForegroundColor Cyan
    Start-Process explorer -WindowStyle Hidden
}
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