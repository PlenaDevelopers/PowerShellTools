<#
    Função: Recuperar o Serial e Verificar Estado de Ativação do Windows
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
& $cabecalhoScriptPath -Script $scriptName -Titulo "Recuperar a chave de instalação do Windows"
#----------------------------------------------------------------------------------------------


# Iniciar Ações
#----------------------------------------------------------------------------------------------
function Get-WindowsProductKey {
    try {
        $key = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
        $digitalProductId = (Get-ItemProperty -Path $key).DigitalProductId
        $productKey = ""

        $keyOffset = 52
        $chars = "BCDFGHJKMPQRTVWXY2346789"

        for ($i = 0; $i -lt 25; $i++) {
            $current = 0
            for ($j = 24; $j -ge 0; $j--) {
                $current = [math]::Floor($current * 256) -bxor $digitalProductId[$keyOffset + $j]
                $digitalProductId[$keyOffset + $j] = [math]::Floor($current / 24)
                $current = $current % 24
            }
            $productKey = $chars[$current] + $productKey
            if (($i + 1) % 5 -eq 0 -and $i -ne 24) {
                $productKey = "-" + $productKey
            }
        }

        return $productKey
    } catch {
        Write-Host "Erro ao recuperar o serial do Windows." -ForegroundColor Red
    }
}

function Get-WindowsActivationStatus {
    try {
        # Executa o comando slmgr.vbs /xpr e captura a saída
        $xprOutput = & cscript.exe //NoLogo "C:\Windows\System32\slmgr.vbs" /xpr 2>&1

        $activationStatus = ""
        $expirationDate = ""
        $edition = ""

        # Captura a versão do Windows
        $osVersion = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ProductName
        
        # Verifica o status de ativação e data de expiração
        if ($xprOutput -match "will expire on\s+([^\r\n]+)") {
            $expirationDate = $matches[1]
            $activationStatus = "Aviso: Ativação expira em $expirationDate"
        } elseif ($xprOutput -match "is permanently activated") {
            $activationStatus = "Ativado permanentemente"
        } else {
            $activationStatus = "Erro: O Windows não está ativado"
        }

        return [PSCustomObject]@{
            Edition = $osVersion
            ActivationStatus = $activationStatus
            ExpirationDate = $expirationDate
        }
    } catch {
        Write-Host "Erro ao verificar o status de ativação do Windows." -ForegroundColor Red
    }
}

$windowsProductKey = Get-WindowsProductKey
$activationInfo = Get-WindowsActivationStatus

if ($windowsProductKey) {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Serial do Windows") -NoNewline
    Write-Host ("{0,-86} " -f $windowsProductKey) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Serial do Windows") -NoNewline
    Write-Host ("{0,-86} " -f "Não foi possível coletar o Serial") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
}

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Versão do Windows") -NoNewline
Write-Host ("{0,-86} " -f $activationInfo.Edition) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Status de Ativação") -NoNewline
Write-Host ("{0,-86} " -f $activationInfo.ActivationStatus) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

if ($activationInfo.ExpirationDate) {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Data de Expiração") -NoNewline
    Write-Host ("{0,-86} " -f $activationInfo.ExpirationDate) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
}

# Rodapé
#----------------------------------------------------------------------------------------------
# Obter o diretório do script atual
$CurrentScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path -Parent

# Construir o caminho completo para o script 'scp_script_rodape.ps1'
$rodapeScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_script_rodape.ps1"

# Executar o script de rodapé
& $rodapeScriptPath
#----------------------------------------------------------------------------------------------