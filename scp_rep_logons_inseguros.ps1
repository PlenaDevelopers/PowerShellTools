# Script para reparar Erro de Logons Inseguros

# Cabecalho
#----------------------------------------------------------------------------------------------
# Obter o diretório do script atual
$scriptName = [System.IO.Path]::GetFileName($MyInvocation.MyCommand.Path)
$CurrentScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path

# Construir o caminho completo para o script 'scp_script_cabecalho.ps1'
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_script_cabecalho.ps1"

& $CabecalhoScriptPath -Script $scriptName -Titulo "Corrigir o Erro de Logons Inseguros"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
# Caminho do Registro
$registryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"

# Nome da entrada
$entryName = "EveryoneIncludesAnonymous"

# Valor DWORD
$entryValue = 1

# Verificar se o caminho no Registro existe, criar se não existir
if (-not (Test-Path $registryPath)) {
New-Item -Path $registryPath -Force
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Chave (Criada)") -NoNewline
Write-Host ("{0,-86} " -f $registryPath) -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan
}
else
{
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Chave (Já Existe)") -NoNewline
Write-Host ("{0,-86} " -f $registryPath) -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan
}

# Criar ou atualizar a entrada no Registro
$null=New-ItemProperty -Path $registryPath -Name $entryName -Value $entryValue -PropertyType DWORD -Force

#$null=New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "EveryoneIncludesAnonymous" -Value 1 -Force

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Chave") -NoNewline
Write-Host ("{0,-86} "   -f $registryPath) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Novo Valor") -NoNewline
Write-Host ("{0,-86} "   -f "EveryoneIncludesAnonymous=1") -NoNewline -ForegroundColor Green
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