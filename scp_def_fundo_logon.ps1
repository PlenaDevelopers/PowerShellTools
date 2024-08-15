# Script para alterar o plano de fundo da tela de bloqueio
param (
    [string]$imagemCaminho = "$PSScriptRoot\wallpaper\wallpaper_default.jpg"
)

# Cabeçalho
#----------------------------------------------------------------------------------------------
Write-Host "╔" -NoNewline -ForegroundColor Cyan
Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
Write-Host "╗" -ForegroundColor Cyan  

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Operação") -NoNewline
Write-Host ("{0,-86} " -f "Alterar Imagem de Fundo") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Copyright") -NoNewline
Write-Host ("{0,-86} " -f "2023 - Evandro Campanhã") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Script") -NoNewline
Write-Host ("{0,-86} " -f $MyInvocation.MyCommand.Path) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

Write-Host "╠" -NoNewline -ForegroundColor Cyan
Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
Write-Host "╣" -ForegroundColor Cyan
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
# Caminho do diretório para copiar a imagem
$destinoImagem = "C:\Windows\Web\Screen\Lockscreen.jpg"

# Copia a imagem para o diretório de bloqueio de tela
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Copiando Imagem") -NoNewline
Write-Host ("{0,-86} " -f "De $imagemCaminho para $destinoImagem") -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

try {
    Copy-Item -Path $imagemCaminho -Destination $destinoImagem -Force
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Copia") -NoNewline
    Write-Host ("{0,-86} " -f "Imagem copiada com sucesso") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan
} catch {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Copia") -NoNewline
    Write-Host ("{0,-86} " -f "Falha ao copiar imagem: $_") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
    exit 1
}

# Caminho do registro para configurar a tela de bloqueio
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP"

# Verifica se o caminho do registro existe
if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}

# Define os valores no registro
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Aplicando Configuração") -NoNewline -ForegroundColor Red
Write-Host ("{0,-86} " -f "LockScreenImagePath, LockScreenImageUrl e LockScreenImageStatus definidos") -NoNewline -ForegroundColor Red
Write-Host "║" -ForegroundColor Cyan

try {
    Set-ItemProperty -Path $regPath -Name "LockScreenImagePath" -Value $destinoImagem
    Set-ItemProperty -Path $regPath -Name "LockScreenImageUrl" -Value $destinoImagem
    Set-ItemProperty -Path $regPath -Name "LockScreenImageStatus" -Value 1
} catch {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Configuração") -NoNewline
    Write-Host ("{0,-86} " -f "Falha ao definir configurações no registro: $_") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
    exit 1
}

# Ajusta permissões no diretório de sistema
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Ajustando Permissões") -NoNewline -ForegroundColor Red
Write-Host ("{0,-86} " -f "Ajustando permissões no diretório SystemData") -NoNewline -ForegroundColor Red
Write-Host "║" -ForegroundColor Cyan

try {
    $folderPath = "C:\ProgramData\Microsoft\Windows\SystemData"
    $acl = Get-Acl $folderPath
    $adminGroup = [System.Security.Principal.NTAccount]"Administradores"
    $rule = [System.Security.AccessControl.FileSystemAccessRule]::new($adminGroup, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
    $acl.AddAccessRule($rule)
    Set-Acl -Path $folderPath -AclObject $acl
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Permissões") -NoNewline
    Write-Host ("{0,-86} " -f "Permissões ajustadas com sucesso") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan
} catch {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Permissões") -NoNewline
    Write-Host ("{0,-86} " -f "Falha ao ajustar permissões: $_") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
}

# Desbloqueia a tela de configuração
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Desbloqueando Tela") -NoNewline -ForegroundColor Red
Write-Host ("{0,-86} " -f "Desbloqueando a tela de configuração, se necessário") -NoNewline -ForegroundColor Red
Write-Host "║" -ForegroundColor Cyan

try {
    # Reinicia o Windows Explorer para aplicar alterações e desbloquear configurações
    Stop-Process -Name explorer -Force
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Tela") -NoNewline
    Write-Host ("{0,-86} " -f "Tela desbloqueada") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan
} catch {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Tela") -NoNewline
    Write-Host ("{0,-86} " -f "Falha ao desbloquear a tela: $_") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
}

#----------------------------------------------------------------------------------------------

# Rodapé
#----------------------------------------------------------------------------------------------
Write-Host "╠" -NoNewline -ForegroundColor Cyan
Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
Write-Host "╣" -ForegroundColor Cyan  

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Processo") -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-86} " -f "Finalizado") -NoNewline -ForegroundColor Cyan
Write-Host "║" -ForegroundColor Cyan

Write-Host "╚" -NoNewline -ForegroundColor Cyan
Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
Write-Host "╝" -ForegroundColor Cyan
