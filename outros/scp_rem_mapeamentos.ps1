<#
    Função: Remover Todos os Mapeamentos de Rede
	Copyright: © Plena Soluções - 2024
	Date: Setembro/2024

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
& $cabecalhoScriptPath -Script $scriptName -Titulo "Remover Todos os Mapeamentos de Rede"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Ação") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "Remover Mapeamentos de Rede") -NoNewline -ForegroundColor Cyan
Write-Host "║" -ForegroundColor Cyan

# Obter a lista de mapeamentos de rede
try {
    $smbMappings = Get-SmbMapping
} catch {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Erro") -NoNewline -ForegroundColor Red
    Write-Host ("{0,-86} " -f "Não foi possível obter a lista de mapeamentos.") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
    exit
}

if ($smbMappings.Count -eq 0) {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Aviso") -NoNewline -ForegroundColor Yellow
    Write-Host ("{0,-86} " -f "Nenhum mapeamento de rede encontrado.") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
} else {
    foreach ($mapping in $smbMappings) {
        $localPath = $mapping.LocalPath

        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Removendo") -NoNewline -ForegroundColor White
        Write-Host ("{0,-86} " -f "$localPath") -NoNewline -ForegroundColor Yellow
        Write-Host "║" -ForegroundColor Cyan

        try {
            Remove-SmbMapping -LocalPath $localPath -Force
        } catch {
            Write-Host "║" -NoNewline -ForegroundColor Cyan
            Write-Host ("{0,-30} : " -f "Erro") -NoNewline -ForegroundColor Red
            Write-Host ("{0,-86} " -f "Não é possível remover a unidade $localPath.") -NoNewline -ForegroundColor Red
            Write-Host "║" -ForegroundColor Cyan
        }
    }

    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Concluído") -NoNewline -ForegroundColor White
    Write-Host ("{0,-86} " -f "Todos os mapeamentos de rede foram removidos.") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan
}
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