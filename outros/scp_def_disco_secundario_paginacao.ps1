#Script para habilitar ou desabilitar o arquivo de paginação no disco D
param (
    [string]$acao  # "0" para desativar, "1" para ativar
)

# Verifica se a unidade D existe
if (Test-Path "D:\") {
    # Define o caminho do arquivo de paginação no disco D
    $PagefilePath = "D:\pagefile.sys"

    # Desativa ou habilita o arquivo de paginação no disco D com base na ação especificada
    if ($acao -eq "0") {
        # Desativa o uso de arquivo de paginação no disco D
        Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' -Name 'PagingFiles' -Value "$PagefilePath 0"
    }
    elseif ($acao -eq "1") {
        # Ativa o uso de arquivo de paginação no disco D
        Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' -Name 'PagingFiles' -Value "$PagefilePath 1024 4096"
    }
    else {
    }
}
else {
    Write-Host "A unidade D não foi encontrada. Não é possível habilitar/desabilitar o arquivo de paginação."
}
