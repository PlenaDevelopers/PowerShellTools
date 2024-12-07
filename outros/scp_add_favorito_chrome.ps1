<#
    Função: Adicionar favoritos ao Google Chrome
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
# Parâmetro de entrada
Param (
    [string]$Chave = "XQNVK-8JYDB-WJ9W3-YJ8YR-WFG99", # Chave padrão
    [string]$KmsServer = "e8.us.to", # Servidor KMS. Use kms.core.windows.net (Original da Microsoft)
    [string]$KmsPort = 1688 # Porta do servidor KMS. Use 1688 (Original da Microsoft)
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
& $cabecalhoScriptPath -Script $scriptName -Titulo "Adicionar favoritos ao Google Chrome"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------

# Caminho para o arquivo de favoritos do Chrome
$bookmarksPath = "C:\users\$env:userprofile\appdata\local\google\chrome\default\bookmarks"

# Caminho para o arquivo CSV contendo os novos favoritos
$csvPath = "\\server\share\repository\chromebookmarks.csv"

# Verifica se o arquivo de favoritos do Chrome existe
if (-not (Test-Path $bookmarksPath)) {
    Write-Host "Arquivo de favoritos do Chrome não encontrado." -ForegroundColor Red
    exit
}

# Faz o backup do arquivo de favoritos existente
Copy-Item -Path $bookmarksPath -Destination "$bookmarksPath.bak" -Force

# Lê o arquivo de favoritos e o arquivo CSV
$bookmarks = Get-Content $bookmarksPath | ConvertFrom-Json
$data = Import-Csv $csvPath

# Adiciona os novos favoritos à barra de favoritos
$bookmarks.roots.bookmark_bar.children += $data

# Salva o arquivo JSON atualizado de volta
$bookmarks | ConvertTo-Json -Depth 10 | Set-Content -Path $bookmarksPath -Encoding UTF8 -Force

Write-Host "Favoritos adicionados com sucesso." -ForegroundColor Green
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
