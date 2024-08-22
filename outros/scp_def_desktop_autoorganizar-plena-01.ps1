#Script que define se os ícones do desktop se auto organizarão
param (
    [string]$acao = "1" # "0" para desativar, "1" para ativar
)

# Caminho do registro para a opção de organizar ícones automaticamente
$regPath = "HKCU:\SOFTWARE\Microsoft\Windows\Shell\Bags\1\Desktop"
$regName = "FFLAGS"

# Valor a ser configurado (1075839521 para ativar e 1075839520 para desativar)
if ($acao -eq "1") {
    $valor = 1075839521 # Ativar
} else {
    $valor = 1075839520 # Desativar
}

# Define o valor no registro
New-ItemProperty -Path $regPath -Name $regName -Value $valor -PropertyType DWORD -Force | Out-Null

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