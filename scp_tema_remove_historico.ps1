param ()

# Remover o histórico de cores usadas
Write-Host "╔" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
write-host "╗" -ForegroundColor Cyan  
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Operação") -NoNewline
Write-Host ("{0,-86} " -f "Remover histórico de cores") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Yellow
Write-Host ("{0,-30} : " -f " Copyright") -NoNewline
Write-Host ("{0,-86} " -f "2024 - Evandro Campanhã") -NoNewline -ForegroundColor Yellow
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

# Função para apagar todo o conteúdo de uma chave de registro
function Remove-RegistryKeyContent {
    param (
        [string]$keyPath
    )
    
    if (Test-Path $keyPath) {
        # Obter todas as subchaves da chave principal
        $subKeys = Get-ChildItem -Path $keyPath -Recurse

        foreach ($subKey in $subKeys) {
            try {
                Remove-Item -Path $subKey.PSPath -Recurse -Force
                Write-Host "║" -NoNewline -ForegroundColor Cyan
                Write-Host ("{0,-30} : " -f " Sucesso ao remover") -NoNewline
                Write-Host ("{0,-86} " -f $subKey.PSPath) -NoNewline -ForegroundColor Green
                Write-Host "║" -ForegroundColor Cyan
            } catch {
                Write-Host "║" -NoNewline -ForegroundColor Cyan
                Write-Host ("{0,-30} : " -f " Erro ao remover") -NoNewline
                Write-Host ("{0,-86} " -f "$($subKey.PSPath): $($_.Exception.Message)") -NoNewline -ForegroundColor Red
                Write-Host "║" -ForegroundColor Cyan
            }
        }
        
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f " Sucesso ao remover") -NoNewline
        Write-Host ("{0,-86} " -f $keyPath) -NoNewline -ForegroundColor Green
        Write-Host "║" -ForegroundColor Cyan
    } else {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f " Alerta ao remover") -NoNewline
        Write-Host ("{0,-86} " -f "$keyPath não encontrada.") -NoNewline -ForegroundColor Yellow
        Write-Host "║" -ForegroundColor Cyan
    }
}

# Caminhos para as chaves de registro de cores
$RegPath1 = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent"
$RegPath2 = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\History\Colors"

# Apagar o conteúdo das chaves de registro de cores
Remove-RegistryKeyContent -keyPath $RegPath1
Remove-RegistryKeyContent -keyPath $RegPath2

# Reiniciar o processo explorer para aplicar as mudanças
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue

# Final do Script
Write-Host "╠" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
write-host "╣" -ForegroundColor Cyan  

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Processo") -NoNewline
Write-Host ("{0,-86} " -f "Finalizado") -NoNewline -ForegroundColor Cyan
Write-Host "║" -ForegroundColor Cyan

Write-Host "╚" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
write-host "╝" -ForegroundColor Cyan
