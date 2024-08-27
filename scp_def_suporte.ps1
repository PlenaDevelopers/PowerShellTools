<#
    Função: Definir informações de suporte
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
& $cabecalhoScriptPath -Script $scriptName -Titulo "alterar as informações de suporte"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
# Defina o caminho para o Registro do Windows
$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation"

# Caminho da imagem BMP no subdiretório do script
$sourceLogoPath = Join-Path -Path $PSScriptRoot -ChildPath "logo\logo_plena.bmp"

# Obter o diretório real do Windows
$windowsDirectory = [System.Environment]::GetFolderPath("Windows")

# Construir o caminho completo para a pasta 'oem'
$oemDirectoryPath = Join-Path -Path $windowsDirectory -ChildPath "System32\oem"

# Construir o caminho completo para o logo dentro da pasta 'oem'
$destinationLogoPath = Join-Path -Path $oemDirectoryPath -ChildPath "logo_plena.bmp"

# Verifique se a pasta de destino existe, se não, crie-a
if (-not (Test-Path $oemDirectoryPath)) {
    $null = New-Item -Path $oemDirectoryPath -ItemType Directory -Force
}

# Copie a imagem BMP para o diretório do Windows
$null = Copy-Item -Path $sourceLogoPath -Destination $destinationLogoPath -Force

# Defina os valores a serem modificados no registro
$values = @{
    "Manufacturer" = "Plena Soluções";
    "Model" = "Cliente Plena Soluções";
    "SupportPhone" = "11 91020-6022";
    "SupportURL" = "http://www.novasuporte.com";
    "Logo" = $destinationLogoPath; 
}

# Verifique se o caminho do registro existe
if (Test-Path $registryPath) {
    # Crie ou atualize os valores no registro
    foreach ($name in $values.Keys) {
        Set-ItemProperty -Path $registryPath -Name $name -Value $values[$name]
    }
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Fabricante") -NoNewline -ForegroundColor White
    Write-Host ("{0,-86} " -f "Plena Soluções") -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan

    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Modelo") -NoNewline -ForegroundColor White
    Write-Host ("{0,-86} " -f "Cliente Plena Soluções") -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan

    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Telefone de Contato") -NoNewline -ForegroundColor White
    Write-Host ("{0,-86} " -f "11 91020-6022") -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan

    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Logotipo") -NoNewline -ForegroundColor White
    Write-Host ("{0,-86} " -f $destinationLogoPath) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Informações ") -NoNewline -ForegroundColor White
    Write-Host ("{0,-86} " -f "Erro ao gravar") -NoNewline -ForegroundColor Red
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