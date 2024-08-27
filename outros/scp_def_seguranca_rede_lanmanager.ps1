<#
    Função: Definir a segurança LanManager
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
    [int]$Option = 0
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
& $cabecalhoScriptPath -Script $scriptName -Titulo "Definir a segurança LanManager"
#----------------------------------------------------------------------------------------------


# Opções disponíveis para o Nível de Autenticação LAN Manager
$OptionsMap = @{
    0 = "Enviar LM e NTLM - Usar NTLMv2 de sessão se negociado"
    1 = "Enviar LM e NTLM - Usar a autenticação de segurança de NTLMv2 se negociado; recusar LM"
    2 = "Enviar NTLMv2 resposta apenas"
    3 = "Enviar NTLMv2 resposta apenas / recusar LM & NTLM"
    4 = "Enviar NTLMv2 resposta somente / recusar LM & NTLM / Refuse NTLM"
    5 = "Enviar NTLMv2 resposta somente / recusar LM & NTLM / Refuse NTLM & LM"
}

# Verifica se a opção fornecida é válida
if (-not $OptionsMap.ContainsKey($Option)) {
    Write-Host "Opção inválida. Por favor, escolha um número entre 0 e 5."
    exit
}

# Define o valor do registro com base na opção escolhida
$RegValue = @{
    0 = 1
    1 = 2
    2 = 3
    3 = 4
    4 = 5
    5 = 6
}[$Option]

# Obtém a descrição correspondente a partir do OptionsMap
$Description = $OptionsMap[$RegValue]

# Exibe a saída formatada no Write-Host
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Valor") -NoNewline
Write-Host ("{0,-86} " -f ("$Description")) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

# Define o caminho do registro
$RegPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"

# Define o nome do valor do registro
$RegName = "LmCompatibilityLevel"

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Chave") -NoNewline
Write-Host ("{0,-86} " -f $RegPath) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

# Define o valor do registro
Set-ItemProperty -Path $RegPath -Name $RegName -Value $RegValue -Force
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Valor") -NoNewline
Write-Host ("{0,-86} " -f ("LmCompatibilityLevel: $RegValue")) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan
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