<#
    Função: Corrigir erros de permissão DCOM
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
    [string]$CLSID = "2593F8B9-4EAF-457C-B68A-50F6B8EA6B54",
    [string]$APPID = "15C20B67-12E7-4BB6-92BB-7AFF07997402",
    [string]$User = "Administrador"
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
& $cabecalhoScriptPath -Script $scriptName -Titulo "Corrigir erros de permissão DCOM"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
# Exibe informações sobre as permissões que serão aplicadas
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Corrigindo DCOM") -NoNewline
Write-Host ("{0,-86} " -f "CLSID: $CLSID") -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Corrigindo DCOM") -NoNewline
Write-Host ("{0,-86} " -f "APPID: $APPID") -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

# Caminho no Registro para a configuração do CLSID e APPID em HKEY_LOCAL_MACHINE
$clsidPath = "HKLM:\SOFTWARE\Classes\CLSID\{$CLSID}"
$appidPath = "HKLM:\SOFTWARE\Classes\AppID\{$APPID}"

# Verifica se o CLSID existe no Registro
if (-not (Test-Path $clsidPath)) {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Erro") -NoNewline
    Write-Host ("{0,-86} " -f "CLSID $CLSID não encontrado no Registro.") -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan

    exit
}

# Verifica se o APPID existe no Registro
if (-not (Test-Path $appidPath)) {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Erro") -NoNewline
    Write-Host ("{0,-86} " -f "CLSID $CLSID não encontrado no Registro.") -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan

    exit
}

# Concedendo permissões de ativação local no DCOM para o grupo Administradores
try {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Permissões") -NoNewline
    Write-Host ("{0,-86} " -f "Concedendo permissões de ativação local ao usuário $User...") -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan

    # Adiciona permissões de ativação local para o usuário especificado
    $dcomConfig = New-Object -ComObject "Shell.Application"
    $dcomConfig.ShellExecute("dcomcnfg", "/standalone /cl {0}" -f $CLSID, "", "runas")

    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Permissões") -NoNewline
    Write-Host ("{0,-86} " -f "Permissões de ativação local concedidas com sucesso!") -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
} catch {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Erro") -NoNewline
    Write-Host ("{0,-86} " -f "Aplicar permissões DCOM: $_") -NoNewline -ForegroundColor White
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