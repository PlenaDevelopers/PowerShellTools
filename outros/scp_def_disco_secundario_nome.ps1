#Script para alterar o nome do disco secundário
param(
    [string]$valor = 'arquivos'
)

# Verifica se a unidade "D" existe
if (Test-Path D:\) {
    # Renomeia a unidade D para o novo rótulo
    Set-Volume -DriveLetter D -NewFileSystemLabel $valor

    # Adiciona um pequeno atraso (por exemplo, 3 segundos)
    Start-Sleep -Seconds 3

    # Atualiza as configurações do sistema (opcional)
    rundll32.exe user32.dll, UpdatePerUserSystemParameters
}