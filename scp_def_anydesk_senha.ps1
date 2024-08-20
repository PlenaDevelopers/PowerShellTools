# Script para definr o acesso remoto do Anydesk
param (
    [string]$UnattendedPassword = 'P@ssw0rd2024'
)

# Cabeçalho
#----------------------------------------------------------------------------------------------
Write-Host "╔" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
write-host "╗" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Configurar") -NoNewline 
Write-Host ("{0,-86} " -f "Anydesk") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Copyright") -NoNewline
Write-Host ("{0,-86} " -f "2023 - Evandro Campanhã") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Script") -NoNewline
Write-Host ("{0,-86} " -f $MyInvocation.MyCommand.Path) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

Write-Host "╠" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
write-host "╣" -ForegroundColor Cyan
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Senha") -NoNewline
Write-Host ("{0,-86} " -f $UnattendedPassword) -NoNewline -ForegroundColor White
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
    Write-Host ("{0,-30} : " -f " Status") -NoNewline
    Write-Host ("{0,-86} " -f "Senha de acesso não configurada com sucesso.") -NoNewline -ForegroundColor White
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
    Write-Host ("{0,-30} : " -f " Status") -NoNewline
    Write-Host ("{0,-86} " -f "Perfil de acesso não configurada com sucesso.") -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
}

# Verificando se o AnyDesk está instalado
if (Test-AnyDeskInstallation) {
    # Configurando as permissões de acesso não supervisionado
    Set-AnyDeskPermissions
    # Definindo a senha de acesso não supervisionado
    Set-AnyDeskPassword -password $UnattendedPassword
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Status") -NoNewline
    Write-Host ("{0,-86} " -f "AnyDesk não está instalado neste sistema.") -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
}
#----------------------------------------------------------------------------------------------

# Aplicando alterações
#----------------------------------------------------------------------------------------------
# Aplicar alterações
rundll32.exe user32.dll, UpdatePerUserSystemParameters

# Verificar se o processo explorer está em execução
$explorerProcess = Get-Process -Name explorer -ErrorAction SilentlyContinue

if ($explorerProcess) {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Reiniciando Processo") -NoNewline
    Write-Host ("{0,-86} " -f "Windows Explorer") -NoNewline -ForegroundColor Cyan
    Write-Host "║" -ForegroundColor Cyan
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Iniciando Processo") -NoNewline
    Write-Host ("{0,-86} " -f "Windows Explorer") -NoNewline -ForegroundColor Cyan
    Write-Host "║" -ForegroundColor Cyan
    Start-Process explorer -WindowStyle Hidden
}
#----------------------------------------------------------------------------------------------

# Rodape
#----------------------------------------------------------------------------------------------
Write-Host "╠" -NoNewline -ForegroundColor Cyan
Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
Write-Host "╣" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Processo") -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-86} " -f "Finalizado") -NoNewline -ForegroundColor Cyan
Write-Host "║" -ForegroundColor Cyan

Write-Host "╚" -NoNewline -ForegroundColor Cyan
Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
Write-Host "╝" -ForegroundColor Cyan