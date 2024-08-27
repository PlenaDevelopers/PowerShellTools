<#
    Função: Habilitar/Desabilitar Teredo
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
    [string]$opcao = "0" # "0" - Desabilitar, "1" - Habilitar
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
& $cabecalhoScriptPath -Script $scriptName -Titulo "Habilitar/Desabilitar o Teredo"
#----------------------------------------------------------------------------------------------
if ($opcao -eq "0") {
    $acao = "Desabilitar"
} elseif ($opcao -eq "1") {
    $acao = "Habilitar"
}
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Valor") -NoNewline
Write-Host ("{0,-86} " -f ("Teredo: $acao")) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

# Converter a ação para um valor numérico
$regValue = [int]$opcao

# Caminho do Registro para o Teredo
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters"
$regName = "DisabledComponents"

# Verificar se o caminho no Registro existe, criar se não existir
if (-not (Test-Path $regPath)) {
    $null=New-Item -Path $regPath -Force | Out-Null
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Chave (Criada)") -NoNewline
    Write-Host ("{0,-86} " -f $regPath) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
}
else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Chave (Existente)") -NoNewline
    Write-Host ("{0,-86} " -f $regPath) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
}

$null=New-ItemProperty -Path $regPath -Name $regName -Value $regValue -PropertyType DWORD -Force | Out-Null
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Valor") -NoNewline
Write-Host ("{0,-86} " -f ("DisabledComponents: $regValue")) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

# Habilitar ou desabilitar o Teredo
if ($regValue -eq 0) {
    $newValue = $currentValue.DisabledComponents -bor 0x20
} else {
    $newValue = $currentValue.DisabledComponents -band (-bnot 0x20)
}

# Definir o novo valor no Registro
Set-ItemProperty -Path $regPath -Name $regName -Value $newValue
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