# Script para Ativar o Microsoft Office 365
# Parâmetro de entrada
Param (
    [string]$ProductKey = "XQNVK-8JYDB-WJ9W3-YJ8YR-WFG99" # Chave padrão
)

# Cabeçalho
#----------------------------------------------------------------------------------------------
Write-Host "╔" -NoNewline -ForegroundColor Cyan
Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
Write-Host "╗" -ForegroundColor Cyan  

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Operação") -NoNewline
Write-Host ("{0,-86} " -f "Ativar Microsoft Office") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Copyright") -NoNewline
Write-Host ("{0,-86} " -f "2023 - Evandro Campanhã") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Script") -NoNewline
Write-Host ("{0,-86} " -f $MyInvocation.MyCommand.Path) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

Write-Host "╠" -NoNewline -ForegroundColor Cyan
Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
Write-Host "╣" -ForegroundColor Cyan
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
# Definindo as variáveis de diretório base para Office 64 bits e 32 bits
$Office64Path = "${env:ProgramFiles}\Microsoft Office\Office16"
$Office32Path = "${env:ProgramFiles(x86)}\Microsoft Office\Office16"

# Início da simulação de "goto"
$Rodape = $false

while ($true) {
    # Verificando se o diretório do Office 64 bits existe
    if (Test-Path $Office64Path) {
        Set-Location -Path $Office64Path
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f " Diretório do Office(x64)") -NoNewline
        Write-Host ("{0,-86} " -f $Office64Path) -NoNewline -ForegroundColor Yellow
        Write-Host "║" -ForegroundColor Cyan
    }
    # Verificando se o diretório do Office 32 bits existe
    elseif (Test-Path $Office32Path) {
        Set-Location -Path $Office32Path
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f " Diretório do Office(x86)") -NoNewline
        Write-Host ("{0,-86} " -f $Office32Path) -NoNewline -ForegroundColor Yellow
        Write-Host "║" -ForegroundColor Cyan
    }
    else {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f " Diretório do Office") -NoNewline
        Write-Host ("{0,-86} " -f "Não encontrado") -NoNewline -ForegroundColor Yellow
        Write-Host "║" -ForegroundColor Cyan
        
        # Simulando "goto Rodape"
        $Rodape = $true
    }

    # Se o Office não for encontrado, pula para o rodapé
    if ($Rodape) { break }

    # Inserindo as licenças KMS
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Inserindo Chave") -NoNewline
    Write-Host ("{0,-86} " -f $ProductKey) -NoNewline -ForegroundColor Yellow
    Write-Host "║" -ForegroundColor Cyan

    Get-ChildItem -Path "..\root\Licenses16" -Filter "proplusvl_kms*.xrm-ms" | ForEach-Object {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f " Executando") -NoNewline
        Write-Host ("{0,-86} " -f $($_.FullName)) -NoNewline -ForegroundColor Yellow
        Write-Host "║" -ForegroundColor Cyan
        $null = & cscript ospp.vbs /inslic:"$($_.FullName)"
    }

    # Inserindo a chave de produto
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Chave") -NoNewline
    Write-Host ("{0,-86} " -f $ProductKey) -NoNewline -ForegroundColor Yellow
    Write-Host "║" -ForegroundColor Cyan
    $null = & cscript ospp.vbs /inpkey:$ProductKey

    # Removendo chaves antigas
    $OldKeys = @("BTDRB", "KHGM9", "CPQVG")
    foreach ($Key in $OldKeys) {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f " Remover chave") -NoNewline
        Write-Host ("{0,-86} " -f $Key) -NoNewline -ForegroundColor Yellow
        Write-Host "║" -ForegroundColor Cyan
        & cscript ospp.vbs /unpkey:$Key > $null
    }

    # Configurando o servidor KMS e ativando o Office
    $KmsServer = "e8.us.to"
    $KmsPort = 1688

    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Servidor KMS") -NoNewline
    Write-Host ("{0,-86} " -f $KmsServer) -NoNewline -ForegroundColor Yellow
    Write-Host "║" -ForegroundColor Cyan
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Porta KMS") -NoNewline
    Write-Host ("{0,-86} " -f $KmsPort) -NoNewline -ForegroundColor Yellow
    Write-Host "║" -ForegroundColor Cyan

    $null = & cscript ospp.vbs /sethst:$KmsServer
    $null = & cscript ospp.vbs /setprt:$KmsPort

    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Operação") -NoNewline
    Write-Host ("{0,-86} " -f "Ativando") -NoNewline -ForegroundColor Yellow
    Write-Host "║" -ForegroundColor Cyan
    $null = & cscript ospp.vbs /act

    # Verificando se o Office está ativado
    $ActivationStatus = & cscript ospp.vbs /dstatus

    # Interpretando a saída para verificar o status de ativação
    if ($ActivationStatus -match "LICENSE STATUS:  ---LICENSED---") {
        Write-Host "╠" -NoNewline -ForegroundColor Cyan
        Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
        Write-Host "╣" -ForegroundColor Cyan

        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f " Status de Ativação") -NoNewline
        Write-Host ("{0,-86} " -f "O Office está ativado com sucesso!") -NoNewline -ForegroundColor Green
        Write-Host "║" -ForegroundColor Cyan
    } else {
        Write-Host "╠" -NoNewline -ForegroundColor Cyan
        Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
        Write-Host "╣" -ForegroundColor Cyan

        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f " Status de Ativação") -NoNewline
        Write-Host ("{0# Parâmetro de entrada
Param (
    [string]$ProductKey = "XQNVK-8JYDB-WJ9W3-YJ8YR-WFG99" # Chave padrão
)

# Cabeçalho
#----------------------------------------------------------------------------------------------
Write-Host "╔" -NoNewline -ForegroundColor Cyan
Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
Write-Host "╗" -ForegroundColor Cyan  

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Operação") -NoNewline
Write-Host ("{0,-86} " -f "Ativar Microsoft Office") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Copyright") -NoNewline
Write-Host ("{0,-86} " -f "2023 - Evandro Campanhã") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Script") -NoNewline
Write-Host ("{0,-86} " -f $MyInvocation.MyCommand.Path) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

Write-Host "╠" -NoNewline -ForegroundColor Cyan
Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
Write-Host "╣" -ForegroundColor Cyan

#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------

# Definindo as variáveis de diretório base para Office 64 bits e 32 bits
$Office64Path = "${env:ProgramFiles}\Microsoft Office\Office16"
$Office32Path = "${env:ProgramFiles(x86)}\Microsoft Office\Office16"

# Verificando se o diretório do Office 64 bits existe
if (Test-Path $Office64Path) {
    Set-Location -Path $Office64Path
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Diretório do Office(x64)") -NoNewline
    Write-Host ("{0,-86} " -f $Office64Path) -NoNewline -ForegroundColor Yellow
    Write-Host "║" -ForegroundColor Cyan
}
# Verificando se o diretório do Office 32 bits existe
elseif (Test-Path $Office32Path) {
    Set-Location -Path $Office32Path
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Diretório do Office(x86)") -NoNewline
    Write-Host ("{0,-86} " -f $Office32Path) -NoNewline -ForegroundColor Yellow
    Write-Host "║" -ForegroundColor Cyan
}
else {
    # Rodape para Office não encontrado
    #----------------------------------------------------------------------------------------------
    Write-Host "╠" -NoNewline -ForegroundColor Cyan
    Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
    Write-Host "╣" -ForegroundColor Cyan  

    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Processo") -NoNewline
    Write-Host ("{0,-86} " -f "Finalizado") -NoNewline -ForegroundColor Cyan
    Write-Host "║" -ForegroundColor Cyan

    Write-Host "╚" -NoNewline -ForegroundColor Cyan
    Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
    Write-Host "╝" -ForegroundColor Cyan
    exit
}

# Inserindo as licenças KMS
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Inserindo Chave") -NoNewline
Write-Host ("{0,-86} " -f $ProductKey) -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan

Get-ChildItem -Path "..\root\Licenses16" -Filter "proplusvl_kms*.xrm-ms" | ForEach-Object {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Executando") -NoNewline
    Write-Host ("{0,-86} " -f $($_.FullName)) -NoNewline -ForegroundColor Yellow
    Write-Host "║" -ForegroundColor Cyan
    $null = & cscript ospp.vbs /inslic:"$($_.FullName)"
}

# Inserindo a chave de produto
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Chave") -NoNewline
Write-Host ("{0,-86} " -f $ProductKey) -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan
$null=& cscript ospp.vbs /inpkey:$ProductKey

# Removendo chaves antigas
$OldKeys = @("BTDRB", "KHGM9", "CPQVG")
foreach ($Key in $OldKeys) {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Remover chave") -NoNewline
    Write-Host ("{0,-86} " -f $Key) -NoNewline -ForegroundColor Yellow
    Write-Host "║" -ForegroundColor Cyan
    & cscript ospp.vbs /unpkey:$Key > $null
}

# Configurando o servidor KMS e ativando o Office
$KmsServer = "e8.us.to"
$KmsPort = 1688

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Servidor KMS") -NoNewline
Write-Host ("{0,-86} " -f $KmsServer) -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Porta KMS") -NoNewline
Write-Host ("{0,-86} " -f $KmsPort) -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan

$null = & cscript ospp.vbs /sethst:$KmsServer
$null = & cscript ospp.vbs /setprt:$KmsPort

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Operação") -NoNewline
Write-Host ("{0,-86} " -f "Ativando") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan
$null = & cscript ospp.vbs /act

# Verificando se o Office está ativado
$ActivationStatus = & cscript ospp.vbs /dstatus

# Interpretando a saída para verificar o status de ativação
if ($ActivationStatus -match "LICENSE STATUS:  ---LICENSED---") {
    Write-Host "╠" -NoNewline -ForegroundColor Cyan
    Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
    Write-Host "╣" -ForegroundColor Cyan

    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Status de Ativação") -NoNewline
    Write-Host ("{0,-86} " -f "O Office está ativado com sucesso!") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan
} else {
    Write-Host "╠" -NoNewline -ForegroundColor Cyan
    Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
    Write-Host "╣" -ForegroundColor Cyan

    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Status de Ativação") -NoNewline
    Write-Host ("{0,-86} " -f "Falha na ativação do Office. Verifique os detalhes.") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
}
#----------------------------------------------------------------------------------------------

# Aplicando alterações
#----------------------------------------------------------------------------------------------
# Aplicar alterações
rundll32.exe user32.dll, UpdatePerUserSystemParameters

# Verificar se o processo explorer está em execução
$explorerProcess = Get-Process -Name explorer -ErrorAction SilentlyContinue

if ($explorerProcess) {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Reiniciando Processo") -NoNewline
    Write-Host ("{0,-86} " -f "Windows Explorer") -NoNewline -ForegroundColor Cyan
    Write-Host "║" -ForegroundColor Cyan
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Iniciando Processo") -NoNewline
    Write-Host ("{0,-86} " -f "Windows Explorer") -NoNewline -ForegroundColor Cyan
    Write-Host "║" -ForegroundColor Cyan
    Start-Process explorer -WindowStyle Hidden
}
#----------------------------------------------------------------------------------------------

# Rodape
#----------------------------------------------------------------------------------------------
Write-Host "╠" -NoNewline -ForegroundColor Cyan
Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
Write-Host "╣" -ForegroundColor Cyan  

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Processo") -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-86} " -f "Finalizado") -NoNewline -ForegroundColor Cyan
Write-Host "║" -ForegroundColor Cyan

Write-Host "╚" -NoNewline -ForegroundColor Cyan
Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
Write-Host "╝" -ForegroundColor Cyan,-86} " -f "Falha na ativação do Office. Verifique os detalhes.") -NoNewline -ForegroundColor Red
        Write-Host "║" -ForegroundColor Cyan
    }

    Write-Host "╚" -NoNewline -ForegroundColor Cyan
    Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
    Write-Host "╝" -ForegroundColor Cyan
}
#----------------------------------------------------------------------------------------------
