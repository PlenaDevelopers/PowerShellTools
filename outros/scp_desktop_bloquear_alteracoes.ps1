# Script para bloquear/desbloquear configurações de personalização
param (
    [string]$acao = "0" # "0" para desbloquear, "1" para bloquear
)

# Função para definir valores no Registro
function Set-RegistryValue {
    param (
        [string]$regPath,
        [string]$regName,
        [int]$regValue
    )
    
    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }
    
    Set-ItemProperty -Path $regPath -Name $regName -Value $regValue
}

# Bloqueio ou desbloqueio de alteração do papel de parede
Set-RegistryValue -regPath "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\ActiveDesktop" -regName "NoChangingWallPaper" -regValue $acao

# Bloqueio ou desbloqueio de alteração de cores de destaque
$regPathAccentColor = "HKCU:\Software\Policies\Microsoft\Windows\Personalization"
$regNameAccentColor = "NoChangingAccentColor"

if ($acao -eq "1") {
    # Bloqueio: Define a chave que impede a alteração de cores de destaque
    Set-RegistryValue -regPath $regPathAccentColor -regName $regNameAccentColor -regValue 1
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Alteração de Cores de Destaque") -NoNewline
    Write-Host ("{0,-86} " -f "Bloqueada") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan
} else {
    # Desbloqueio: Remove a chave que permite alteração de cores de destaque
    if (Test-Path $regPathAccentColor) {
        Remove-ItemProperty -Path $regPathAccentColor -Name $regNameAccentColor -ErrorAction SilentlyContinue
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Alteração de Cores de Destaque") -NoNewline
        Write-Host ("{0,-86} " -f "Desbloqueada") -NoNewline -ForegroundColor Green
        Write-Host "║" -ForegroundColor Cyan
    }
}

# Bloqueio ou desbloqueio de alteração da tela de fundo da tela de bloqueio
Set-RegistryValue -regPath "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" -regName "NoChangingLockScreen" -regValue $acao

# Bloqueio ou desbloqueio de alteração de fontes
Set-RegistryValue -regPath "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -regName "NoChangeFont" -regValue $acao

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
