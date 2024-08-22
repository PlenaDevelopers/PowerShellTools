# Script para recuperar o Serial OEM do Windows na BIOS
#-------------------------------------------------------
$osVersion = (Get-WmiObject -Class Win32_OperatingSystem).Caption

Write-Host "Sistema Operacional: $osVersion" -ForegroundColor Cyan
Write-Host "Buscando o Serial OEM do Windows na BIOS..." -ForegroundColor Yellow

try {
    $oemKey = (Get-WmiObject -Query 'SELECT * FROM SoftwareLicensingService').OA3xOriginalProductKey

    if ($oemKey) {
        Write-Host "O Serial OEM encontrado na BIOS é:" -ForegroundColor Green
        Write-Host $oemKey -ForegroundColor White
    } else {
        Write-Host "Nenhum Serial OEM foi encontrado na BIOS." -ForegroundColor Red
    }
} catch {
    Write-Host "Erro ao tentar recuperar o Serial OEM." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}
