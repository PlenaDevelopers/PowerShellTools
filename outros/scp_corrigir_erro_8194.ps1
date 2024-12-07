# Verifica se o script está sendo executado com privilégios de Administrador
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Este script precisa ser executado como Administrador." -ForegroundColor Red
    exit
}

Write-Host "Aplicando correções para o erro do VSS..." -ForegroundColor Cyan

# Define o SID do Network Service diretamente
$serviceAccountSID = New-Object System.Security.Principal.SecurityIdentifier "S-1-5-20"

# Caminho no Registro que controla permissões de acesso ao VSS Writer
$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SvcHost"

try {
    # Obtém a ACL atual da chave do Registro
    $acl = Get-Acl -Path $registryPath

    # Configura permissão de leitura usando o SID do Network Service
    $accessRule = New-Object System.Security.AccessControl.RegistryAccessRule(
        $serviceAccountSID, 
        [System.Security.AccessControl.RegistryRights]::ReadKey, 
        [System.Security.AccessControl.AccessControlType]::Allow
    )
    
    # Define a nova regra de acesso
    $acl.SetAccessRule($accessRule)
    Set-Acl -Path $registryPath -AclObject $acl
    
    Write-Host "Permissões aplicadas ao serviço VSS para o usuário 'Network Service'." -ForegroundColor Green
} catch {
    Write-Host "Erro ao tentar definir as permissões: $_" -ForegroundColor Red
}

# Reinicia o serviço VSS para aplicar as mudanças
Write-Host "Reiniciando o serviço de Cópias de Sombra de Volume (VSS)..." -ForegroundColor Cyan
Restart-Service -Name "VSS" -Force -ErrorAction SilentlyContinue

Write-Host "Correção concluída. Verifique o log de eventos para confirmar se o erro foi resolvido." -ForegroundColor Green
