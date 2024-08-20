param (
    [string]$Titulo = "Processo",
    [string]$Status = "Finalizado"
)
# Rodape
#----------------------------------------------------------------------------------------------
Write-Host "╠" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
write-host "╣" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Yellow
Write-Host ("{0,-30} : " -f $Titulo) -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f $Status) -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Yellow

Write-Host "╚" -NoNewline -ForegroundColor Yellow
Write-Host ("═" * 120) -NoNewline -ForegroundColor Yellow
Write-Host "╝" -ForegroundColor Yellow
#----------------------------------------------------------------------------------------------