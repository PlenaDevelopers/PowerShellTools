# Script para definr o acesso remoto do Anydesk
param (
    [string]$Senha = 'P@ssw0rd2024'
)

# Cabecalho
#----------------------------------------------------------------------------------------------
# Obter o diretório do script atual
$scriptName = [System.IO.Path]::GetFileName($MyInvocation.MyCommand.Path)
$CurrentScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path

# Construir o caminho completo para o script 'scp_script_cabecalho.ps1'
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_script_cabecalho.ps1"

& $CabecalhoScriptPath -Script $scriptName -Titulo "Definir acesso do Anydesk"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Senha") -NoNewline
Write-Host ("{0,-86} " -f $Senha) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

# Função para verificar se o AnyDesk está instalado
function Test-AnyDeskInstallation {
    $anydeskPath = "C:\Program Files (x86)\AnyDesk\AnyDesk.exe"
    if (Test-Path $anydeskPath) {
        return $true
    } else {
        return $false
    }
}

# Função para definir a senha de acesso não supervisionado
function Set-AnyDeskPassword {
    param (
        [string]$password
    )
    
    # Caminho para o executável do AnyDesk
    $anydeskExe = "C:\Program Files (x86)\AnyDesk\AnyDesk.exe"
    
    # Definindo a senha de acesso não supervisionado
    $command = "echo $password | & `"$anydeskExe`" --set-password _unattended_access"
    
    # Executando o comando
    Invoke-Expression $command
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Status") -NoNewline
    Write-Host ("{0,-86} " -f "Senha de acesso não supervisionado configurada com sucesso.") -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan

}

# Função para configurar as permissões para acesso não supervisionado
function Set-AnyDeskPermissions {
    # Caminho para o executável do AnyDesk
    $anydeskExe = "C:\Program Files (x86)\AnyDesk\AnyDesk.exe"
    
    # Comando para configurar o perfil de acesso não supervisionado com permissões completas
    $command = "& `"$anydeskExe`" --add-profile _unattended_access +control +file_transfer +clipboard +audio +input +view +sysinfo +syssettings +chat"
    
    # Executando o comando
    Invoke-Expression $command
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Status") -NoNewline
    Write-Host ("{0,-86} " -f "Perfil de acesso não supervisionado configurada com sucesso.") -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
}

# Verificando se o AnyDesk está instalado
if (Test-AnyDeskInstallation) {
    # Configurando as permissões de acesso não supervisionado
    Set-AnyDeskPermissions
    # Definindo a senha de acesso não supervisionado
    Set-AnyDeskPassword -password $Senha
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Status") -NoNewline
    Write-Host ("{0,-86} " -f "AnyDesk não está instalado neste sistema.") -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
}
#----------------------------------------------------------------------------------------------

# Aplicando alterações
#----------------------------------------------------------------------------------------------
# Aplicar alterações
rundll32.exe user32.dll, UpdatePerUserSystemParameters
#----------------------------------------------------------------------------------------------

# Rodape
#----------------------------------------------------------------------------------------------
# Obter o diretório do script atual
$CurrentScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path

# Construir o caminho completo para o script 'scp_script_rodape.ps1'
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_script_rodape.ps1"

& $CabecalhoScriptPath
#----------------------------------------------------------------------------------------------