<#
    Função: Renomear Arquivos
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
    [string]$extensao = "jpg",
    [string]$prefixo = "foto-",
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
& $cabecalhoScriptPath -Script $scriptName -Titulo "Renomear Arquivos"
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

# Obter todos os arquivos com a extensão especificada
$arquivos = Get-ChildItem -Path $diretorioBase -Filter "*.$extensao" | Sort-Object Name

# Verificar se há arquivos a serem renomeados
if ($arquivos.Count -eq 0) {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Aviso") -NoNewline -ForegroundColor Yellow
    Write-Host ("{0,-86} " -f "Nenhum arquivo com a extensão '$extensao' encontrado.") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
} else {
    # Renomear os arquivos
    $contador = 1
    foreach ($arquivo in $arquivos) {
        $novoNome = "{0}{1:D2}.{2}" -f $prefixo, $contador, $extensao
        $novoCaminho = Join-Path -Path $diretorioBase -ChildPath $novoNome

        # Renomear o arquivo
        Rename-Item -Path $arquivo.FullName -NewName $novoNome

        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Arquivo renomeado") -NoNewline -ForegroundColor White
        Write-Host ("{0,-86} " -f "$($arquivo.Name) -> $novoNome") -NoNewline -ForegroundColor Green
        Write-Host "║" -ForegroundColor Cyan

        $contador++
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
