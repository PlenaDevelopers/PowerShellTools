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

    Bugs & Correções:
    Em caso de Bugs encontrado pedimos a gentileza de informar por email para que possamos 
    analisar e gerar atualizações corretivas.

    Autor: Evandro Campanhã
    Contato: aurora.erp@gmail.com
    ------------------------------------------------------------------------------
#>
param (
    [string]$Usuario = 'Administrador',
    [string]$Senha = 'P@ssw0rd',
    [string]$HabilitarLogonAutomatico = '1'  # '1' para Habilitar, '0' para Desabilitar
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

# Iniciar Ações
#----------------------------------------------------------------------------------------------
# Valor a ser configurado (1 para ativar e 0 para desativar)
if ($HabilitarLogonAutomatico -eq "1") {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Opção") -NoNewline
    Write-Host ("{0,-86} " -f "Ativar") -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Opção") -NoNewline
    Write-Host ("{0,-86} " -f "Desativar") -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
}

# Converter o nome do parametro
$regValue = $HabilitarLogonAutomatico

$regPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
$regName = "AutoAdminLogon"

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Chave") -NoNewline
Write-Host ("{0,-86} " -f $regPath) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Item") -NoNewline
Write-Host ("{0,-86} " -f $regName) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Valor") -NoNewline
Write-Host ("{0,-86} " -f $regValue) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

# Verificar se o caminho no Registro existe, criar se não existir
if (-not (Test-Path $regPath)) {
    $null = New-Item -Path $regPath -Force | Out-Null
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Chave") -NoNewline
    Write-Host ("{0,-86} " -f "Criada") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan
}

# Configurar o AutoAdminLogon
$null = Set-ItemProperty -Path $regPath -Name $regName -Value $regValue -Type String

# Configurar as chaves DefaultUsername e DefaultPassword apenas se o AutoAdminLogon estiver habilitado
if ($HabilitarLogonAutomatico -eq '1') {
    $null = Set-ItemProperty $RegPath 'DefaultUsername' -Value "$Usuario" -Type String
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Valor") -NoNewline
    Write-Host ("{0,-86} " -f ("DefaultUsername: $Usuario - Criado")) -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan

    $null = Set-ItemProperty $RegPath 'DefaultPassword' -Value "$Senha" -Type String
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Valor") -NoNewline
    Write-Host ("{0,-86} " -f ("DefaultPassword: $Senha - Criado")) -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan
} else {
    # Remover as chaves DefaultUsername e DefaultPassword se o AutoAdminLogon estiver desabilitado
    if (Test-Path $regPath) {
        $usernameExists = Get-ItemProperty -Path $regPath -Name 'DefaultUsername' -ErrorAction SilentlyContinue
        if ($usernameExists) {
            $usernameValue = Get-ItemPropertyValue -Path $regPath -Name 'DefaultUsername'
            $null = Remove-ItemProperty $regPath -Name 'DefaultUsername'
            Write-Host "║" -NoNewline -ForegroundColor Cyan
            Write-Host ("{0,-30} : " -f "Valor") -NoNewline
            Write-Host ("{0,-86} " -f ("DefaultUsername: $usernameValue Removido")) -NoNewline -ForegroundColor Green
            Write-Host "║" -ForegroundColor Cyan
        } else {
            Write-Host "║" -NoNewline -ForegroundColor Cyan
            Write-Host ("{0,-30} : " -f "Valor") -NoNewline
            Write-Host ("{0,-86} " -f "DefaultUsername: Não havia um valor") -NoNewline -ForegroundColor Yellow
            Write-Host "║" -ForegroundColor Cyan
        }
    }

    if (Test-Path $regPath) {
        $passwordExists = Get-ItemProperty -Path $regPath -Name 'DefaultPassword' -ErrorAction SilentlyContinue
        if ($passwordExists) {
            $passwordValue = Get-ItemPropertyValue -Path $regPath -Name 'DefaultPassword'
            $null = Remove-ItemProperty $regPath -Name 'DefaultPassword'
            Write-Host "║" -NoNewline -ForegroundColor Cyan
            Write-Host ("{0,-30} : " -f "Valor") -NoNewline
            Write-Host ("{0,-86} " -f ("DefaultPassword: $passwordValue Removido")) -NoNewline -ForegroundColor Green
            Write-Host "║" -ForegroundColor Cyan
        } else {
            Write-Host "║" -NoNewline -ForegroundColor Cyan
            Write-Host ("{0,-30} : " -f "Valor") -NoNewline
            Write-Host ("{0,-86} " -f "DefaultPassword: Não havia um valor") -NoNewline -ForegroundColor Yellow
            Write-Host "║" -ForegroundColor Cyan
        }
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
