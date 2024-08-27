<#
    Função: Habilitar/Desabilitar o Logon Automático
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
    [string]$Usuario = 'Administrador',
    [string]$Senha = 'P@ssw0rd',
    [string]$HabilitarLogonAutomatico = '0'  # '1' para Habilitar, '0' para Desabilitar
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
& $cabecalhoScriptPath -Script $scriptName -Titulo "Habilitar/Desabilitar o Logon Automático"
#----------------------------------------------------------------------------------------------
if ($HabilitarLogonAutomatico -eq "0") {
    $acao = "Desabilitar"
} elseif ($HabilitarLogonAutomatico -eq "1") {
    $acao = "Habilitar"
}
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Valor") -NoNewline
Write-Host ("{0,-86} " -f ("AutoAdminLogon: $HabilitarLogonAutomatico")) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

$RegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
# Verificar se o caminho no Registro existe, criar se não existir
if (-not (Test-Path $RegistryPath)) {
    $null=New-Item -Path $RegistryPath -Force | Out-Null
}

# Configurar o AutoAdminLogon
$null=Set-ItemProperty $RegistryPath 'AutoAdminLogon' -Value "$HabilitarLogonAutomatico" -Type String
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Chave") -NoNewline
Write-Host ("{0,-86} " -f $RegistryPath) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

# Configurar as chaves DefaultUsername e DefaultPassword apenas se o AutoAdminLogon estiver habilitado
if ($HabilitarLogonAutomatico -eq '1') {
    $null=Set-ItemProperty $RegistryPath 'DefaultUsername' -Value "$Usuario" -type String 
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Valor") -NoNewline
    Write-Host ("{0,-86} " -f ("DefaultUsername: $Usuario")) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan


    $null=Set-ItemProperty $RegistryPath 'DefaultPassword' -Value "$Senha" -type String
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Valor") -NoNewline
    Write-Host ("{0,-86} " -f ("DefaultPassword: $Senha")) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
} else {
    # Remover as chaves DefaultUsername e DefaultPassword se o AutoAdminLogon estiver desabilitado
    $null=Remove-ItemProperty $RegistryPath -Name 'DefaultUsername'
    $null=Remove-ItemProperty $RegistryPath -Name 'DefaultPassword'
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Valor") -NoNewline
    Write-Host ("{0,-86} " -f ("DefaultUsername e DefaultPassword removidos")) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
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