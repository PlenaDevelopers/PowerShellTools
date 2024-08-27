<#
    Função: Mostrar/Esconder a versão do Windows no Desktop
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
    [string]$valor = "1" #"0" - Não Mostrar | "1" - Mostrar 
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
& $cabecalhoScriptPath -Script $scriptName -Titulo "Habilitar/Desabilitar a visualização da versão do Windows"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
# Defina o caminho do Registro e os valores
$regPath = "HKCU:\Control Panel\Desktop"
$regName = "PaintDesktopVersion"

# Verifique se o parâmetro é válido
if ($valor -ne "0" -and $valor -ne "1") {
    Write-Host "║" -NoNewline -ForegroundColor Red
    Write-Host ("{0,-30} : " -f "Erro") -NoNewline
    Write-Host ("{0,-86} " -f "Parâmetro inválido! Use '0' para Não Mostrar ou '1' para Mostrar") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
    exit
}

# Defina o valor de acordo com o parâmetro
$regValue = [int]$valor

# Verifique se a chave do Registro existe
if (-not (Test-Path $regPath)) {
    # Crie a chave do Registro se não existir
    $null=New-Item -Path $regPath -Force
}

# Atualize ou crie o valor do Registro
Write-Host "║" -NoNewline -ForegroundColor Cyan
if ($regValue -eq 1) {
    Write-Host ("{0,-30} : " -f "Status") -NoNewline
    Write-Host ("{0,-86} " -f "Ativar") -NoNewline -ForegroundColor White
} else {
    Write-Host ("{0,-30} : " -f "Satus") -NoNewline
    Write-Host ("{0,-86} " -f "Desativar") -NoNewline -ForegroundColor White
}
Write-Host "║" -ForegroundColor Cyan

$null=Set-ItemProperty -Path $regPath -Name $regName -Value $regValue
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