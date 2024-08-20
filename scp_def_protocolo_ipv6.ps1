# Script para desabilitar o "Protocolo IPv6"

# Cabecalho
#----------------------------------------------------------------------------------------------
# Obter o diretório do script atual
$scriptName = [System.IO.Path]::GetFileName($MyInvocation.MyCommand.Path)
$CurrentScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path

# Construir o caminho completo para o script 'scp_script_cabecalho.ps1'
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_script_cabecalho.ps1"

& $CabecalhoScriptPath -Script $scriptName -Titulo "Protocolo IPv6"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
Get-NetAdapter | ForEach-Object {
    Disable-NetAdapterBinding -Name $_.Name -ComponentID ms_tcpip6
}

# Listando adaptadores e informando se o protocolo IPv6 está habilitado ou não
Get-NetAdapter | ForEach-Object {
    $ipv6Enabled = $_ | Get-NetIPAddress -AddressFamily IPv6 -ErrorAction SilentlyContinue

    if ($ipv6Enabled) {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "$($_.Name)") -NoNewline
        Write-Host ("{0,-86} " -f "Habilitado") -NoNewline -ForegroundColor Green
        Write-Host "║" -ForegroundColor Cyan
    } else {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "$($_.Name)") -NoNewline
        Write-Host ("{0,-86} " -f "Desabilitado") -NoNewline -ForegroundColor Red
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