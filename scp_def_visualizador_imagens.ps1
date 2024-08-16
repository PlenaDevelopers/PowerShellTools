# Scipt para ativar o "Visualizador de Imagens Clássico"
# Cabeçalho
#----------------------------------------------------------------------------------------------
Write-Host "╔" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
write-host "╗" -ForegroundColor Cyan  

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Operação") -NoNewline
Write-Host ("{0,-86} " -f "Configurar Visualizador de Imagens do Windows") -NoNewline -ForegroundColor Yellow
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
# Configurações para photoviewer.dll
$photoviewerPath = "HKLM:\SOFTWARE\Classes\Applications\photoviewer.dll"
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Chave (photoviewer.dll)") -NoNewline
Write-Host ("{0,-86} " -f $photoviewerPath) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

# Shell -> Open
$openPath = Join-Path $photoviewerPath "shell\open"
$null = New-Item -Path $openPath -Force
$null = New-ItemProperty -Path $openPath -Name "MuiVerb" -Value "@photoviewer.dll,-3043" -Force
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Chave (Shell)") -NoNewline
Write-Host ("{0,-86} " -f $openPath) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

# Command
$commandPath = Join-Path $openPath "command"
$null = New-Item -Path $commandPath -Force
$null = New-ItemProperty -Path $commandPath -Name "(default)" -Value "C:\Windows\System32\rundll32.exe `C:\Windows\System32\photoviewer.dll`, ImageView_Fullscreen %1" -Force
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Chave (Comando)") -NoNewline
Write-Host ("{0,-86} " -f $commandPath) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

# DropTarget
$dropTargetPath = Join-Path $openPath "DropTarget"
$null = New-Item -Path $dropTargetPath -Force
$null = New-ItemProperty -Path $dropTargetPath -Name "Clsid" -Value "{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}" -Force
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Chave (Drop)") -NoNewline
Write-Host ("{0,-86} " -f $dropTargetPath) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

# Shell -> Print
$printPath = Join-Path $photoviewerPath "shell\print"
$null = New-Item -Path $printPath -Force
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Chave (Imprimir - Shell)") -NoNewline
Write-Host ("{0,-86} " -f $printPath) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

# Print Command
$printCommandPath = Join-Path $printPath "command"
$null = New-Item -Path $printCommandPath -Force
$null = New-ItemProperty -Path $printCommandPath -Name "(default)" -Value "C:\Windows\System32\rundll32.exe `C:\Windows\System32\photoviewer.dll`, ImageView_Fullscreen %1" -Force
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Chave (Imprimir)") -NoNewline
Write-Host ("{0,-86} " -f $printCommandPath) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

# Print DropTarget
$printDropTargetPath = Join-Path $printPath "DropTarget"
$null = New-Item -Path $printDropTargetPath -Force
$null = New-ItemProperty -Path $printDropTargetPath -Name "Clsid" -Value "{60fd46de-f830-4894-a628-6fa81bc0190d}" -Force
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Chave (Imprimir Drop)") -NoNewline
Write-Host ("{0,-86} " -f $printDropTargetPath) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

# File Associations
$fileAssociations = @(".jpg", ".jpeg", ".gif", ".png", ".bmp", ".tiff", ".ico")

foreach ($extension in $fileAssociations) {
    $extensionPath = "HKLM:\SOFTWARE\Classes\$extension"
    $null = New-ItemProperty -Path $extensionPath -Name "(default)" -Value "PhotoViewer.FileAssoc.Tiff" -Force
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Tipo de Arquivo") -NoNewline
    Write-Host ("{0,-86} " -f $extension) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
}
#----------------------------------------------------------------------------------------------

# Aplicando alterações
#----------------------------------------------------------------------------------------------
# Aplicar alterações
rundll32.exe user32.dll, UpdatePerUserSystemParameters

# Verificar se o processo explorer está em execução
$explorerProcess = Get-Process -Name explorer -ErrorAction SilentlyContinue

if ($explorerProcess) {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Reiniciando Processo") -NoNewline
    Write-Host ("{0,-86} " -f "Windows Explorer") -NoNewline -ForegroundColor Cyan
    Write-Host "║" -ForegroundColor Cyan
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Start-Process explorer -WindowStyle Hidden
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Iniciando Processo") -NoNewline
    Write-Host ("{0,-86} " -f "Windows Explorer") -NoNewline -ForegroundColor Cyan
    Write-Host "║" -ForegroundColor Cyan
    Start-Process explorer -WindowStyle Hidden
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