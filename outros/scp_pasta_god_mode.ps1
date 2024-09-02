<#
    Função: Criar pasta God Mode
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
    analisar e gerar atualizações corretivas.

    Autor: Evandro Campanhã
    Contato: aurora.erp@gmail.com
    ------------------------------------------------------------------------------
#>

param(
    [string]$pasta = "C:\Temp\JPG",
    [string]$formatoEntrada = "jpg",
    [string]$formatoSaida = "bmp"
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
& $cabecalhoScriptPath -Script $scriptName -Titulo "Criar pasta God Mode"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
# Defina o nome da pasta e o caminho da área de trabalho
$nomePasta = "GodMode.{ED7BA470-8E54-465E-825C-99712043E01C}"
$caminhoAreaDeTrabalho = [System.IO.Path]::Combine([System.Environment]::GetFolderPath("Desktop"), $nomePasta)

# Crie a pasta GodMode na área de trabalho
if (-Not (Test-Path -Path $caminhoAreaDeTrabalho)) {
    try {
        New-Item -Path $caminhoAreaDeTrabalho -ItemType Directory -Force | Out-Null
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Sucesso") -NoNewline
        Write-Host ("{0,-86} " -f "Pasta GodMode criada com sucesso na área de trabalho.") -NoNewline -ForegroundColor Green
        Write-Host "║" -ForegroundColor Cyan
    } catch {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Erro") -NoNewline
        Write-Host ("{0,-86} " -f "Não foi possível criar a pasta GodMode: $_") -NoNewline -ForegroundColor Red
        Write-Host "║" -ForegroundColor Cyan
    }
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Aviso") -NoNewline
    Write-Host ("{0,-86} " -f "A pasta GodMode já existe na área de trabalho.") -NoNewline -ForegroundColor Yellow
    Write-Host "║" -ForegroundColor Cyan
}

# Informar o usuário sobre a criação
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Instrução") -NoNewline
Write-Host ("{0,-86} " -f "Abra a pasta para acessar todas as configurações do Windows.") -NoNewline -ForegroundColor Green
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
