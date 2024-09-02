<#
    Função: Limpar Logs de Eventos do Windows
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
    [string]$TipoLog = "Setup" #"System", "Security", "Application", "Setup", "ForwardedEvents"
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
& $cabecalhoScriptPath -Script $scriptName -Titulo "Limpar Logs de Eventos do Windows"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
# Função para limpar logs
function LimparLog {
    param (
        [string]$logName
    )
    
    # Verifica se o log existe
    if (Get-WinEvent -ListLog $logName -ErrorAction SilentlyContinue) {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Limpando Log") -NoNewline -ForegroundColor White
        Write-Host ("{0,-86} " -f $logName) -NoNewline -ForegroundColor Green
        Write-Host "║" -ForegroundColor Cyan

        try {
            # Tratamento específico para logs
            if ($logName -eq "ForwardedEvents") {
                # Para "ForwardedEvents", usa Clear-WinEvent
                Clear-WinEvent -LogName $logName
            } elseif ($logName -eq "Setup") {
                # Para "Setup", usar um tratamento diferente
                Write-Host "║" -NoNewline -ForegroundColor Cyan
                Write-Host ("{0,-30} : " -f "Log Setup") -NoNewline -ForegroundColor Yellow
                Write-Host ("{0,-86} " -f "Não pode ser limpo diretamente.") -NoNewline -ForegroundColor Red
                Write-Host "║" -ForegroundColor Cyan
            } else {
                # Para outros logs
                Clear-EventLog -LogName $logName
            }

            Write-Host "║" -NoNewline -ForegroundColor Cyan
            Write-Host ("{0,-30} : " -f "Log Limpo") -NoNewline -ForegroundColor White
            Write-Host ("{0,-86} " -f $logName) -NoNewline -ForegroundColor Green
            Write-Host "║" -ForegroundColor Cyan
        } catch {
            Write-Host "║" -NoNewline -ForegroundColor Cyan
            Write-Host ("{0,-30} : " -f "Erro ao Limpar Log") -NoNewline -ForegroundColor Yellow
            Write-Host ("{0,-86} " -f "Erro ao tentar limpar o log $logName.") -NoNewline -ForegroundColor Red
            Write-Host "║" -ForegroundColor Cyan
        }
    } else {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Log Não Encontrado") -NoNewline -ForegroundColor Yellow
        Write-Host ("{0,-86} " -f $logName) -NoNewline -ForegroundColor Red
        Write-Host "║" -ForegroundColor Cyan
    }
}

# Tipos de log suportados
$tiposLogSuportados = @("System", "Security", "Application", "Setup", "ForwardedEvents")

# Verifica se o tipo de log fornecido é válido
if ($tiposLogSuportados -contains $TipoLog) {
    LimparLog -logName $TipoLog
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Tipo de Log Inválido") -NoNewline -ForegroundColor Yellow
    Write-Host ("{0,-86} " -f "$TipoLog não é um tipo de log válido. Os tipos válidos são: System, Security, Application, Setup, ForwardedEvents.") -NoNewline -ForegroundColor Red
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
