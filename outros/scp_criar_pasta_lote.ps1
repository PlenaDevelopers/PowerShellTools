<#
    Função: Criar pastas
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

# Definindo a lista de pastas
$pastas = @(
    @{ Path = "C:\Temp\Logs" },
    @{ Path = "C:\Temp\Logs1" },
    @{ Path = "C:\Temp\Logs2" },
    @{ Path = "C:\Temp\Logs3" },
    @{ Path = "C:\Temp\Logs4" },
    @{ Path = "C:\Temp\Logs5" },
    @{ Path = "C:\Temp\Logs6" },
    @{ Path = "C:\Temp\Backups" },
    @{ Path = "C:\Temp\Relatorios" },
    @{ Path = "C:\Temp\Imagens" }
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
& $cabecalhoScriptPath -Script $scriptName -Titulo "Criar pastas"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
foreach ($pasta in $pastas) {
    $caminhoPasta = $pasta.Path
    
    # Verifica se o caminho da pasta existe
    if (-not (Test-Path -Path $caminhoPasta -PathType Container)) {
        # Cria a pasta se não existir
        $null = New-Item -Path $caminhoPasta -ItemType Directory -Force
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Pasta (criada)") -NoNewline
        Write-Host ("{0,-86} " -f $caminhoPasta) -NoNewline -ForegroundColor Green
        Write-Host "║" -ForegroundColor Cyan
    } else {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Pasta (já existia)") -NoNewline
        Write-Host ("{0,-86} " -f $caminhoPasta) -NoNewline -ForegroundColor Green
        Write-Host "║" -ForegroundColor Cyan
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
