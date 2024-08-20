# Script para efetuar a limpeza do historico de cores do tema

# Cabecalho
#----------------------------------------------------------------------------------------------
# Obter o diretório do script atual
$scriptName = [System.IO.Path]::GetFileName($MyInvocation.MyCommand.Path)
$CurrentScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path

# Construir o caminho completo para o script 'scp_script_cabecalho.ps1'
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_script_cabecalho.ps1"

& $CabecalhoScriptPath -Script $scriptName -Titulo "Temas - Remover histórico"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
# Função para apagar todo o conteúdo de uma chave de registro
function Remove-RegistryKeyContent {
    param (
        [string]$keyPath
    )
    
    if (Test-Path $keyPath) {
        # Obter todas as subchaves da chave principal
        $subKeys = Get-ChildItem -Path $keyPath -Recurse -ErrorAction SilentlyContinue

        foreach ($subKey in $subKeys) {
            try {
                $null=Remove-Item -Path $subKey.PSPath -Recurse -Force
                Write-Host "║" -NoNewline -ForegroundColor Cyan
                Write-Host ("{0,-30} : " -f "Sucesso ao remover") -NoNewline
                Write-Host ("{0,-86} " -f $subKey.PSPath) -NoNewline -ForegroundColor Green
                Write-Host "║" -ForegroundColor Cyan
            } catch {
                Write-Host "║" -NoNewline -ForegroundColor Cyan
                Write-Host ("{0,-30} : " -f "Erro ao remover") -NoNewline
                Write-Host ("{0,-86} " -f "$($subKey.PSPath): $($_.Exception.Message)") -NoNewline -ForegroundColor Red
                Write-Host "║" -ForegroundColor Cyan
            }
        }
        
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Sucesso ao remover") -NoNewline
        Write-Host ("{0,-86} " -f $keyPath) -NoNewline -ForegroundColor Green
        Write-Host "║" -ForegroundColor Cyan
    } else {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Alerta ao remover") -NoNewline
        Write-Host ("{0,-86} " -f "$keyPath não encontrada.") -NoNewline -ForegroundColor Yellow
        Write-Host "║" -ForegroundColor Cyan
    }
}

# Caminhos para as chaves de registro de cores
$RegPath1 = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent"
$RegPath2 = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\History\Colors"

# Apagar o conteúdo das chaves de registro de cores
$null=Remove-RegistryKeyContent -keyPath $RegPath1
$null=Remove-RegistryKeyContent -keyPath $RegPath2
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