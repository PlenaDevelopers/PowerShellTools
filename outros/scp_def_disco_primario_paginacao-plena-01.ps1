#Script para desabilitar ou habilitar o arquivo de paginação no disco do Windows
param (
    [string]$acao = '1' # "0" para desativar, "1" para ativar
)

# Obtém a unidade onde o Windows está instalado
$WindowsDrive = $env:SystemDrive

# Define o caminho do arquivo de paginação no disco do Windows
$PagefilePath = "$WindowsDrive\pagefile.sys"

# Desabilita ou habilita o arquivo de paginação no disco do Windows com base na ação especificada
if ($acao -eq "0") {
    # Desativa o uso de arquivo de paginação no disco do Windows
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' -Name 'PagingFiles' -Value "$PagefilePath 0"
}
elseif ($acao -eq "1") {
    # Ativa o uso de arquivo de paginação no disco do Windows
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' -Name 'PagingFiles' -Value "$PagefilePath 1024 4096"
}
else {
    Write-Host "Ação inválida. Use '0' para desativar ou '1' para ativar o arquivo de paginação."
}
