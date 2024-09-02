<#
    Função: Habilitar/Desabilitar o Cortana
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
    [string]$acao = "0" # "0" - Desabilitar, "1" - Habilitar
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
& $cabecalhoScriptPath -Script $scriptName -Titulo "Habilitar/Desabilitar o Cortana"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
if ($acao -eq "0") {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Opção") -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-86} " -f "Desabilitar o Cortana") -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan

    $AcceptedPrivacyPolicyValue = 0
    $RestrictImplicitValueCollection = 1
    $RDsxWAaQUzQtK3MVfvekDQNsktKT7oB4hw = 1
    $HarvestContactsValue = 0
    Get-AppxPackage *Microsoft.549981C3F5F10* | Remove-AppxPackage
} elseif ($acao -eq "1") {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Opção") -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-86} " -f "Habilitar o Cortana") -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan

    $AcceptedPrivacyPolicyValue = 1
    $RestrictImplicitValueCollection = 0
    $RDsxWAaQUzQtK3MVfvekDQNsktKT7oB4hw = 0
    $HarvestContactsValue = 1
    Get-AppXPackage *Microsoft.549981C3F5F10* -AllUsers | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
}

$Cortana1 = "HKCU:\SOFTWARE\Microsoft\Personalization\Settings"
$Cortana2 = "HKCU:\SOFTWARE\Microsoft\InputPersonalization"
$Cortana3 = "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore"

If (!(Test-Path $Cortana1)) {
    New-Item $Cortana1
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Chave (Criada)") -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-86} " -f $Cortana1) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
}
else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Chave (Presente)") -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-86} " -f $Cortana1) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
}
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "AcceptedPrivacyPolicy") -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-86} " -f $AcceptedPrivacyPolicyValue) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
    Set-ItemProperty $Cortana1 AcceptedPrivacyPolicy -Value $AcceptedPrivacyPolicyValue 

If (!(Test-Path $Cortana2)) {
    New-Item $Cortana2
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Chave (Criada)") -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-86} " -f $Cortana2) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
}
else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Chave (Presente)") -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-86} " -f $Cortana2) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
}
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "RestrictImplicitTextCollection") -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-86} " -f $RestrictImplicitValueCollection) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
    Set-ItemProperty $Cortana2 RestrictImplicitTextCollection -Value $RestrictImplicitValueCollection 
    
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "RestrictImplicitInkCollection") -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-86} " -f $RDsxWAaQUzQtK3MVfvekDQNsktKT7oB4hw) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
    Set-ItemProperty $Cortana2 RestrictImplicitInkCollection -Value $RestrictImplicitInkCollectionValue 

If (!(Test-Path $Cortana3)) {
    New-Item $Cortana3
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Chave (Criada)") -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-86} " -f $Cortana3) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
}
else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Chave (Presente)") -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-86} " -f $Cortana3) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
}
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "HarvestContacts") -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-86} " -f $HarvestContactsValue) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
    Set-ItemProperty $Cortana3 HarvestContacts -Value $HarvestContactsValue 
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