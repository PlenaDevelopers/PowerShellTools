<#
    Função: Instalar Cliente SSH - Windows 10
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
& $cabecalhoScriptPath -Script $scriptName -Titulo "Instalar Cliente SSH - Windows 2012"
#----------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Verificando") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "Cliente SSH no Windows") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan

# Verifica se o Cliente SSH já está instalado
$sshClient = Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Client*'

if ($sshClient.State -eq "Installed") {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Status") -NoNewline -ForegroundColor White
    Write-Host ("{0,-86} " -f "Cliente SSH já está instalado.") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Instalando") -NoNewline -ForegroundColor White
    Write-Host ("{0,-86} " -f "Cliente SSH no Windows") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan

    # Instala o Cliente SSH
    Add-WindowsCapability -Online -Name 'OpenSSH.Client~~~~0.0.1.0'

    # Verifica se a instalação foi bem-sucedida
    $sshClient = Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Client*'
    if ($sshClient.State -eq "Installed") {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f " Concluído") -NoNewline -ForegroundColor White
        Write-Host ("{0,-86} " -f "Cliente SSH instalado com sucesso!") -NoNewline -ForegroundColor Green
        Write-Host "║" -ForegroundColor Cyan
    } else {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f " Erro") -NoNewline -ForegroundColor Yellow
        Write-Host ("{0,-86} " -f "Falha ao instalar o Cliente SSH.") -NoNewline -ForegroundColor Red
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