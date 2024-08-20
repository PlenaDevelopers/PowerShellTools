param (
    [string]$Titulo = "Processo",
    [string]$Status = "Finalizado"
)
# Rodape
#----------------------------------------------------------------------------------------------
Write-Host "╚" -NoNewline -ForegroundColor Cyan
Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
Write-Host "╝" -ForegroundColor Cyan

Write-Host "╔" -NoNewline -ForegroundColor Cyan
Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
Write-Host "╗" -ForegroundColor Cyan 

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f $Titulo) -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f $Status) -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan

Write-Host "╚" -NoNewline -ForegroundColor Cyan
Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
Write-Host "╝" -ForegroundColor Cyan
#----------------------------------------------------------------------------------------------