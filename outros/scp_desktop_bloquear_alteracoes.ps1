#Script para bloquear/desbloquear o desktop
param (
    [string]$acao = "0" # "0" para desbloquear, "1" para bloquear
)

# Defina o caminho do Registro e os valores
$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\ActiveDesktop"
$regName = "NoChangingWallPaper"

if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}

# Valor a ser configurado (1 para ativar e 0 para desativar)
if ($acao -eq "1") {
    $regValue = 1 # Bloquear
} else {
    $regValue = 0 # Desbloquear
}

# Define o valor no Registro
Set-ItemProperty -Path $regPath -Name $regName -Value $regValue

# Verifica se o processo do Windows Explorer está em execução
$explorerProcess = Get-Process -Name explorer -ErrorAction SilentlyContinue

# Se o processo não estiver em execução, inicie-o
if (-not $explorerProcess) {
    Start-Process explorer
}

# Atualiza as configurações para refletir as mudanças
rundll32.exe user32.dll, UpdatePerUserSystemParameters

# Encerra o processo do Windows Explorer para aplicar as alterações imediatamente
Stop-Process -Name explorer -Force

# Aguarda alguns segundos antes de reiniciar o Windows Explorer
Start-Sleep -Seconds 2
