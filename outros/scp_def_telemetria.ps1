# Script para habilitar ou desabilitar a Telemetria do Windows
param (
    [string]$valor = "0" # "0" - Desabilitar, "1" - Habilitar
)

# Caminho do Registro para a Telemetria do Windows
$telemetryRegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
$telemetryRegName = "AllowTelemetry"

# Valor a ser configurado (1 para ativar e 0 para desativar)
$telemetryRegValue = if ($valor -eq "1") { 1 } else { 0 }

# Verificar se o caminho no Registro existe, criar se não existir
if (-not (Test-Path $telemetryRegPath)) {
    New-Item -Path $telemetryRegPath -Force | Out-Null
}

# Criar ou atualizar a entrada no Registro
Set-ItemProperty -Path $telemetryRegPath -Name $telemetryRegName -Value $telemetryRegValue -Force

if ($valor -eq "1") {
    Write-Host "Telemetria do Windows habilitada."
} else {
    Write-Host "Telemetria do Windows desabilitada."
}
