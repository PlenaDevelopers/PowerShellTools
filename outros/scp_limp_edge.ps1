<#
    Função: Limpar o Navegador Microsoft Edge
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
& $cabecalhoScriptPath -Script $scriptName -Titulo "Limpar o Navegador Microsoft Edge"
#----------------------------------------------------------------------------------------------
# Verificar se o Microsoft Edge está instalado
$edgeInstalled = Test-Path "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"

if ($edgeInstalled) {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Microsoft Edge Instalado") -NoNewline -ForegroundColor White
    Write-Host ("{0,-86} " -f "Limpando Configurações" ) -NoNewline -ForegroundColor Gray
    Write-Host "║" -ForegroundColor Cyan

    # Encerrar processos do Microsoft Edge
    $null=Stop-Process -Name "msedge" -Force -ErrorAction SilentlyContinue

    # Remover diretório de dados do Microsoft Edge (isso irá redefinir todas as configurações)
    $edgeDataDir = [System.IO.Path]::Combine($env:LOCALAPPDATA, 'Microsoft\Edge\User Data')
    $null=Remove-Item -Path $edgeDataDir -Recurse -Force -ErrorAction SilentlyContinue

    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Microsoft Edge") -NoNewline -ForegroundColor White
    Write-Host ("{0,-86} " -f "Configurações Excluídas" ) -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Microsoft Edge") -NoNewline -ForegroundColor White
    Write-Host ("{0,-86} " -f "Não está instalado" ) -NoNewline -ForegroundColor Yellow
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