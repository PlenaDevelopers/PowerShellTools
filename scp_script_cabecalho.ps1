param (
    [string]$CopyRight = "Evandro Campanhã",
    [string]$Script = "",
    [string]$Titulo = "Processo"
)

$anoAtual = (Get-Date).Year
# Cabeçalho
#----------------------------------------------------------------------------------------------
Write-Host "╔" -NoNewline -ForegroundColor Cyan
Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
Write-Host "╗" -ForegroundColor Cyan  

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Operação") -NoNewline
Write-Host ("{0,-86} " -f $Titulo) -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Produção") -NoNewline
Write-Host ("{0,-86} " -f $anoAtual) -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Copyright") -NoNewline
Write-Host ("{0,-86} " -f $CopyRight) -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Script") -NoNewline
Write-Host ("{0,-86} " -f $Script) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

Write-Host "╚" -NoNewline -ForegroundColor Cyan
Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
Write-Host "╝" -ForegroundColor Cyan

Write-Host "╔" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
write-host "╗" -ForegroundColor Cyan
#----------------------------------------------------------------------------------------------