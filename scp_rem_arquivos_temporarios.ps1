# Script para limpar arquivos temporários
# Cabeçalho
#----------------------------------------------------------------------------------------------
Write-Host "╔" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
write-host "╗" -ForegroundColor Cyan  

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Operação") -NoNewline
Write-Host ("{0,-86} " -f "Limpar arquivos temporários") -NoNewline -ForegroundColor Yellow
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
# Caminhos para limpeza
$paths = @(
    "$env:TEMP\*",
    [System.IO.Path]::Combine($env:LOCALAPPDATA, 'Microsoft\Windows\INetCache'),
    [System.IO.Path]::Combine($env:LOCALAPPDATA, 'Packages'),
    'C:\Windows\SoftwareDistribution\Download',
    'C:\Users\Public\AppData\Local\Microsoft\Windows\Explorer',
    'C:\Windows\Logs',
    [System.IO.Path]::Combine($env:LOCALAPPDATA, 'Temp'),
    [System.IO.Path]::Combine($env:LOCALAPPDATA, 'Apps')
)

foreach ($path in $paths) {
    # Obter arquivos e pastas no caminho especificado
    $items = Get-ChildItem -Path $path -ErrorAction SilentlyContinue -Recurse
    foreach ($item in $items) {
        try {
            # Tentar remover o item
            Remove-Item -Path $item.FullName -Force -Recurse -ErrorAction Stop
        } catch {
            # Ignorar erros ao tentar remover o item
        }
    }
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Pasta") -NoNewline -ForegroundColor White
    Write-Host ("{0,-86} " -f $path) -NoNewline -ForegroundColor Yellow
    Write-Host "║" -ForegroundColor Cyan
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Limpar") -NoNewline -ForegroundColor White
    Write-Host ("{0,-86} " -f "Arquivos Temporários - OK") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan
}

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
