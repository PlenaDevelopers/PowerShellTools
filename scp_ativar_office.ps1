<#
    Função: Ativar o Microsoft Office 365
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
& $cabecalhoScriptPath -Script $scriptName -Titulo "Ativar o Microsoft Office 365"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
# Definindo as variáveis de diretório base para Office 64 bits e 32 bits
$Office64Path = "${env:ProgramFiles}\Microsoft Office\Office16"
$Office32Path = "${env:ProgramFiles(x86)}\Microsoft Office\Office16"

# Verificando se o diretório do Office 64 bits existe
if (Test-Path $Office64Path) {
    Set-Location -Path $Office64Path
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Diretório do Office(x64)") -NoNewline
    Write-Host ("{0,-86} " -f $Office64Path) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
}
# Verificando se o diretório do Office 32 bits existe
elseif (Test-Path $Office32Path) {
    Set-Location -Path $Office32Path
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Diretório do Office(x86)") -NoNewline
    Write-Host ("{0,-86} " -f $Office32Path) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
}
else {
    # Rodape para Office não encontrado
    #----------------------------------------------------------------------------------------------
    Write-Host "╠" -NoNewline -ForegroundColor Cyan
    Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
    Write-Host "╣" -ForegroundColor Cyan  

    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Processo") -NoNewline
    Write-Host ("{0,-86} " -f "Finalizado") -NoNewline -ForegroundColor Cyan
    Write-Host "║" -ForegroundColor Cyan

    Write-Host "╚" -NoNewline -ForegroundColor Cyan
    Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
    Write-Host "╝" -ForegroundColor Cyan
    exit
}

# Inserindo as licenças KMS
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Inserindo Chave") -NoNewline
Write-Host ("{0,-86} " -f $Chave) -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan

Get-ChildItem -Path "..\root\Licenses16" -Filter "proplusvl_kms*.xrm-ms" | ForEach-Object {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Executando") -NoNewline
    Write-Host ("{0,-86} " -f $($_.FullName)) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
    $null = & cscript ospp.vbs /inslic:"$($_.FullName)"
}

# Inserindo a chave de produto
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Chave") -NoNewline
Write-Host ("{0,-86} " -f $Chave) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan
$null=& cscript ospp.vbs /inpkey:$Chave

# Removendo chaves antigas
$OldKeys = @("BTDRB", "KHGM9", "CPQVG")
foreach ($Key in $OldKeys) {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Remover chave") -NoNewline
    Write-Host ("{0,-86} " -f $Key) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
    & cscript ospp.vbs /unpkey:$Key > $null
}

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Servidor KMS") -NoNewline
Write-Host ("{0,-86} " -f $KmsServer) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Porta KMS") -NoNewline
Write-Host ("{0,-86} " -f $KmsPort) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

$null = & cscript ospp.vbs /sethst:$KmsServer
$null = & cscript ospp.vbs /setprt:$KmsPort

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Operação") -NoNewline
Write-Host ("{0,-86} " -f "Ativando") -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

$null = & cscript ospp.vbs /act

# Verificando se o Office está ativado
$ActivationStatus = & cscript ospp.vbs /dstatus

# Interpretando a saída para verificar o status de ativação
if ($ActivationStatus -match "LICENSE STATUS:  ---LICENSED---") {
    Write-Host "╠" -NoNewline -ForegroundColor Cyan
    Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
    Write-Host "╣" -ForegroundColor Cyan

    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Status de Ativação") -NoNewline
    Write-Host ("{0,-86} " -f "O Office está ativado com sucesso!") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan
} else {
    Write-Host "╠" -NoNewline -ForegroundColor Cyan
    Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
    Write-Host "╣" -ForegroundColor Cyan

    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Status de Ativação") -NoNewline
    Write-Host ("{0,-86} " -f "Falha na ativação do Office. Verifique os detalhes.") -NoNewline -ForegroundColor Red
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