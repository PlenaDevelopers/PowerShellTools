# Defina o caminho do Registro e os valores
$regPath = "HKCU:\Control Panel\Desktop"
$regName = "PaintDesktopVersion"
$regValue = 1

# Padronizar o Desktop
Write-Host "╔" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
write-host "╗" -ForegroundColor Cyan  
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Operação") -NoNewline
Write-Host ("{0,-86} " -f "Mostrar versão do Windows no Desktop") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Yellow
Write-Host ("{0,-30} : " -f " Copyright") -NoNewline
Write-Host ("{0,-86} " -f "2023 - Evandro Campanhã") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Yellow

$computerName = (Get-ComputerInfo).CsName
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Computador") -NoNewline
Write-Host ("{0,-86} " -f $computerName) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Script") -NoNewline
Write-Host ("{0,-86} " -f $MyInvocation.MyCommand.Path) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

Write-Host "╠" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
write-host "╣" -ForegroundColor Cyan

# Verifique se a chave do Registro existe
if (-not (Test-Path $regPath)) {
    # Crie a chave do Registro se não existir
    New-Item -Path $regPath -Force
}

# Verifique se o valor do Registro existe
if (-not (Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue)) {
    # Crie o valor do Registro se não existir
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Criar Chave") -NoNewline
    Write-Host ("{0,-86} " -f $regPath) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
    New-ItemProperty -Path $regPath -Name $regName -Value $regValue -PropertyType DWord

    if ($regValue -eq 1) {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f " Valor definido") -NoNewline
        Write-Host ("{0,-86} " -f "sim") -NoNewline -ForegroundColor White
        Write-Host "║" -ForegroundColor Cyan
    } else {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f " Valor definido") -NoNewline
        Write-Host ("{0,-86} " -f "não") -NoNewline -ForegroundColor White
        Write-Host "║" -ForegroundColor Cyan
    }
} else {
    # Atualize o valor do Registro se já existir
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Atualizar Chave") -NoNewline
    Write-Host ("{0,-86} " -f $regPath) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
    Set-ItemProperty -Path $regPath -Name $regName -Value $regValue

    if ($regValue -eq 1) {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f " Valor definido") -NoNewline
        Write-Host ("{0,-86} " -f "SIM") -NoNewline -ForegroundColor White
        Write-Host "║" -ForegroundColor Cyan
    } else {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f " Valor definido") -NoNewline
        Write-Host ("{0,-86} " -f "NÃO") -NoNewline -ForegroundColor White
        Write-Host "║" -ForegroundColor Cyan
    }
}

# Atualize as configurações para refletir as mudanças

RUNDLL32.EXE USER32.DLL,UpdatePerUserSystemParameters 1, True

#Final do Script
Write-Host "╠" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
write-host "╣" -ForegroundColor Cyan  

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Processo")   -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-86} " -f "Finalizado") -NoNewline -ForegroundColor Cyan
Write-Host "║" -ForegroundColor Cyan

Write-Host "╚" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
write-host "╝" -ForegroundColor Cyan
