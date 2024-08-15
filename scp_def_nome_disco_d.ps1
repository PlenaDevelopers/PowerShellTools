﻿# Script para alterar o rótulo da "Unidade D"
# Cabeçalho
#----------------------------------------------------------------------------------------------
Write-Host "╔" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
write-host "╗" -ForegroundColor Cyan  

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Operação") -NoNewline
Write-Host ("{0,-86} " -f "Renomear Disco D:") -NoNewline -ForegroundColor Yellow
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
write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
write-host "╣" -ForegroundColor Cyan
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
# Rótulo desejado para o disco (substitua "Windows" pelo rótulo desejado)
$novoRotulo = "arquivos"

# Obtém a letra da unidade onde o Windows está instalado
$windowsDrive = (Get-Item -LiteralPath $env:SystemRoot).PSDrive.Name

# Verifica se a unidade D: existe
if (Test-Path -Path "D:\") {
    try {
        # Obtém informações sobre a unidade D:
        $volumeD = Get-Volume -DriveLetter D -ErrorAction Stop

        # Verifica se é um disco rígido interno e se é a unidade D:
        if ($volumeD.DriveType -eq 'Fixed' -and $volumeD.DriveLetter -eq 'D') {

            Write-Host "║" -NoNewline -ForegroundColor Cyan
            Write-Host ("{0,-30} : " -f " Nome Anterior") -NoNewline
            Write-Host ("{0,-86} " -f $volumeD.FileSystemLabel) -NoNewline -ForegroundColor Gray
            Write-Host "║" -ForegroundColor Cyan
            
            # Renomeia o rótulo do volume
            Set-Volume -DriveLetter $volumeD.DriveLetter -NewFileSystemLabel $novoRotulo
            
            # Adiciona um pequeno atraso (por exemplo, 1 segundo)
            Start-Sleep -Seconds 3
            
            # Atualiza as configurações do sistema (opcional)
            rundll32.exe user32.dll, UpdatePerUserSystemParameters
            
            # Recupera o novo nome do volume
            $novoNome = (Get-Volume -DriveLetter $volumeD.DriveLetter).FileSystemLabel
            
            Write-Host "║" -NoNewline -ForegroundColor Cyan
            Write-Host ("{0,-30} : " -f " Novo Nome") -NoNewline
            Write-Host ("{0,-86} " -f $novoNome) -NoNewline -ForegroundColor Gray
            Write-Host "║" -ForegroundColor Cyan

        } else {
            Write-Host "A unidade D: não é um disco rígido interno ou não é a unidade D:."
        }
    } catch {
        Write-Host "Erro ao obter informações sobre a unidade D: $_"
    }
} else {
    Write-Host "A unidade D: não existe no computador."
}
#----------------------------------------------------------------------------------------------

# Reiniciar O Windows Explorer
rundll32.exe user32.dll, UpdatePerUserSystemParameters
get-process explorer | Stop-Process -Force
#----------------------------------------------------------------------------------------------

# Rodape
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