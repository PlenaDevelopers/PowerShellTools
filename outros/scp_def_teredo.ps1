# Script para habilitar ou desabilitar o Teredo
param (
    [string]$acao = "0" # "0" - Desabilitar, "1" - Habilitar
)

# Verificar se a ação é válida
if ($acao -ne "0" -and $acao -ne "1") {
    Write-Host "Ação inválida. Use '0' para desabilitar ou '1' para habilitar."
    Exit
}

# Converter a ação para um valor numérico
$regValue = [int]$acao

# Caminho do Registro para o Teredo
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters"
$regName = "DisabledComponents"

# Obter o valor atual, se existir
$currentValue = Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue

# Verificar se o caminho no Registro existe, criar se não existir
if (-not $currentValue) {
    $null = New-ItemProperty -Path $regPath -Name $regName -Value "0" -PropertyType DWORD -Force
}

# Habilitar ou desabilitar o Teredo
if ($regValue -eq 0) {
    $newValue = $currentValue.DisabledComponents -bor 0x20
} else {
    $newValue = $currentValue.DisabledComponents -band (-bnot 0x20)
}

# Definir o novo valor no Registro
Set-ItemProperty -Path $regPath -Name $regName -Value $newValue

# Mensagem de confirmação
if ($regValue -eq 0) {
    Write-Host "Teredo desabilitado."
} else {
    Write-Host "Teredo habilitado."
}
