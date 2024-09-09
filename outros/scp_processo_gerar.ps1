<#
    Função: Gerar processos
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

param (
    [string]$ProcessName = "notepad.exe",
    [int]$ProcessCount = 50
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
& $cabecalhoScriptPath -Script $scriptName -Titulo "Gerar processos"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
# Verifica se o nome do processo foi fornecido
if (-not $ProcessName) {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Erro") -NoNewline
    Write-Host ("{0,-86} " -f "Nome do processo não fornecido") -NoNewline -ForegroundColor DarkMagenta 
    Write-Host "║" -ForegroundColor Cyan
    exit
}

# Verifica se a quantidade de processos é válida
if (-not $ProcessCount -or $ProcessCount -le 0) {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Erro") -NoNewline
    Write-Host ("{0,-86} " -f "Quantidade de processos inválida") -NoNewline -ForegroundColor DarkMagenta 
    Write-Host "║" -ForegroundColor Cyan
    exit
}

# Cria os processos
for ($i = 1; $i -le $ProcessCount; $i++) {
    try {
        Start-Process $ProcessName
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Status") -NoNewline
        Write-Host ("{0,-86} " -f "Processo $ProcessName iniciado ($i de $ProcessCount)") -NoNewline -ForegroundColor Green
        Write-Host "║" -ForegroundColor Cyan
    } catch {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Erro") -NoNewline
        Write-Host ("{0,-86} " -f "Falha ao iniciar o processo $ProcessName") -NoNewline -ForegroundColor Red
        Write-Host "║" -ForegroundColor Cyan
    }
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