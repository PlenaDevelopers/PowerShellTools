<#
    Função: Backup do Regitro do Windows
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
    [string]$arquivoReg = "$PSScriptRoot\backup_$valor.reg"
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
& $cabecalhoScriptPath -Script $scriptName -Titulo "Backup do Regitro do Windows"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
function Listar-OcorrenciasRegistro {
    param (
        [string]$valor,
        [string]$arquivoReg
    )

    # Cabeçalho do arquivo .reg
    $header = "Windows Registry Editor Version 5.00`r`n"
    
    # Cria o arquivo .reg e adiciona o cabeçalho
    Set-Content -Path $arquivoReg -Value $header

    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Valor de Procura") -NoNewline
    Write-Host ("{0,-86} " -f $valor) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan

    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Arquivo Destino") -NoNewline
    Write-Host ("{0,-86} " -f $arquivoReg) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan

    Get-ChildItem -Path HKLM:\, HKCU:\ -Recurse -ErrorAction SilentlyContinue |
    ForEach-Object {
        try {
            # Obtém a chave atual e suas propriedades
            $chaveAtual = $_.PSPath
            $chave = Get-ItemProperty -Path $chaveAtual -ErrorAction SilentlyContinue
            foreach ($property in $chave.PSObject.Properties) {
                if ($property.Name -like "*$valor*" -or $property.Value -like "*$valor*") {
                    # Monta a entrada para o arquivo .reg
                    $chaveLimpa = $chaveAtual -replace 'HKEY_LOCAL_MACHINE', 'HKLM' -replace 'HKEY_CURRENT_USER', 'HKCU'
                    $valorRegistro = "[`"$chaveLimpa`"]`r`n`"$($property.Name)`"=`"$($property.Value)`"`r`n"
                    
                    Write-Host "║" -NoNewline -ForegroundColor Cyan
                    Write-Host ("{0,-119} " -f "$chaveLimpa") -NoNewline -ForegroundColor White
                    Write-Host "║" -ForegroundColor Cyan

                    Write-Host "║" -NoNewline -ForegroundColor Cyan
                    Write-Host ("{0,-119} " -f "$($property.Value)") -NoNewline -ForegroundColor Cyan
                    Write-Host "║" -ForegroundColor Cyan

                    Write-Host "║" -NoNewline -ForegroundColor Cyan
                    write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
                    Write-Host "║" -ForegroundColor Cyan 

                    # Adiciona a entrada ao arquivo .reg
                    Add-Content -Path $arquivoReg -Value $valorRegistro
                }
            }
        } catch {
            # Ignora erros de permissão
        }
    }
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Status") -NoNewline
    Write-Host ("{0,-86} " -f "Arquivo .reg criado com sucesso em: $arquivoReg") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
}

# Executa a função de listar ocorrências no registro
Listar-OcorrenciasRegistro -valor $valor -arquivoReg $arquivoReg
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