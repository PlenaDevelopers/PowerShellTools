<#
    Função: Lista redes Wifi
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
    analisar e gerar atualizações corretivas.

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
& $cabecalhoScriptPath -Script $scriptName -Titulo "Lista redes Wifi"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------

# Executa o comando netsh e armazena a saída
$networks = netsh wlan show networks mode=Bssid

# Inicializa as variáveis de captura
$ssid = ""
$auth = ""
$cifra = ""
$networkType = ""
$bssid = ""
$signal = ""
$radioType = ""
$channel = ""
$basicRates = ""
$otherRates = ""

# Percorre cada linha da saída
foreach ($line in $networks) {
    # Captura o SSID
    if ($line -match "SSID \d+ : (.+)") {
        $ssid = $matches[1]
    }
    
    # Captura o tipo de autenticação
    if ($line -match "Autentica‡Æo\s+: (.+)") {
        $auth = $matches[1]
    }

    # Captura a cifra
    if ($line -match "Criptografia\s+: (.+)") {
        $cifra = $matches[1]
    }

    # Captura o tipo de rede
    if ($line -match "Tipo de rede\s+: (.+)") {
        $networkType = $matches[1]
    }

    # Captura o BSSID
    if ($line -match "BSSID \d+\s+: (.+)") {
        $bssid = $matches[1]
    }

    # Captura o sinal
    if ($line -match "Sinal\s+: (\d+)%") {
        $signal = $matches[1] + "%"
    }

    # Captura o tipo de rádio
    if ($line -match "Tipo de r dio\s+: (.+)") {
        $radioType = $matches[1]
    }

    # Captura o canal
    if ($line -match "Canal\s+: (\d+)") {
        $channel = $matches[1]
    }

    # Captura as taxas básicas
    if ($line -match "Taxas b sicas \(Mbps\): (.+)") {
        $basicRates = $matches[1]
    }

    # Captura outras taxas
    if ($line -match "Outras taxas \(Mbps\): (.+)") {
        $otherRates = $matches[1]
    }

    # Se todas as informações estiverem capturadas, exibe os dados formatados
    if ($ssid -ne "" -and $auth -ne "" -and $cifra -ne "" -and $networkType -ne "" -and $bssid -ne "" -and $signal -ne "" -and $radioType -ne "" -and $channel -ne "" -and $basicRates -ne "" -and $otherRates -ne "") {
        Write-Host "╠" -NoNewline -ForegroundColor Cyan
        write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
        write-host "╣" -ForegroundColor Cyan
        
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "SSID") -NoNewline
        Write-Host ("{0,-86} " -f $ssid) -NoNewline -ForegroundColor White
        Write-Host "║" -ForegroundColor Cyan

        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Autenticação") -NoNewline
        Write-Host ("{0,-86} " -f $auth) -NoNewline -ForegroundColor White
        Write-Host "║" -ForegroundColor Cyan

        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Cifra") -NoNewline
        Write-Host ("{0,-86} " -f $cifra) -NoNewline -ForegroundColor White
        Write-Host "║" -ForegroundColor Cyan

        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Tipo de Rede") -NoNewline
        Write-Host ("{0,-86} " -f $networkType) -NoNewline -ForegroundColor White
        Write-Host "║" -ForegroundColor Cyan

        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "BSSID") -NoNewline
        Write-Host ("{0,-86} " -f $bssid) -NoNewline -ForegroundColor White
        Write-Host "║" -ForegroundColor Cyan

        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Sinal") -NoNewline
        Write-Host ("{0,-86} " -f $signal) -NoNewline -ForegroundColor White
        Write-Host "║" -ForegroundColor Cyan

        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Tipo de Rádio") -NoNewline
        Write-Host ("{0,-86} " -f $radioType) -NoNewline -ForegroundColor White
        Write-Host "║" -ForegroundColor Cyan

        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Canal") -NoNewline
        Write-Host ("{0,-86} " -f $channel) -NoNewline -ForegroundColor White
        Write-Host "║" -ForegroundColor Cyan

        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Taxas Básicas") -NoNewline
        Write-Host ("{0,-86} " -f "$basicRates Mbps") -NoNewline -ForegroundColor White
        Write-Host "║" -ForegroundColor Cyan

        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Outras Taxas") -NoNewline
        Write-Host ("{0,-86} " -f "$otherRates Mbps") -NoNewline -ForegroundColor White
        Write-Host "║" -ForegroundColor Cyan

        Write-Host "╠" -NoNewline -ForegroundColor Cyan
        write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
        write-host "╣" -ForegroundColor Cyan
        
        # Limpa as variáveis para o próximo bloco
        $ssid = ""
        $auth = ""
        $cifra = ""
        $networkType = ""
        $bssid = ""
        $signal = ""
        $radioType = ""
        $channel = ""
        $basicRates = ""
        $otherRates = ""
    }
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