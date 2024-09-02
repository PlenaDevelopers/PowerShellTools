<#
    Função: Organizar Arquivos por Extensão
    Copyright: © Plena Soluções - 2024
    Date: Setembro/2024

    Licenciamento:
    Este script é fornecido "como está", sem qualquer garantia de qualquer tipo,
    expressa ou implícita, incluindo, mas não se limitando às garantias de 
    comercialização, adequação a um determinado fim e não violação. O uso deste 
    script é totalmente gratuito, mas você deve manter os créditos ao autor original.
    
    Bugs & Correções
    Em caso de Bugs encontrado pedimos a gentileza de informar por email para que possamos 
    analisar e gerar atualizações corretivas.

    Autor: Evandro Campanhã
    Contato: aurora.erp@gmail.com
    ------------------------------------------------------------------------------
#>

param (
    [string]$extensao = "TODOS", # se o valor for "TODOS" a pasta inteira será organizada
    [string]$diretorioBase = "C:\temp"
)

# Cabeçalho
#----------------------------------------------------------------------------------------------
# Obter o diretório do script atual
$scriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path -Parent

# Obter o nome do script atual
$scriptName = [System.IO.Path]::GetFileName($MyInvocation.MyCommand.Path)

# Construir o caminho completo para o script 'scp_script_cabecalho.ps1'
$cabecalhoScriptPath = Join-Path -Path $scriptDirectory -ChildPath "scp_script_cabecalho.ps1"

# Executar o script de cabeçalho
& $cabecalhoScriptPath -Script $scriptName -Titulo "Organizar Arquivos por Extensão"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
# Verificar se o diretório base existe
if (-not (Test-Path -Path $diretorioBase -PathType Container)) {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Erro") -NoNewline -ForegroundColor Red
    Write-Host ("{0,-86} " -f "Diretório base não encontrado.") -NoNewline -ForegroundColor Yellow
    Write-Host "║" -ForegroundColor Cyan
    exit
}

# Função para mover arquivos para subpastas com base na extensão
function Move-FilesToSubfolders {
    param (
        [array]$arquivos
    )
    foreach ($arquivo in $arquivos) {
        $extensaoArquivo = $arquivo.Extension.TrimStart('.')
        $subpasta = Join-Path -Path $diretorioBase -ChildPath $extensaoArquivo.ToUpper()

        # Criar a subpasta se não existir
        if (-not (Test-Path -Path $subpasta)) {
            New-Item -Path $subpasta -ItemType Directory | Out-Null
        }

        # Mover o arquivo para a subpasta correspondente
        $destino = Join-Path -Path $subpasta -ChildPath $arquivo.Name
        Move-Item -Path $arquivo.FullName -Destination $destino -Force

        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Arquivo movido") -NoNewline -ForegroundColor White
        Write-Host ("{0,-86} " -f "$destino") -NoNewline -ForegroundColor Green
        Write-Host "║" -ForegroundColor Cyan
    }
}

# Movimentação dos arquivos
if ($extensao -eq "TODOS") {
    # Obter todos os arquivos no diretório base
    $arquivos = Get-ChildItem -Path $diretorioBase -File
    Move-FilesToSubfolders -arquivos $arquivos
} else {
    # Obter apenas os arquivos com a extensão especificada
    $arquivos = Get-ChildItem -Path $diretorioBase -Filter "*.$extensao" -File
    Move-FilesToSubfolders -arquivos $arquivos
}
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
