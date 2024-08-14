Write-Host "╔" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
write-host "╗" -ForegroundColor Cyan  
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Operação") -NoNewline
Write-Host ("{0,-86} " -f "Definir informações de suporte") -NoNewline -ForegroundColor Yellow
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
# Defina o caminho para o Registro do Windows
$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation"

# Defina os valores a serem modificados
$values = @{
    "Manufacturer" = "Plena Soluções";
    "Model" = "Cliente Plena Soluções";
    "SupportPhone" = "11 91020-6022";
    #"SupportURL" = "http://www.novasuporte.com";
    "Logo" = "logo_plena.bmp";  # Substitua pelo caminho da nova imagem
}
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Tarefa") -NoNewline -ForegroundColor cyan
Write-Host ("{0,-86} " -f "Alterar Informações") -NoNewline -ForegroundColor cyan
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor gray
Write-Host "║" -ForegroundColor Cyan

# Verifique se o caminho do registro existe
if (Test-Path $registryPath) {
    # Crie ou atualize os valores no registro
    foreach ($name in $values.Keys) {
        Set-ItemProperty -Path $registryPath -Name $name -Value $values[$name]
    }
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Fabricante") -NoNewline -ForegroundColor White
    Write-Host ("{0,-86} " -f "Plena Soluções") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Modelo") -NoNewline -ForegroundColor White
    Write-Host ("{0,-86} " -f "Cliente Plena Soluções") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Telefone de Contato") -NoNewline -ForegroundColor White
    Write-Host ("{0,-86} " -f "11 91020-6022") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Logotipo") -NoNewline -ForegroundColor White
    Write-Host ("{0,-86} " -f "logo_plena.bmp") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Informações ") -NoNewline -ForegroundColor White
    Write-Host ("{0,-86} " -f "Erro ao gravar") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
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