#Script para alternar entre diferentes temas do Windows 10

param (
    [string]$Tema = "Claro"
)

# Caminho do Registro
$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
$regName = "SystemUsesLightTheme"

# Valor a ser configurado
switch ($Tema) {
    "Claro" {
        $regValue = 1
        break
    }
    "Escuro" {
        $regValue = 0
        break
    }

}

# Definir o valor no Registro
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
