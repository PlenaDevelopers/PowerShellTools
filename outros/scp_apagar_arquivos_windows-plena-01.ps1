#Script para excluir arquivos do diretorio do Windows
param (
    [string]$FileExtension = 'log'
)

# Função para alterar permissões de arquivo
function AlterarPermissoesArquivo {
    param (
        [string]$caminhoArquivo
    )

try {
    # Resetar permissões com icacls e desabilitar herança
    icacls $caminhoArquivo /reset /T /C
    
    $acl = (Get-Item $caminhoArquivo).GetAccessControl() 

    # Obter o SID para o grupo "Todos"
    $sid = New-Object System.Security.Principal.SecurityIdentifier([System.Security.Principal.WellKnownSidType]::WorldSid, $null)

    # Criar a regra de acesso usando o SID
    $permission = New-Object System.Security.AccessControl.FileSystemAccessRule($sid, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
    
    $acl.SetAccessRuleProtection($True, $False)

    $acl.SetAccessRule($permission)
    (Get-Item $caminhoArquivo).SetAccessControl($acl)
} catch {
    Write-Host "Não foi possível alterar as permissões do arquivo $($caminhoArquivo): $($_.Exception.Message)"
}

}

# Obtém o caminho do diretório do Windows
$windowsDirectory = [Environment]::GetFolderPath("Windows")

# Constrói o caminho completo para os arquivos com a extensão especificada no desktop
$filesToDelete = Get-ChildItem -Path $windowsDirectory -Filter "*.$FileExtension" -File

if ($filesToDelete.Count -gt 0) {
    foreach ($file in $filesToDelete) {
        # Altera as permissões do arquivo
        AlterarPermissoesArquivo -caminhoArquivo $file.FullName

        # Remove o arquivo
        Remove-Item -Path $file.FullName -Force
        Write-Host "Arquivo removido: $($file.FullName)"
    }
} else {
    Write-Host "Nenhum arquivo com a extensão '$FileExtension' encontrado no desktop."
}
