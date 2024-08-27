<#
    Função: Habilitar a funcionalidade de leitura de Sistemas de Arquivos SMBv1
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
# Cabeçalho
#----------------------------------------------------------------------------------------------
# Obter o diretório do script atual
$scriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path -Parent

# Obter o nome do script atual
$scriptName = [System.IO.Path]::GetFileName($MyInvocation.MyCommand.Path)

# Construir o caminho completo para o script 'scp_script_cabecalho.ps1'
$cabecalhoScriptPath = Join-Path -Path $scriptDirectory -ChildPath "scp_script_cabecalho.ps1"

# Executar o script de cabeçalho
& $cabecalhoScriptPath -Script $scriptName -Titulo "Habilitar o suporte a sistemas de arquivos SMBv1"
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

# Rodapé
#----------------------------------------------------------------------------------------------
# Obter o diretório do script atual
$CurrentScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path -Parent

# Construir o caminho completo para o script 'scp_script_rodape.ps1'
$rodapeScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_script_rodape.ps1"

# Executar o script de rodapé
& $rodapeScriptPath
#----------------------------------------------------------------------------------------------