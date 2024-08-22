#Script para alterar o nome do disco do Windows
param(
    [string]$valor = 'windows'
)

# Obtém a letra da unidade onde o Windows está instalado
$systemDrive = $env:SystemDrive.Substring(0,1)

# Renomeia a unidade com o novo rótulo
Set-Volume -DriveLetter $systemDrive -NewFileSystemLabel $valor

# Adiciona um pequeno atraso (por exemplo, 1 segundo)
Start-Sleep -Seconds 3

# Atualiza as configurações do sistema (opcional)
rundll32.exe user32.dll, UpdatePerUserSystemParameters