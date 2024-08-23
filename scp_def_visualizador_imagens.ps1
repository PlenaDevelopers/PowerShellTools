<#
    Função: Ativar o "Visualizador de Imagens Clássico do Windows"
	Copyright: © Plena Soluções - 2024
	Date: Agosto/2024

	Licenciamento:
	Este script é fornecido "como está", sem qualquer garantia de qualquer tipo,
	expressa ou implícita, incluindo, mas não se limitando às garantias de 
	comercialização, adequação a um determinado fim e não violação. O uso deste 
	script é totalmente gratuito, mas você deve manter os créditos ao autor original.
	
	Seriais/Keys:
	Os Seriais/Keys para licenciamento de software contidos neste ou em outros
	arquivos são meramente ilustrativos para a utilização do script, sendo assim cabe
	ao utilizador do script alterar estas chaves para uma válida que represente o 
	licenciamento vigente.

	Bugs & Correções
	Em caso de Bugs encontrado pedimos a gentileza de informar por email para que possamos 
	analizar e gerar atualizações corretivas.

	Autor: Evandro Campanhã
	Contato: aurora.erp@gmail.com
	------------------------------------------------------------------------------
#>

# Cabecalho
#----------------------------------------------------------------------------------------------
# Obter o diretório do script atual
$scriptName = [System.IO.Path]::GetFileName($MyInvocation.MyCommand.Path)
$CurrentScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path

# Construir o caminho completo para o script 'scp_script_cabecalho.ps1'
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_script_cabecalho.ps1"

& $CabecalhoScriptPath -Script $scriptName -Titulo "Habilitar visualizador de imagens"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
# Configurações para photoviewer.dll
$photoviewerPath = "HKLM:\SOFTWARE\Classes\Applications\photoviewer.dll"
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Chave (photoviewer.dll)") -NoNewline
Write-Host ("{0,-86} " -f $photoviewerPath) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

# Shell -> Open
$openPath = Join-Path $photoviewerPath "shell\open"
$null = New-Item -Path $openPath -Force
$null = New-ItemProperty -Path $openPath -Name "MuiVerb" -Value "@photoviewer.dll,-3043" -Force
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Chave (Shell)") -NoNewline
Write-Host ("{0,-86} " -f $openPath) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

# Command
$commandPath = Join-Path $openPath "command"
$null = New-Item -Path $commandPath -Force
$null = New-ItemProperty -Path $commandPath -Name "(default)" -Value "C:\Windows\System32\rundll32.exe `C:\Windows\System32\photoviewer.dll`, ImageView_Fullscreen %1" -Force
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Chave (Comando)") -NoNewline
Write-Host ("{0,-86} " -f $commandPath) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

# DropTarget
$dropTargetPath = Join-Path $openPath "DropTarget"
$null = New-Item -Path $dropTargetPath -Force
$null = New-ItemProperty -Path $dropTargetPath -Name "Clsid" -Value "{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}" -Force
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Chave (Drop)") -NoNewline
Write-Host ("{0,-86} " -f $dropTargetPath) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

# Shell -> Print
$printPath = Join-Path $photoviewerPath "shell\print"
$null = New-Item -Path $printPath -Force
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Chave (Imprimir - Shell)") -NoNewline
Write-Host ("{0,-86} " -f $printPath) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

# Print Command
$printCommandPath = Join-Path $printPath "command"
$null = New-Item -Path $printCommandPath -Force
$null = New-ItemProperty -Path $printCommandPath -Name "(default)" -Value "C:\Windows\System32\rundll32.exe `C:\Windows\System32\photoviewer.dll`, ImageView_Fullscreen %1" -Force
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Chave (Imprimir)") -NoNewline
Write-Host ("{0,-86} " -f $printCommandPath) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

# Print DropTarget
$printDropTargetPath = Join-Path $printPath "DropTarget"
$null = New-Item -Path $printDropTargetPath -Force
$null = New-ItemProperty -Path $printDropTargetPath -Name "Clsid" -Value "{60fd46de-f830-4894-a628-6fa81bc0190d}" -Force
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Chave (Imprimir Drop)") -NoNewline
Write-Host ("{0,-86} " -f $printDropTargetPath) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

# File Associations
$fileAssociations = @(".jpg", ".jpeg", ".gif", ".png", ".bmp", ".tiff", ".ico")

foreach ($extension in $fileAssociations) {
    $extensionPath = "HKLM:\SOFTWARE\Classes\$extension"
    $null = New-ItemProperty -Path $extensionPath -Name "(default)" -Value "PhotoViewer.FileAssoc.Tiff" -Force
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Tipo de Arquivo") -NoNewline
    Write-Host ("{0,-86} " -f $extension) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
}
#----------------------------------------------------------------------------------------------

# Aplicando alterações
#----------------------------------------------------------------------------------------------
rundll32.exe user32.dll, UpdatePerUserSystemParameters
#----------------------------------------------------------------------------------------------

# Rodape
#----------------------------------------------------------------------------------------------
# Obter o diretório do script atual
$CurrentScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path

# Construir o caminho completo para o script 'scp_script_rodape.ps1'
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_script_rodape.ps1"

& $CabecalhoScriptPath
#----------------------------------------------------------------------------------------------