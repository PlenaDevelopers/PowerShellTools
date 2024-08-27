<#
    Função: Limpar o Navegador Mozilla Firefox
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
& $cabecalhoScriptPath -Script $scriptName -Titulo "Limpar o Navegador Mozilla Firefox"
#----------------------------------------------------------------------------------------------

# Verificar se o Mozilla Firefox está instalado
$firefoxInstalled = Test-Path "C:\Program Files\Mozilla Firefox\firefox.exe"

if ($firefoxInstalled) {
    # Encerrar processos do Mozilla Firefox
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Status") -NoNewline -ForegroundColor cyan
    Write-Host ("{0,-86} " -f "Encerrando o Mozilla Firefox") -NoNewline -ForegroundColor cyan
    Write-Host "║" -ForegroundColor Cyan
    $null=Stop-Process -Name "firefox" -Force -ErrorAction SilentlyContinue

    # Remover diretório de dados do Mozilla Firefox (isso irá redefinir todas as configurações)
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Status") -NoNewline -ForegroundColor cyan
    Write-Host ("{0,-86} " -f "Limpando diretórios") -NoNewline -ForegroundColor cyan
    Write-Host "║" -ForegroundColor Cyan
    $firefoxDataDir = [System.IO.Path]::Combine($env:APPDATA, 'Mozilla\Firefox\Profiles')
    $null=Remove-Item -Path $firefoxDataDir -Recurse -Force -ErrorAction SilentlyContinue
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Status") -NoNewline -ForegroundColor cyan
    Write-Host ("{0,-86} " -f "Mozilla Firefox não está instalado.") -NoNewline -ForegroundColor cyan
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