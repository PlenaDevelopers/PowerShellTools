<#
    Função: Atualizar as versões do Visual C Runtimes
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
& $cabecalhoScriptPath -Script $scriptName -Titulo "Atualizar o Microsoft Visul C Runtimes"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
# Obtém o diretório atual do script
$currentScriptDirectory = $PSScriptRoot
# Adiciona o subdiretório "updates"
$updatesDirectory = Join-Path $currentScriptDirectory "updates\visual_runtimes"
# Se precisar do caminho completo do script
$currentScriptPath = $MyInvocation.MyCommand.Path

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Diretorio das Atualizações") -NoNewline
Write-Host ("{0,-86} "   -f $updatesDirectory) -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan

Write-Host "╠" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
write-host "╣" -ForegroundColor Cyan

# Visual C 2005
#----------------------------------------------------------------------------------------------
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Instalando") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "Visual C 2005") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan

$vcredist2005Path = Join-Path $updatesDirectory "vcredist2005_x64.exe"

if (Test-Path $vcredist2005Path) {
    Start-Process -FilePath $vcredist2005Path -ArgumentList "/q" -Wait
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Aviso") -NoNewline -ForegroundColor Yellow
    Write-Host ("{0,-86} " -f "Visual C 2005 não encontrado no diretório.") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
}

# Visual C 2008
#----------------------------------------------------------------------------------------------
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Instalando") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "Visual C 2008") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan

$vcredist2008Path = Join-Path $updatesDirectory "vcredist2008_x64.exe"

if (Test-Path $vcredist2008Path) {
    Start-Process -FilePath $vcredist2008Path -ArgumentList "/q" -Wait
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Aviso") -NoNewline -ForegroundColor Yellow
    Write-Host ("{0,-86} " -f "Visual C 2008 não encontrado no diretório.") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
}

# Visual C 2010
#----------------------------------------------------------------------------------------------
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Instalando") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "Visual C 2010") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan

$vcredist2010Path = Join-Path $updatesDirectory "vcredist2010_x64.exe"

if (Test-Path $vcredist2010Path) {
    Start-Process -FilePath $vcredist2010Path -ArgumentList "/q" -Wait
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Aviso") -NoNewline -ForegroundColor Yellow
    Write-Host ("{0,-86} " -f "Visual C 2010 não encontrado no diretório.") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
}

# Visual C 2012
#----------------------------------------------------------------------------------------------
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Instalando") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "Visual C 2012") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan

$vcredist2012Path = Join-Path $updatesDirectory "vcredist2012_x64.exe"

if (Test-Path $vcredist2012Path) {
    Start-Process -FilePath $vcredist2012Path -ArgumentList "/q" -Wait
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Aviso") -NoNewline -ForegroundColor Yellow
    Write-Host ("{0,-86} " -f "Visual C 2012 não encontrado no diretório.") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
}

# Visual C 2013
#----------------------------------------------------------------------------------------------
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Instalando") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "Visual C 2013") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan

$vcredist2013Path = Join-Path $updatesDirectory "vcredist2013_x64.exe"

if (Test-Path $vcredist2013Path) {
    Start-Process -FilePath $vcredist2013Path -ArgumentList "/q" -Wait
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Aviso") -NoNewline -ForegroundColor Yellow
    Write-Host ("{0,-86} " -f "Visual C 2013 não encontrado no diretório.") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
}

# Visual C 2015 / 2017 / 2019 / 2022
#----------------------------------------------------------------------------------------------
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Instalando") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "Visual C 2015 / 2017 / 2019 / 2022") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan

$vcredist2015_2022Path = Join-Path $updatesDirectory "vcredist2015_2017_2019_2022_x64.exe"

if (Test-Path $vcredist2015_2022Path) {
    Start-Process -FilePath $vcredist2015_2022Path -ArgumentList "/q" -Wait
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Aviso") -NoNewline -ForegroundColor Yellow
    Write-Host ("{0,-86} " -f "Visual C 2015 / 2017 / 2019 / 2022 não encontrado no diretório.") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
}

# Visual C Universal
#----------------------------------------------------------------------------------------------
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Instalando") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "Visual C Universal") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan

$visualCUniversalPath = Join-Path $updatesDirectory "Windows8.1-KB2999226-x64.msu"

if (Test-Path $visualCUniversalPath) {
    Start-Process -FilePath $visualCUniversalPath -ArgumentList "/quiet" -Wait
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Aviso") -NoNewline -ForegroundColor Yellow
    Write-Host ("{0,-86} " -f "Visual C Universal não encontrado no diretório.") -NoNewline -ForegroundColor Red
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