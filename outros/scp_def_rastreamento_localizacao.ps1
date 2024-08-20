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

# Caminho do Registro para o rastreamento de localização
$regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors"
$regName = "DisableLocation"

# Verificar se o caminho no Registro existe, criar se não existir
if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}

# Criar ou atualizar a entrada no Registro
New-ItemProperty -Path $regPath -Name $regName -Value $regValue -PropertyType DWORD -Force | Out-Null

# Mensagem de confirmação
if ($regValue -eq 0) {
    Write-Host "Rastreamento de localização desabilitado."
} else {
    Write-Host "Rastreamento de localização habilitado."
}
