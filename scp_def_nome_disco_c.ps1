# Rótulo desejado para o disco (substitua "Windows" pelo rótulo desejado)
Write-Host "╔" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
write-host "╗" -ForegroundColor Cyan  
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Operação") -NoNewline
Write-Host ("{0,-86} " -f "Renomear Disco") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Yellow
Write-Host ("{0,-30} : " -f " Copyright") -NoNewline
Write-Host ("{0,-86} " -f "2023 - Evandro Campanhã") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Yellow

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Script") -NoNewline
Write-Host ("{0,-86} " -f $MyInvocation.MyCommand.Path) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

Write-Host "╠" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
write-host "╣" -ForegroundColor Cyan

$novoRotulo = "windows"

# Obtém a letra da unidade onde o Windows está instalado
$windowsDrive = (Get-Item -LiteralPath $env:SystemRoot).PSDrive.Name

# Itera sobre os volumes
foreach ($volume in Get-Volume) {

    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Disco") -NoNewline
    Write-Host ("{0,-86} " -f $volume.FileSystemLabel) -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan

    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Sistema de Arquivos") -NoNewline
    Write-Host ("{0,-86} " -f $volume.FileSystem) -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan

    # Verifica se o volume é o volume do sistema
    if ($volume.DriveType -eq 'Fixed' -and $volume.DriveLetter -eq $windowsDrive) {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f " Unidade do Windows") -NoNewline
        Write-Host ("{0,-86} " -f "SIM") -NoNewline -ForegroundColor Green
        Write-Host "║" -ForegroundColor Cyan
    }
    Else {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f " Unidade do Windows") -NoNewline
        Write-Host ("{0,-86} " -f "NÃO") -NoNewline -ForegroundColor Gray
        Write-Host "║" -ForegroundColor Cyan
    }
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    write-host ("═" * 120) -NoNewline -ForegroundColor gray
    Write-Host "║" -ForegroundColor Cyan
}

foreach ($volume in Get-Volume) {
    # Verifica se o volume é o volume do sistema
    if ($volume.DriveType -eq 'Fixed' -and $volume.DriveLetter -eq $windowsDrive) {

        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f " Nome Anterior") -NoNewline
        Write-Host ("{0,-86} " -f $volume.FileSystemLabel) -NoNewline -ForegroundColor Gray
        Write-Host "║" -ForegroundColor Cyan

        # Renomeia o rótulo do volume
        Set-Volume -DriveLetter $volume.DriveLetter -NewFileSystemLabel $novoRotulo
        # Adiciona um pequeno atraso (por exemplo, 1 segundo)
        Start-Sleep -Seconds 3
        # Atualiza as configurações do sistema (opcional)
        rundll32.exe user32.dll, UpdatePerUserSystemParameters
        # Recupera o novo nome do volume
        $novoNome = (Get-Volume -DriveLetter $volume.DriveLetter).FileSystemLabel
        
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f " Novo Nome") -NoNewline
        Write-Host ("{0,-86} " -f $novoNome) -NoNewline -ForegroundColor Gray
        Write-Host "║" -ForegroundColor Cyan
    }
}

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