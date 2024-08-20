# Script para limpar arquivos temporários
# Cabecalho
#----------------------------------------------------------------------------------------------
# Obter o diretório do script atual
$scriptName = [System.IO.Path]::GetFileName($MyInvocation.MyCommand.Path)
$CurrentScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path

# Construir o caminho completo para o script 'scp_script_cabecalho.ps1'
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_script_cabecalho.ps1"

& $CabecalhoScriptPath -Script $scriptName -Titulo "Limpar arquivos temporários"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
# Caminhos para limpeza
$paths = @(
    "$env:TEMP\*",
    [System.IO.Path]::Combine($env:LOCALAPPDATA, 'Microsoft\Windows\INetCache'),
    [System.IO.Path]::Combine($env:LOCALAPPDATA, 'Packages'),
    'C:\Windows\SoftwareDistribution\Download',
    'C:\Users\Public\AppData\Local\Microsoft\Windows\Explorer',
    'C:\Windows\Logs',
    [System.IO.Path]::Combine($env:LOCALAPPDATA, 'Temp'),
    [System.IO.Path]::Combine($env:LOCALAPPDATA, 'Apps')
)

foreach ($path in $paths) {
    # Obter arquivos e pastas no caminho especificado
    $items = Get-ChildItem -Path $path -ErrorAction SilentlyContinue -Recurse
    foreach ($item in $items) {
        try {
            # Tentar remover o item
            Remove-Item -Path $item.FullName -Force -Recurse -ErrorAction Stop
        } catch {
            # Ignorar erros ao tentar remover o item
        }
    }
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Pasta") -NoNewline -ForegroundColor White
    Write-Host ("{0,-86} " -f $path) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
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