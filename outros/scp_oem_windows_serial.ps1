<#
    Função: Script para recuperar o serial do Windows da BIOS
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
    analisar e gerar atualizações corretivas.

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
& $cabecalhoScriptPath -Script $scriptName -Titulo "Script para recuperar o serial do Windows da BIOS"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
$osVersion = (Get-WmiObject -Class Win32_OperatingSystem).Caption
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Sistema Operacional") -NoNewline
Write-Host ("{0,-86} " -f $osVersion) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

try {
    $oemKey = (Get-WmiObject -Query 'SELECT * FROM SoftwareLicensingService').OA3xOriginalProductKey

    if ($oemKey) {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Serial") -NoNewline
        Write-Host ("{0,-86} " -f $oemKey) -NoNewline -ForegroundColor White
        Write-Host "║" -ForegroundColor Cyan
    } else {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Serial") -NoNewline
        Write-Host ("{0,-86} " -f "Serial OEM não encontrado") -NoNewline -ForegroundColor White
        Write-Host "║" -ForegroundColor Cyan
    }
} catch {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Serial (Erro)") -NoNewline
    Write-Host ("{0,-86} " -f $_.Exception.Message) -NoNewline -ForegroundColor White
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