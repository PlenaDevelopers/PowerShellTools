param (
    [string]$nome_pc = "temp-pc"
)

# Cabeçalho
#----------------------------------------------------------------------------------------------
Write-Host "╔" -NoNewline -ForegroundColor Cyan
Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
Write-Host "╗" -ForegroundColor Cyan  

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Operação") -NoNewline
Write-Host ("{0,-86} " -f "Renomear Computador") -NoNewline -ForegroundColor Yellow
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
Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
Write-Host "╣" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Nome Atual") -NoNewline
Write-Host ("{0,-86} " -f $($env:COMPUTERNAME)) -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
# Nome atual do computador
$currentComputerName = $env:COMPUTERNAME

# Novo nome desejado
$novoNome = $nome_pc

# Verifica se o nome atual é diferente do novo nome
if ($currentComputerName -ne $novoNome) {
    # Renomear o computador e suprimir mensagens
    $null = Rename-Computer -NewName $novoNome -Force -Restart:$false -PassThru 2>$null
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Status") -NoNewline
    Write-Host ("{0,-86} " -f "O computador foi renomeado para: $novoNome") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan
}
else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Status") -NoNewline
    Write-Host ("{0,-86} " -f "O nome não foi alterado pois é igual ao anterior") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan
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