<#
    Função: Microsoft Edge Lite
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

# Função: Microsoft Edge Lite
param (
    [string]$Action = "0" # "0" - Desabilitar, "1" - Habilitar
)

# Cabeçalho
#----------------------------------------------------------------------------------------------
# Obter o diretório do script atual
$scriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path -Parent

# Obter o nome do script atual
$scriptName = [System.IO.Path]::GetFileName($MyInvocation.MyCommand.Path)

# Construir o caminho completo para o script 'scp_script_cabecalho.ps1'
$cabecalhoScriptPath = Join-Path -Path $scriptDirectory -ChildPath "scp_script_cabecalho.ps1"

# Executar o script de cabeçalho
& $cabecalhoScriptPath -Script $scriptName -Titulo "Microsoft Edge Lite"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
$edgeKeyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
$edgeUpdateKeyPath = "HKLM:\SOFTWARE\Policies\Microsoft\EdgeUpdate"
$microsoftKeyPath = "HKLM:\SOFTWARE\Microsoft"

# Criar as chaves de registro se não existirem
if (-not (Test-Path $edgeKeyPath)) {
    New-Item -Path $edgeKeyPath -Force | Out-Null
}
if (-not (Test-Path $edgeUpdateKeyPath)) {
    New-Item -Path $edgeUpdateKeyPath -Force | Out-Null
}
if (-not (Test-Path $microsoftKeyPath)) {
    New-Item -Path $microsoftKeyPath -Force | Out-Null
}

# Definir valores para habilitar ou desabilitar
if ($Action -eq "1") {
    $syncDisabled = 1
    $browserSignin = 0
    $newSmartScreenLibraryEnabled = 0
    $smartScreenEnabled = 0
    $smartScreenPuaEnabled = 0
    $startupBoostEnabled = 0
    $bingAdsSuppression = 1
    $backgroundModeEnabled = 0
    $componentUpdatesEnabled = 0
    $edgeShoppingAssistantEnabled = 0
    $forceGoogleSafeSearch = 1
    $autoUpdateCheckPeriodMinutes = 0
    $updateDefault = 0
    $updatePolicy = 0
    $doNotUpdateToEdgeWithChromium = 1
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Status") -NoNewline
    Write-Host ("{0,-86} " -f "Microsoft Edge Lite - Habilitado") -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
} else {
    $syncDisabled = 0
    $browserSignin = 1
    $newSmartScreenLibraryEnabled = 1
    $smartScreenEnabled = 1
    $smartScreenPuaEnabled = 1
    $startupBoostEnabled = 1
    $bingAdsSuppression = 0
    $backgroundModeEnabled = 1
    $componentUpdatesEnabled = 1
    $edgeShoppingAssistantEnabled = 1
    $forceGoogleSafeSearch = 0
    $autoUpdateCheckPeriodMinutes = 1440
    $updateDefault = 1
    $updatePolicy = 1
    $doNotUpdateToEdgeWithChromium = 0
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Status") -NoNewline
    Write-Host ("{0,-86} " -f "Microsoft Edge Lite - Desabilitado") -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
}

# Aplicando valores no registro para Edge
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Valor") -NoNewline
Write-Host ("{0,-86} " -f "SyncDisabled = $syncDisabled") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan
$null=New-ItemProperty -Path $edgeKeyPath -Name "SyncDisabled" -PropertyType DWord -Value $syncDisabled -Force

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Valor") -NoNewline
Write-Host ("{0,-86} " -f "BrowserSignin = $browserSignin") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan
$null=New-ItemProperty -Path $edgeKeyPath -Name "BrowserSignin" -PropertyType DWord -Value $browserSignin -Force

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Valor") -NoNewline
Write-Host ("{0,-86} " -f "NewSmartScreenLibraryEnabled = $newSmartScreenLibraryEnabled") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan
$null=New-ItemProperty -Path $edgeKeyPath -Name "NewSmartScreenLibraryEnabled" -PropertyType DWord -Value $newSmartScreenLibraryEnabled -Force

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Valor") -NoNewline
Write-Host ("{0,-86} " -f "SmartScreenEnabled = $smartScreenEnabled") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan
$null=New-ItemProperty -Path $edgeKeyPath -Name "SmartScreenEnabled" -PropertyType DWord -Value $smartScreenEnabled -Force

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Valor") -NoNewline
Write-Host ("{0,-86} " -f "SmartScreenPuaEnabled = $smartScreenPuaEnabled") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan
$null=New-ItemProperty -Path $edgeKeyPath -Name "SmartScreenPuaEnabled" -PropertyType DWord -Value $smartScreenPuaEnabled -Force

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Valor") -NoNewline
Write-Host ("{0,-86} " -f "StartupBoostEnabled = $startupBoostEnabled") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan
$null=New-ItemProperty -Path $edgeKeyPath -Name "StartupBoostEnabled" -PropertyType DWord -Value $startupBoostEnabled -Force

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Valor") -NoNewline
Write-Host ("{0,-86} " -f "BingAdsSuppression = $bingAdsSuppression") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan
$null=New-ItemProperty -Path $edgeKeyPath -Name "BingAdsSuppression" -PropertyType DWord -Value $bingAdsSuppression -Force

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Valor") -NoNewline
Write-Host ("{0,-86} " -f "BackgroundModeEnabled = $backgroundModeEnabled") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan
$null=New-ItemProperty -Path $edgeKeyPath -Name "BackgroundModeEnabled" -PropertyType DWord -Value $backgroundModeEnabled -Force

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Valor") -NoNewline
Write-Host ("{0,-86} " -f "ComponentUpdatesEnabled = $componentUpdatesEnabled") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan
$null=New-ItemProperty -Path $edgeKeyPath -Name "ComponentUpdatesEnabled" -PropertyType DWord -Value $componentUpdatesEnabled -Force

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Valor") -NoNewline
Write-Host ("{0,-86} " -f "EdgeShoppingAssistantEnabled = $edgeShoppingAssistantEnabled") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan
$null=New-ItemProperty -Path $edgeKeyPath -Name "EdgeShoppingAssistantEnabled" -PropertyType DWord -Value $edgeShoppingAssistantEnabled -Force

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Valor") -NoNewline
Write-Host ("{0,-86} " -f "ForceGoogleSafeSearch = $forceGoogleSafeSearch") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan
$null=New-ItemProperty -Path $edgeKeyPath -Name "ForceGoogleSafeSearch" -PropertyType DWord -Value $forceGoogleSafeSearch -Force

# Aplicando valores no registro para EdgeUpdate
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Valor") -NoNewline
Write-Host ("{0,-86} " -f "AutoUpdateCheckPeriodMinutes = $autoUpdateCheckPeriodMinutes") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan
$null=New-ItemProperty -Path $edgeUpdateKeyPath -Name "AutoUpdateCheckPeriodMinutes" -PropertyType DWord -Value $autoUpdateCheckPeriodMinutes -Force

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Valor") -NoNewline
Write-Host ("{0,-86} " -f "UpdateDefault = $updateDefault") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan
$null=New-ItemProperty -Path $edgeUpdateKeyPath -Name "UpdateDefault" -PropertyType DWord -Value $updateDefault -Force

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Valor") -NoNewline
Write-Host ("{0,-86} " -f "UpdatePolicy = $updatePolicy") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan
$null=New-ItemProperty -Path $edgeUpdateKeyPath -Name "UpdatePolicy" -PropertyType DWord -Value $updatePolicy -Force

# Aplicando valores no registro para Microsoft
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Valor") -NoNewline
Write-Host ("{0,-86} " -f "DoNotUpdateToEdgeWithChromium = $doNotUpdateToEdgeWithChromium") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan
$null=New-ItemProperty -Path $microsoftKeyPath -Name "DoNotUpdateToEdgeWithChromium" -PropertyType DWord -Value $doNotUpdateToEdgeWithChromium -Force
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
