<#
    Função: Reparar os ícones do Desktop
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
& $cabecalhoScriptPath -Script $scriptName -Titulo "Reparar ícones do desktop"
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