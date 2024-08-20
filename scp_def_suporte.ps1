# Script para definir as informações de suporte

# Cabecalho
#----------------------------------------------------------------------------------------------
# Obter o diretório do script atual
$scriptName = [System.IO.Path]::GetFileName($MyInvocation.MyCommand.Path)
$CurrentScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path

# Construir o caminho completo para o script 'scp_script_cabecalho.ps1'
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_script_cabecalho.ps1"

& $CabecalhoScriptPath -Script $scriptName -Titulo "Definir informações de suporte"
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