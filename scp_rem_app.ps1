<#
    Função: Remover aplicativos pré-instalados
	Copyright: © Plena Soluções - 2024
	Date: Agosto/2024

	Licenciamento:
	Este script é fornecido "como está", sem qualquer garantia de qualquer tipo,
	expressa ou implícita, incluindo, mas não se limitando às garantias de 
	comercialização, adequação a um determinado fim e não violação. O uso deste 
	script é totalmente gratuito, mas você deve manter os créditos ao autor original.
	
	Seriais/Keys:
	Os Seriais/Keys para licenciamento de software contidos neste ou em outros
	arquivos são meramente ilustrativos para a utilização do script, sendo assim cabe
	ao utilizador do script alterar estas chaves para uma válida que represente o 
	licenciamento vigente.

	Bugs & Correções
	Em caso de Bugs encontrado pedimos a gentileza de informar por email para que possamos 
	analizar e gerar atualizações corretivas.

	Autor: Evandro Campanhã
	Contato: aurora.erp@gmail.com
	------------------------------------------------------------------------------
#>
# Cabeçalho
#----------------------------------------------------------------------------------------------
# Obter o diretório do script atual
$scriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path -Parent

# Obter o nome do script atual
$scriptName = [System.IO.Path]::GetFileName($MyInvocation.MyCommand.Path)

# Construir o caminho completo para o script 'scp_script_cabecalho.ps1'
$cabecalhoScriptPath = Join-Path -Path $scriptDirectory -ChildPath "scp_script_cabecalho.ps1"

# Executar o script de cabeçalho
& $cabecalhoScriptPath -Script $scriptName -Titulo "Remover aplicativos pré-instalados"
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

ForEach ($x in $AppRemoveList) {
    $provisionedPackage = Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like $x }

    if ($provisionedPackage -ne $null) {
        $appName = $provisionedPackage.DisplayName
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Aplicativo") -NoNewline
        Write-Host ("{0,-86} " -f $appName) -NoNewline -ForegroundColor Yellow
        Write-Host "║" -ForegroundColor Cyan

        $null = Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like $x } | Remove-AppxProvisionedPackage -Online
        $appPath = "$Env:LOCALAPPDATA\Packages\$x*"
        $null = Remove-Item -Path $appPath -Recurse -Force -ErrorAction SilentlyContinue
    }
}


Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Operação") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "Remover OneDrive") -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

$onedrivePath = [System.IO.Path]::Combine($env:LOCALAPPDATA, 'Microsoft', 'OneDrive', 'OneDrive.exe')

if (Test-Path $onedrivePath) {
    Stop-Process -Name onedrive -Force -ErrorAction SilentlyContinue
    Start-Process "$env:windir\SysWOW64\OneDriveSetup.exe" "/uninstall"
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "OneDrive") -NoNewline -ForegroundColor White
    Write-Host ("{0,-86} " -f "Removido") -NoNewline -ForegroundColor Yellow
    Write-Host "║" -ForegroundColor Cyan
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "OneDrive") -NoNewline -ForegroundColor White
    Write-Host ("{0,-86} " -f "Não está instalado") -NoNewline -ForegroundColor Yellow
    Write-Host "║" -ForegroundColor Cyan
}
#----------------------------------------------------------------------------------------------

# Aplicando alterações
#----------------------------------------------------------------------------------------------
rundll32.exe user32.dll, UpdatePerUserSystemParameters
#----------------------------------------------------------------------------------------------

# Rodapé
#----------------------------------------------------------------------------------------------
# Obter o diretório do script atual
$CurrentScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path -Parent

# Construir o caminho completo para o script 'scp_script_rodape.ps1'
$rodapeScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_script_rodape.ps1"

# Executar o script de rodapé
& $rodapeScriptPath
#----------------------------------------------------------------------------------------------