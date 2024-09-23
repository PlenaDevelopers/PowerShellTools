<#
    Função: Habilitar ou desabilitar o serviço Office Click-to-Run
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

param (
    [string]$Action = "disable"  # Padrão: habilitar o serviço. Pode ser 'enable' ou 'disable'.
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
& $cabecalhoScriptPath -Script $scriptName -Titulo "Habilitar ou desabilitar o serviço Office Click-to-Runs"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
$serviceName = "ClickToRunSvc"

function Check-Service {
    $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
    if ($null -eq $service) {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Status") -NoNewline -ForegroundColor Yellow
        Write-Host ("{0,-86} " -f "O serviço Click-to-Run não foi localizado") -NoNewline -ForegroundColor Red
        Write-Host "║" -ForegroundColor Cyan

        return $false
    }
    return $true
}

function Enable-ClickToRun {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Status") -NoNewline -ForegroundColor Yellow
    Write-Host ("{0,-86} " -f "Habilitando o serviço Office Click-to-Run...") -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan

    Set-Service -Name $serviceName -StartupType Automatic
    Start-Service -Name $serviceName

    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Status") -NoNewline -ForegroundColor Yellow
    Write-Host ("{0,-86} " -f "Serviço Office Click-to-Run habilitado com sucesso!") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan
}

function Disable-ClickToRun {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Status") -NoNewline -ForegroundColor Yellow
    Write-Host ("{0,-86} " -f "Desabilitando o serviço Office Click-to-Run...") -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan

    Stop-Service -Name $serviceName -Force
    Set-Service -Name $serviceName -StartupType Disabled

    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Status") -NoNewline -ForegroundColor Yellow
    Write-Host ("{0,-86} " -f "Serviço Office Click-to-Run desabilitado com sucesso!") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan
}

# Verifica se o serviço existe
if (Check-Service) {
    # Verifica a ação desejada e executa
    switch ($Action.ToLower()) {
        "enable" {
            Enable-ClickToRun
        }
        "disable" {
            Disable-ClickToRun
        }
        default {
            Write-Host "║" -NoNewline -ForegroundColor Cyan
            Write-Host ("{0,-30} : " -f "Status") -NoNewline -ForegroundColor Yellow
            Write-Host ("{0,-86} " -f "Ação desconhecida. Use 'enable' para habilitar ou 'disable' para desabilitar o serviço.") -NoNewline -ForegroundColor Red
            Write-Host "║" -ForegroundColor Cyan
        }
    }
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Status") -NoNewline -ForegroundColor Yellow
    Write-Host ("{0,-86} " -f "Serviço não encontrado. Verifique se o Office Click-to-Run está instalado.") -NoNewline -ForegroundColor Red
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
