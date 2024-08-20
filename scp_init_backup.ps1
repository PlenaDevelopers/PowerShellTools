# Script para efetuar Backup do Sistema

# Cabecalho
#----------------------------------------------------------------------------------------------
# Obter o diretório do script atual
$scriptName = [System.IO.Path]::GetFileName($MyInvocation.MyCommand.Path)
$CurrentScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path

# Construir o caminho completo para o script 'scp_script_cabecalho.ps1'
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_script_cabecalho.ps1"

& $CabecalhoScriptPath -Script $scriptName -Titulo "Backup do sistema"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
# Obtém a data e hora atual
$dataHoraAtual = Get-Date -Format "dd/MM/yyyy-HH:mm:ss"

# Define a descrição para o ponto de restauração
$descricaoPontoRestauracao = "$dataHoraAtual - Ponto de Restauração by Plena Souções"

function Test-ServiceExists {
    param (
        [string]$serviceName
    )

    try {
        $service = Get-Service -Name $serviceName -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

$serviceName = "srservice"  # Substitua pelo nome do serviço desejado
if (Test-ServiceExists -serviceName $serviceName) {
    # Tenta criar um ponto de restauração do sistema
    try {
        $null = Checkpoint-Computer -Description $descricaoPontoRestauracao -RestorePointType "MODIFY_SETTINGS"
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Tarefa") -NoNewline -ForegroundColor White
        Write-Host ("{0,-86} " -f "Ponto de Restauração criado com sucesso") -NoNewline -ForegroundColor Green
        Write-Host "║" -ForegroundColor Cyan
        }
        catch {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Erro") -NoNewline -ForegroundColor White
        Write-Host ("{0,-86} " -f "Erro ao criar ponto de restauração: $_") -NoNewline -ForegroundColor Red
        Write-Host "║" -ForegroundColor Cyan
        }
} else {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Erro") -NoNewline -ForegroundColor White
        Write-Host ("{0,-86} " -f "O serviço $serviceName não existe.") -NoNewline -ForegroundColor Red
        Write-Host "║" -ForegroundColor Cyan
}
#----------------------------------------------------------------------------------------------

# Aplicando alterações
#----------------------------------------------------------------------------------------------
# Aplicar alterações
rundll32.exe user32.dll, UpdatePerUserSystemParameters
#----------------------------------------------------------------------------------------------

# Rodape
#----------------------------------------------------------------------------------------------
# Obter o diretório do script atual
$CurrentScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path

# Construir o caminho completo para o script 'scp_script_rodape.ps1'
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_script_rodape.ps1"

& $CabecalhoScriptPath
#----------------------------------------------------------------------------------------------