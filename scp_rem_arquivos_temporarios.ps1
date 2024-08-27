<#
    Função: Limpar arquivos temporários
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
& $cabecalhoScriptPath -Script $scriptName -Titulo "Limpar arquivos temporários"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
# Caminhos para limpeza
$paths = @(
    "$env:TEMP\*",
    [System.IO.Path]::Combine($env:LOCALAPPDATA, 'Microsoft\Windows\INetCache'),
    [System.IO.Path]::Combine($env:LOCALAPPDATA, 'Packages'),
    'C:\Windows\SoftwareDistribution\Download',
    'C:\Users\Public\AppData\Local\Microsoft\Windows\Explorer',
    'C:\Windows\Logs',
    [System.IO.Path]::Combine($env:LOCALAPPDATA, 'Temp'),
    [System.IO.Path]::Combine($env:LOCALAPPDATA, 'Apps')
)

foreach ($path in $paths) {
    # Obter arquivos e pastas no caminho especificado
    $items = Get-ChildItem -Path $path -ErrorAction SilentlyContinue -Recurse
    foreach ($item in $items) {
        try {
            # Tentar remover o item
            Remove-Item -Path $item.FullName -Force -Recurse -ErrorAction Stop
        } catch {
            # Ignorar erros ao tentar remover o item
        }
    }
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Pasta") -NoNewline -ForegroundColor White
    Write-Host ("{0,-86} " -f $path) -NoNewline -ForegroundColor White
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