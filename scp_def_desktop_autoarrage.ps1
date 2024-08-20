#Script que define se os ícones do desktop se auto organizarão
param (
    [string]$acao = "1" # "0" para desativar, "1" para ativar
)

# Cabecalho
#----------------------------------------------------------------------------------------------
# Obter o diretório do script atual
$scriptName = [System.IO.Path]::GetFileName($MyInvocation.MyCommand.Path)
$CurrentScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path

# Construir o caminho completo para o script 'scp_script_cabecalho.ps1'
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_script_cabecalho.ps1"

& $CabecalhoScriptPath -Script $scriptName -Titulo "Definir agrupamentode ícones no desktop"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
# Caminho do registro para a opção de organizar ícones automaticamente
$regPath = "HKCU:\SOFTWARE\Microsoft\Windows\Shell\Bags\1\Desktop"
$regName = "FFLAGS"

# Valor a ser configurado (1075839521 para ativar e 1075839520 para desativar)
if ($acao -eq "1") {
    $valor = 1075839521 # Ativar
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Opção") -NoNewline
    Write-Host ("{0,-86} " -f "Ativar") -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
} else {
    $valor = 1075839520 # Desativar
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Opção") -NoNewline
    Write-Host ("{0,-86} " -f "Desativar") -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
}

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Chave") -NoNewline
Write-Host ("{0,-86} " -f $regPath) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

# Define o valor no registro
New-ItemProperty -Path $regPath -Name $regName -Value $valor -PropertyType DWORD -Force | Out-Null
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f $regName) -NoNewline
Write-Host ("{0,-86} " -f $valor) -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan
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