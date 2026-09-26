<#
    Copyright: (c) Flex IT - 2026
    Function: Abrir Chrome em Modo Kiosk
    Description: Script Powershell do pacote PowerTool para execution automated em Windows 10 e Windows 11.
#>

# Define a URL que voce deseja abrir
$url = "https://www.exemplo.com"

# Header
#----------------------------------------------------------------------------------------------
# Get the current script directory
$scriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path -Parent

# Get the current script name
$scriptName = [System.IO.Path]::GetFileName($MyInvocation.MyCommand.Path)


# Show local header
Write-PowerToolHeader -Script $scriptName -Titulo "Iniciar o Google Chrome no modo Kiosk"
#----------------------------------------------------------------------------------------------

# Start actions
#----------------------------------------------------------------------------------------------
# Caminho do executavel do Google Chrome (ajuste conforme o caminho de instalacao no seu sistema)
$chromePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"

# Verifica se o Chrome esta instalado no caminho especificado
if (Test-Path $chromePath) {
    # Abre o Google Chrome com a URL especificada em modo de tela cheia (kiosk)
    Start-Process $chromePath -ArgumentList "--kiosk", $url
    Write-PowerToolLine "Status" "Abrindo '$url' no Google Chrome em modo de tela cheia.'" "White"
} else {
    Write-PowerToolLine "Status" "O Google Chrome nao foi encontrado no caminho especificado: $chromePath" "White"
}
#----------------------------------------------------------------------------------------------

# Applying changes
#----------------------------------------------------------------------------------------------
rundll32.exe user32.dll, UpdatePerUserSystemParameters
#----------------------------------------------------------------------------------------------

# Rodape
#----------------------------------------------------------------------------------------------
# Get the current script directory
$CurrentScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path -Parent


# Exibir rodape local
Write-PowerToolFooter
#----------------------------------------------------------------------------------------------
