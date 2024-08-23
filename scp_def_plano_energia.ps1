<#
    Função: Definir plano de energia
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

# Cabecalho
#----------------------------------------------------------------------------------------------
# Obter o diretório do script atual
$scriptName = [System.IO.Path]::GetFileName($MyInvocation.MyCommand.Path)
$CurrentScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path

# Construir o caminho completo para o script 'scp_script_cabecalho.ps1'
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_script_cabecalho.ps1"

& $CabecalhoScriptPath -Script $scriptName -Titulo "Definir plano de energia"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
# Define a política de suspensão para "Nunca"
powercfg /change standby-timeout-ac 0
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Suspender PC") -NoNewline -ForegroundColor White
    Write-Host ("{0,-86} " -f "Nunca") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan

# Define a política de suspensão para "Nunca" quando estiver usando bateria
powercfg /change standby-timeout-dc 0
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Suspender PC (Bateria)") -NoNewline -ForegroundColor White
    Write-Host ("{0,-86} " -f "Nunca") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan

# Desativa o desligamento do monitor ao usar energia AC
powercfg /change monitor-timeout-ac 0
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Desligar Monitor") -NoNewline -ForegroundColor White
    Write-Host ("{0,-86} " -f "Nunca") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan

# Desativa o desligamento do monitor ao usar bateria
powercfg /change monitor-timeout-dc 0
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Desligar Monitor (Bateria)") -NoNewline -ForegroundColor White
    Write-Host ("{0,-86} " -f "Nunca") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan
#----------------------------------------------------------------------------------------------

# Aplicando alterações
#----------------------------------------------------------------------------------------------
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