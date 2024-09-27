<#
    Função: Scanner de Portas
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
& $cabecalhoScriptPath -Script $scriptName -Titulo "Scanner de Portas"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------

# Define a função para escanear as portas
function Scan-Port {
    param (
        [string]$TargetHost = "192.168.120.1", # Valor padrão para o host
        [int]$StartPort = 1,
        [int]$EndPort = 65535,
        [int]$Timeout = 1000, # Timeout em milissegundos
        [int]$ShowClosedPorts = 0, # 1 para mostrar portas fechadas, 0 para ocultar
        [int]$SaveToFile = 1 # 1 para salvar em arquivo, 0 para não salvar
    )

    # Inicia o escaneamento
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Alvo") -NoNewline
    Write-Host ("{0,-86} " -f $TargetHost) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan

    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Portas") -NoNewline
    Write-Host ("{0,-86} " -f "$StartPort a $EndPort") -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan

    # Inicializa uma variável para armazenar resultados
    $results = @()

    for ($port = $StartPort; $port -le $EndPort; $port++) {
        # Tenta conectar à porta
        $tcpClient = New-Object System.Net.Sockets.TcpClient

        try {
            # Conecta à porta especificada
            $tcpClient.Connect($TargetHost, $port)
            # Se a conexão for bem-sucedida, a porta está aberta
            Write-Host "║" -NoNewline -ForegroundColor Cyan
            Write-Host ("{0,-30} : " -f "Porta $port") -NoNewline
            Write-Host ("{0,-86} " -f "Aberta") -NoNewline -ForegroundColor Green
            Write-Host "║" -ForegroundColor Cyan
        } catch {
            # Se houver um erro, a porta está fechada ou inativa
            if ($ShowClosedPorts -eq 1) {
                Write-Host "║" -NoNewline -ForegroundColor Cyan
                Write-Host ("{0,-30} : " -f "Porta $port") -NoNewline
                Write-Host ("{0,-86} " -f "Fechada") -NoNewline -ForegroundColor Red
                Write-Host "║" -ForegroundColor Cyan
            }
        } finally {
            # Fecha a conexão
            $tcpClient.Close()
        }

        # Adiciona o resultado à lista
        $results += $result

        # Opcional: Adiciona um tempo de espera entre as tentativas
        Start-Sleep -Milliseconds $Timeout
    }

    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Status") -NoNewline
    Write-Host ("{0,-86} " -f "Concluído") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan

    # Salva o resultado em um arquivo se solicitado
    if ($SaveToFile -eq 1) {
        $outputPath = Join-Path -Path $scriptDirectory -ChildPath "PortScanResults.txt"
        $results | Out-File -FilePath $outputPath -Encoding UTF8
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Arquivo") -NoNewline
        Write-Host ("{0,-86} " -f "$outputPath") -NoNewline -ForegroundColor Yellow
        Write-Host "║" -ForegroundColor Cyan

    }
}

# Uso da função com um host específico
Scan-Port -TargetHost "192.168.120.1" -StartPort 1 -EndPort 100 -ShowClosedPorts 0 -SaveToFile 1 # Altere conforme necessário
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
