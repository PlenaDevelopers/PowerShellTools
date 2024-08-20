#Script que remove a caixa de pesquisa
param (
    [string]$acao = "0" # 0 para desativar, 1 para ativar
)

# Cabecalho
#----------------------------------------------------------------------------------------------
# Obter o diretório do script atual
$scriptName = [System.IO.Path]::GetFileName($MyInvocation.MyCommand.Path)
$CurrentScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path

# Construir o caminho completo para o script 'scp_script_cabecalho.ps1'
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_script_cabecalho.ps1"

& $CabecalhoScriptPath -Script $scriptName -Titulo "Barra de Pesquisa"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
# Defina o caminho do Registro e os valores
$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"
$regName = "SearchboxTaskbarMode"

if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}

# Valor a ser configurado (0 para desativar e 1 para ativar)
if ($acao -eq "0") {
    $regValue = 0 # Desativar
    $estado = 'Desativar'
} else {
    $regValue = 2 # Ativar
    $estado = 'Ativar'
}

# Define o valor no Registro
Set-ItemProperty -Path $regPath -Name $regName -Value $regValue

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "$regName") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f  $estado) -NoNewline -ForegroundColor White
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