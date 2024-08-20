# Script para ativar o "Suporte a Compartilhamentos de Arquivos SMBv1"

# Cabecalho
#----------------------------------------------------------------------------------------------
# Obter o diretório do script atual
$scriptName = [System.IO.Path]::GetFileName($MyInvocation.MyCommand.Path)
$CurrentScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path

# Construir o caminho completo para o script 'scp_script_cabecalho.ps1'
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_script_cabecalho.ps1"

& $CabecalhoScriptPath -Script $scriptName -Titulo "Suporte a Compartilhamentos de Arquivos SMBv1"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
# Obter o status do SMBv1
$featureStatus = Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol

# Verificar se o SMBv1 está habilitado
if ($featureStatus.State -eq 'Enabled') {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "SMB Versão 1") -NoNewline
    Write-Host ("{0,-86} " -f "Já está habilitado") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan
}
else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "SMB Versão 1") -NoNewline
    Write-Host ("{0,-86} " -f "Não está habilitado") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan

    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Tarefa") -NoNewline -ForegroundColor cyan
    Write-Host ("{0,-86} " -f "Habilitar o Serviço") -NoNewline -ForegroundColor cyan
    Write-Host "║" -ForegroundColor Cyan

    Write-Host "║" -NoNewline -ForegroundColor Cyan
    write-host ("═" * 120) -NoNewline -ForegroundColor gray
    Write-Host "║" -ForegroundColor Cyan

    # Habilitar o recurso sem reiniciar e suprimir mensagens de aviso
    $null = Enable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -All -NoRestart 2>&1
    
    # Obter o status do SMBv1
    $featureStatus = Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol

    # Verificar se o SMBv1 está habilitado
    if ($featureStatus.State -eq 'Enabled') {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "SMB Versão 1") -NoNewline
        Write-Host ("{0,-86} " -f "Habilitado") -NoNewline -ForegroundColor Green
        Write-Host "║" -ForegroundColor Cyan
    }
    else {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "SMB Versão 1") -NoNewline
        Write-Host ("{0,-86} " -f "Não está habilitado") -NoNewline -ForegroundColor Green
        Write-Host "║" -ForegroundColor Cyan
    }
}
#----------------------------------------------------------------------------------------------

# Aplicando alterações
#----------------------------------------------------------------------------------------------
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