<#
    Função: Renomear a unidade de disco D, se houver
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
	analizar e gerar atualizações corretivas.

	Autor: Evandro Campanhã
	Contato: aurora.erp@gmail.com
	------------------------------------------------------------------------------
#>

param (
    [string]$valor = "Brother",
    [string]$acao = "listar"
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
& $cabecalhoScriptPath -Script $scriptName -Titulo "Renomear o disco D"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
function Listar-OcorrenciasRegistro {
    param (
        [string]$valor
    )
    # Pesquisa no Registro por chaves ou valores que correspondam ao $valor
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Procurando") -NoNewline
    Write-Host ("{0,-86} " -f $valor) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan

    Get-ChildItem -Path HKLM:\, HKCU:\ -Recurse -ErrorAction SilentlyContinue |
    ForEach-Object {
        try {
            # Verifica se o valor ou chave corresponde ao termo de busca
            $chaveAtual = $_.PSPath
            $chave = Get-ItemProperty -Path $chaveAtual -ErrorAction SilentlyContinue

            Write-Host "║" -NoNewline -ForegroundColor Cyan
            Write-Host ("{0,-120} " -f $chaveAtual) -NoNewline -ForegroundColor White
            Write-Host "║" -ForegroundColor Cyan

            foreach ($property in $chave.PSObject.Properties) {
               if ($property.Name -like "*$valor*" -or $property.Value -like "*$valor*") {

                }
            }
        } catch {
            # Ignore erros de permissão
        }
    }
}

function Apagar-OcorrenciasRegistro {
    param (
        [string]$valor
    )
    # Procura e apaga todas as chaves ou valores que correspondam ao $valor
    Write-Host "Procurando e removendo ocorrências no registro que contenham: $valor" -ForegroundColor Cyan
    Get-ChildItem -Path HKLM:\, HKCU:\ -Recurse -ErrorAction SilentlyContinue |
    ForEach-Object {
        try {
            $chaveAtual = $_.PSPath
            $chave = Get-ItemProperty -Path $chaveAtual -ErrorAction SilentlyContinue
            foreach ($property in $chave.PSObject.Properties) {
                if ($property.Name -like "*$valor*" -or $property.Value -like "*$valor*") {
                    Write-Host "Removendo chave ou valor na chave: $chaveAtual" -ForegroundColor Red
                    Remove-ItemProperty -Path $chaveAtual -Name $property.Name -ErrorAction SilentlyContinue
                }
            }
        } catch {
            # Ignore erros de permissão ou chaves protegidas
        }
    }
}

# Verifica qual ação realizar
if ($acao -eq "listar") {
    Listar-OcorrenciasRegistro -valor $valor
} elseif ($acao -eq "apagar") {
    Apagar-OcorrenciasRegistro -valor $valor
} else {
    Write-Host "Ação inválida. Use 'listar' ou 'apagar'." -ForegroundColor Red
}
