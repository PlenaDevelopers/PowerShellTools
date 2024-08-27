<#
    Função: Backup do Sistema
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
& $cabecalhoScriptPath -Script $scriptName -Titulo "Iniciar o backup do sistema"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
# Obtém a data e hora atual
$dataHoraAtual = Get-Date -Format "dd/MM/yyyy-HH:mm:ss"

# Define a descrição para o ponto de restauração
$descricaoPontoRestauracao = "$dataHoraAtual - Ponto de Restauração by Plena Souções"

function Test-ServiceExists {
    param (
        [string]$serviceName
    )

    try {
        $service = Get-Service -Name $serviceName -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

$serviceName = "srservice"  # Substitua pelo nome do serviço desejado
if (Test-ServiceExists -serviceName $serviceName) {
    # Tenta criar um ponto de restauração do sistema
    try {
        $null = Checkpoint-Computer -Description $descricaoPontoRestauracao -RestorePointType "MODIFY_SETTINGS"
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Tarefa") -NoNewline -ForegroundColor White
        Write-Host ("{0,-86} " -f "Ponto de Restauração criado com sucesso") -NoNewline -ForegroundColor Green
        Write-Host "║" -ForegroundColor Cyan
        }
        catch {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Erro") -NoNewline -ForegroundColor White
        Write-Host ("{0,-86} " -f "Erro ao criar ponto de restauração: $_") -NoNewline -ForegroundColor Red
        Write-Host "║" -ForegroundColor Cyan
        }
} else {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Erro") -NoNewline -ForegroundColor White
        Write-Host ("{0,-86} " -f "O serviço $serviceName não existe.") -NoNewline -ForegroundColor Red
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