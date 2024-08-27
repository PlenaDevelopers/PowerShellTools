<#
    Função: Altera o wallpaper de fundo da tela de logon
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
    [string]$imagem = "$PSScriptRoot\wallpaper\wallpaper_default.jpg"
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
& $cabecalhoScriptPath -Script $scriptName -Titulo "Definir a imagem de fundo da tela de Logon"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
# Caminho do diretório para copiar a imagem
$destinoImagem = "C:\Windows\Web\Screen\Lockscreen.jpg"

# Copia a imagem para o diretório de bloqueio de tela
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Copiando Imagem (Origem)") -NoNewline
Write-Host ("{0,-86} " -f $imagem) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Copiando Imagem (Destino)") -NoNewline
Write-Host ("{0,-86} " -f $destinoImagem) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

try {
    $null=Copy-Item -Path $imagem -Destination $destinoImagem -Force
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Copiar Arquivo") -NoNewline
    Write-Host ("{0,-86} " -f "Imagem copiada com sucesso") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan
} catch {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Copia") -NoNewline
    Write-Host ("{0,-86} " -f "Falha ao copiar imagem: $_") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
    exit 1
}

# Caminho do registro para configurar a tela de bloqueio
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP"

# Verifica se o caminho do registro existe
if (-not (Test-Path $regPath)) {
    $null=New-Item -Path $regPath -Force | Out-Null
}

# Define os valores no registro
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Aplicando Configuração") -NoNewline -ForegroundColor white
Write-Host ("{0,-86} " -f "LockScreenImagePath, LockScreenImageUrl e LockScreenImageStatus definidos") -NoNewline -ForegroundColor cyan
Write-Host "║" -ForegroundColor Cyan

try {
    $null=Set-ItemProperty -Path $regPath -Name "LockScreenImagePath" -Value $destinoImagem
    $null=Set-ItemProperty -Path $regPath -Name "LockScreenImageUrl" -Value $destinoImagem
    $null=Set-ItemProperty -Path $regPath -Name "LockScreenImageStatus" -Value 1
} catch {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Configuração") -NoNewline
    Write-Host ("{0,-86} " -f "Falha ao definir configurações no registro: $_") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
    exit 1
}

# Ajusta permissões no diretório de sistema
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Ajustando Permissões") -NoNewline -ForegroundColor white
Write-Host ("{0,-86} " -f "Ajustando permissões no diretório SystemData") -NoNewline -ForegroundColor cyan
Write-Host "║" -ForegroundColor Cyan

try {
    $folderPath = "C:\ProgramData\Microsoft\Windows\SystemData"
    $acl = Get-Acl $folderPath
    $adminGroup = [System.Security.Principal.NTAccount]"Administradores"
    $rule = [System.Security.AccessControl.FileSystemAccessRule]::new($adminGroup, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
    $acl.AddAccessRule($rule)
    Set-Acl -Path $folderPath -AclObject $acl
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Permissões") -NoNewline
    Write-Host ("{0,-86} " -f "Permissões ajustadas com sucesso") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan
} catch {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Permissões") -NoNewline
    Write-Host ("{0,-86} " -f "Falha ao ajustar permissões: $_") -NoNewline -ForegroundColor Red
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