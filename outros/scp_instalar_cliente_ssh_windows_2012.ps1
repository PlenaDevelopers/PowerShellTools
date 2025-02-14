<#
    Função: Instalar Cliente SSH - Windows 2012
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
Write-Host ("{0,-86} " -f "Sistema Operacional") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan

$osVersion = [System.Environment]::OSVersion.Version
$win10OrNewer = ($osVersion.Major -ge 10)

if ($win10OrNewer) {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Windows 10+") -NoNewline -ForegroundColor White
    Write-Host ("{0,-86} " -f "Usando WindowsCapability") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan

    # Verifica e instala OpenSSH no Windows 10+
    $sshClient = Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Client*'
    if ($sshClient.State -ne "Installed") {
        Add-WindowsCapability -Online -Name 'OpenSSH.Client~~~~0.0.1.0'
    }
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Windows Server 2012") -NoNewline -ForegroundColor White
    Write-Host ("{0,-86} " -f "Corrigindo TLS 1.2") -NoNewline -ForegroundColor Yellow
    Write-Host "║" -ForegroundColor Cyan

    # Ativa suporte ao TLS 1.2 para conexões seguras
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    # Verifica se o Chocolatey está instalado
    if (!(Test-Path "C:\ProgramData\chocolatey\bin\choco.exe")) {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f " Instalando") -NoNewline -ForegroundColor White
        Write-Host ("{0,-86} " -f "Chocolatey") -NoNewline -ForegroundColor Green
        Write-Host "║" -ForegroundColor Cyan

        # Baixa e instala o Chocolatey
        $chocoScript = "$env:TEMP\choco_install.ps1"
        Invoke-WebRequest -Uri 'https://community.chocolatey.org/install.ps1' -OutFile $chocoScript
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$chocoScript`"" -Wait -NoNewWindow
    }

    # Verifica se o Chocolatey foi instalado corretamente
    if (Test-Path "C:\ProgramData\chocolatey\bin\choco.exe") {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f " Concluído") -NoNewline -ForegroundColor White
        Write-Host ("{0,-86} " -f "Chocolatey instalado com sucesso!") -NoNewline -ForegroundColor Green
        Write-Host "║" -ForegroundColor Cyan

        # Instala OpenSSH via Chocolatey
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f " Instalando") -NoNewline -ForegroundColor White
        Write-Host ("{0,-86} " -f "OpenSSH") -NoNewline -ForegroundColor Green
        Write-Host "║" -ForegroundColor Cyan

        Start-Process -FilePath "C:\ProgramData\chocolatey\bin\choco.exe" -ArgumentList "install openssh -y" -Wait -NoNewWindow
    } else {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f " Erro") -NoNewline -ForegroundColor Yellow
        Write-Host ("{0,-86} " -f "Falha ao instalar Chocolatey.") -NoNewline -ForegroundColor Red
        Write-Host "║" -ForegroundColor Cyan
        exit 1
    }

    # Verifica se o OpenSSH foi instalado corretamente
    if (Test-Path "C:\Program Files\OpenSSH-Win64\ssh.exe") {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f " Concluído") -NoNewline -ForegroundColor White
        Write-Host ("{0,-86} " -f "OpenSSH instalado com sucesso!") -NoNewline -ForegroundColor Green
        Write-Host "║" -ForegroundColor Cyan
    } else {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f " Erro") -NoNewline -ForegroundColor Yellow
        Write-Host ("{0,-86} " -f "Falha ao instalar OpenSSH.") -NoNewline -ForegroundColor Red
        Write-Host "║" -ForegroundColor Cyan
        exit 1
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