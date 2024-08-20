#Script para remover o Microsoft ONEDrive
Clear

# Verifica se o script está sendo executado como administrador
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Executando script como administrador..."
    Start-Sleep -Seconds 1
    # Inicia uma nova instância do PowerShell com privilégios de administrador
    Start-Process powershell -Verb runAs -ArgumentList ("-File $($MyInvocation.MyCommand.Path) $args")
    # Encerra a execução deste script
    Exit
}

# Verificar se o processo OneDrive.exe está em execução
if (Get-Process -Name "OneDrive" -ErrorAction SilentlyContinue) {
    # Se estiver em execução, encerrar o processo
    Stop-Process -Name "OneDrive" -Force
}

# Verificar se o processo explorer.exe está em execução
$explorerProcess = Get-Process -Name "explorer" -ErrorAction SilentlyContinue

if ($explorerProcess -eq $null) {
    # Se o processo explorer não estiver em execução, inicie-o
    Start-Process explorer
}

if (Test-Path "$env:systemroot\System32\OneDriveSetup.exe") {
    & "$env:systemroot\System32\OneDriveSetup.exe" /uninstall
}
if (Test-Path "$env:systemroot\SysWOW64\OneDriveSetup.exe") {
    & "$env:systemroot\SysWOW64\OneDriveSetup.exe" /uninstall
}

# Criar a chave do Registro se ela ainda não existir
$null = New-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\OneDrive" -Force | Out-Null

# Definir o valor do Registro para desabilitar o OneDrive
$null = Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\OneDrive" -Name "DisableFileSyncNGSC" -Value 1

# Remover resíduos do OneDrive
$null = rm -Recurse -Force -ErrorAction SilentlyContinue "$env:localappdata\Microsoft\OneDrive"
$null = rm -Recurse -Force -ErrorAction SilentlyContinue "$env:programdata\Microsoft OneDrive"
$null = rm -Recurse -Force -ErrorAction SilentlyContinue "C:\OneDriveTemp"

# Remover o OneDrive da barra de tarefas
$null = New-PSDrive -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" -Name "HKCR"
$null = mkdir -Force "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
$null = sp "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" "System.IsPinnedToNameSpaceTree" 0
$null = mkdir -Force "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
$null = sp "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" "System.IsPinnedToNameSpaceTree" 0
$null = Remove-PSDrive "HKCR"

# Carregar o Registro do perfil padrão
$null = reg load "HKU\Default" "C:\Users\Default\NTUSER.DAT"

# Verificar se a chave do Registro existe antes de excluir
if (Test-Path "HKU\Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Run") {
    # Excluir a entrada de execução do OneDrive do Registro
    $null = reg delete "HKU\Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "OneDriveSetup" /f
}

# Descarregar o Registro do perfil padrão
$null = reg unload "HKU\Default"

# Remover Entradas do Menu Iniciar
$null = rm -Force -ErrorAction SilentlyContinue "$env:userprofile\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk"

# Atualiza as configurações para refletir as mudanças
rundll32.exe user32.dll, UpdatePerUserSystemParameters

# Encerra o processo do Windows Explorer para aplicar as alterações imediatamente
Stop-Process -Name explorer -Force

# Aguarda alguns segundos antes de reiniciar o Windows Explorer
Start-Sleep -Seconds 2

# Remover resíduos individuais do OneDrive
$diretorioOnedrive = "$env:WinDir\WinSxS"
$items = Get-ChildItem -Path $diretorioOnedrive -Recurse -Directory | Where-Object { $_.Name -like "*onedrive*" -or $_.Name -like "*settingsync-onedrive*" }

foreach ($item in $items) {
    # Tentar remover o item e capturar exceções de permissão
    try {
        # Resetar permissões com icacls
        icacls $item.FullName /reset /T /C
        
        $acl = $item.GetAccessControl() 

        # Obter o SID para o grupo "Todos"
        $sid = New-Object System.Security.Principal.SecurityIdentifier([System.Security.Principal.WellKnownSidType]::WorldSid, $null)
        6
        # Criar a regra de acesso usando o SID
        $permission = New-Object System.Security.AccessControl.FileSystemAccessRule($sid, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")

        $acl.SetAccessRuleProtection($True, $False)

        $acl.SetAccessRule($permission)
        $item.SetAccessControl($acl)
        
        # Remover arquivos com rm
        rm -Recurse -Force $item.FullName | Out-Null
    } catch {
        Write-Host "Não foi possível remover o item $($item.FullName): $($_.Exception.Message)"
    }
}

# Se o processo não estiver em execução, inicie-o
if ($explorerProcess -eq $null) {
    Start-Process explorer
}

# Atualiza as configurações para refletir as mudanças
rundll32.exe user32.dll, UpdatePerUserSystemParameters

# Encerra o processo do Windows Explorer para aplicar as alterações imediatamente
Stop-Process -Name explorer -Force

# Aguarda alguns segundos antes de reiniciar o Windows Explorer
Start-Sleep -Seconds 2
