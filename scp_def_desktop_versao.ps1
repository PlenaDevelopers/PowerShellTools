# Script para mostrar a versão do Windows no Desktop
param (
    [string]$valor = "1" #"0" - Não Mostrar | "1" - Mostrar 
)

# Cabecalho
#----------------------------------------------------------------------------------------------
# Obter o diretório do script atual
$scriptName = [System.IO.Path]::GetFileName($MyInvocation.MyCommand.Path)
$CurrentScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path

# Construir o caminho completo para o script 'scp_script_cabecalho.ps1'
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_script_cabecalho.ps1"

& $CabecalhoScriptPath -Script $scriptName -Titulo "Mostrar versão no Desktop"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
# Defina o caminho do Registro e os valores
$regPath = "HKCU:\Control Panel\Desktop"
$regName = "PaintDesktopVersion"

# Verifique se o parâmetro é válido
if ($valor -ne "0" -and $valor -ne "1") {
    Write-Host "║" -NoNewline -ForegroundColor Red
    Write-Host ("{0,-30} : " -f "Erro") -NoNewline
    Write-Host ("{0,-86} " -f "Parâmetro inválido! Use '0' para Não Mostrar ou '1' para Mostrar") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
    exit
}

# Defina o valor de acordo com o parâmetro
$regValue = [int]$valor

# Verifique se a chave do Registro existe
if (-not (Test-Path $regPath)) {
    # Crie a chave do Registro se não existir
    $null=New-Item -Path $regPath -Force
}

# Atualize ou crie o valor do Registro
Write-Host "║" -NoNewline -ForegroundColor Cyan
if ($regValue -eq 1) {
    Write-Host ("{0,-30} : " -f "Status") -NoNewline
    Write-Host ("{0,-86} " -f "Ativar") -NoNewline -ForegroundColor White
} else {
    Write-Host ("{0,-30} : " -f "Satus") -NoNewline
    Write-Host ("{0,-86} " -f "Desativar") -NoNewline -ForegroundColor White
}
Write-Host "║" -ForegroundColor Cyan

$null=Set-ItemProperty -Path $regPath -Name $regName -Value $regValue
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