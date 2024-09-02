<#
    Função: Limpar as configurações do Anydesk
    Copyright: © Plena Soluções - 2024
    Date: Setembro/2024

    Licenciamento:
    Este script é fornecido "como está", sem qualquer garantia de qualquer tipo,
    expressa ou implícita, incluindo, mas não se limitando às garantias de 
    comercialização, adequação a um determinado fim e não violação. O uso deste 
    script é totalmente gratuito, mas você deve manter os créditos ao autor original.
    
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
& $cabecalhoScriptPath -Script $scriptName -Titulo "Limpar as configurações do Anydesk"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
# Função para encerrar o processo AnyDesk
function Encerrar-AnyDesk {
    $processName = "AnyDesk"
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Encerrando Processo") -NoNewline -ForegroundColor White
    Write-Host ("{0,-86} " -f $processName) -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan

    try {
        Stop-Process -Name $processName -Force -ErrorAction Stop
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Processo Encerrado") -NoNewline -ForegroundColor White
        Write-Host ("{0,-86} " -f $processName) -NoNewline -ForegroundColor Green
        Write-Host "║" -ForegroundColor Cyan
    } catch {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Erro ao Encerrar") -NoNewline -ForegroundColor Yellow
        Write-Host ("{0,-86} " -f "Erro ao tentar encerrar o processo $processName.") -NoNewline -ForegroundColor Red
        Write-Host "║" -ForegroundColor Cyan
    }
}

# Função para remover uma pasta e seu conteúdo
function Remove-Folder {
    param (
        [string]$folderPath
    )

    if (Test-Path $folderPath) {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Removendo Pasta") -NoNewline -ForegroundColor White
        Write-Host ("{0,-86} " -f $folderPath) -NoNewline -ForegroundColor Green
        Write-Host "║" -ForegroundColor Cyan

        try {
            Remove-Item -Path $folderPath -Recurse -Force
            Write-Host "║" -NoNewline -ForegroundColor Cyan
            Write-Host ("{0,-30} : " -f "Pasta Removida") -NoNewline -ForegroundColor White
            Write-Host ("{0,-86} " -f $folderPath) -NoNewline -ForegroundColor Green
            Write-Host "║" -ForegroundColor Cyan
        } catch {
            Write-Host "║" -NoNewline -ForegroundColor Cyan
            Write-Host ("{0,-30} : " -f "Erro ao Remover") -NoNewline -ForegroundColor Yellow
            Write-Host ("{0,-86} " -f "Erro ao tentar remover a pasta $folderPath.") -NoNewline -ForegroundColor Red
            Write-Host "║" -ForegroundColor Cyan
        }
    } else {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Pasta Não Encontrada") -NoNewline -ForegroundColor Yellow
        Write-Host ("{0,-86} " -f $folderPath) -NoNewline -ForegroundColor Red
        Write-Host "║" -ForegroundColor Cyan
    }
}

# Caminho das pastas AnyDesk usando diretório relativo
$programDataPath = Join-Path -Path $env:PROGRAMDATA -ChildPath "AnyDesk"
$userAppDataPath = Join-Path -Path $env:APPDATA -ChildPath "AnyDesk"

# Encerrar o AnyDesk se estiver em execução
Encerrar-AnyDesk

# Remover pastas
Remove-Folder -folderPath $programDataPath
Remove-Folder -folderPath $userAppDataPath
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
