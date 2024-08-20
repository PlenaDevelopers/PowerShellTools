# Script para alterar o rótulo da "Unidade D"

# Cabecalho
#----------------------------------------------------------------------------------------------
# Obter o diretório do script atual
$scriptName = [System.IO.Path]::GetFileName($MyInvocation.MyCommand.Path)
$CurrentScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path

# Construir o caminho completo para o script 'scp_script_cabecalho.ps1'
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_script_cabecalho.ps1"

& $CabecalhoScriptPath -Script $scriptName -Titulo "Renomear disco secundário"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
# Rótulo desejado para o disco (substitua "Windows" pelo rótulo desejado)
$novoRotulo = "arquivos"

# Obtém a letra da unidade onde o Windows está instalado
$windowsDrive = (Get-Item -LiteralPath $env:SystemRoot).PSDrive.Name

# Verifica se a unidade D: existe
if (Test-Path -Path "D:\") {
    try {
        # Obtém informações sobre a unidade D:
        $volumeD = Get-Volume -DriveLetter D -ErrorAction Stop

        # Verifica se é um disco rígido interno e se é a unidade D:
        if ($volumeD.DriveType -eq 'Fixed' -and $volumeD.DriveLetter -eq 'D') {

        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Disco") -NoNewline
        Write-Host ("{0,-86} " -f $volumeD.FileSystemLabel) -NoNewline -ForegroundColor White
        Write-Host "║" -ForegroundColor Cyan

        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Sistema de Arquivos") -NoNewline
        Write-Host ("{0,-86} " -f $volumeD.FileSystem) -NoNewline -ForegroundColor White
        Write-Host "║" -ForegroundColor Cyan

        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("═" * 120) -NoNewline -ForegroundColor gray
        Write-Host "║" -ForegroundColor Cyan

            Write-Host "║" -NoNewline -ForegroundColor Cyan
            Write-Host ("{0,-30} : " -f "Nome Anterior") -NoNewline
            Write-Host ("{0,-86} " -f $volumeD.FileSystemLabel) -NoNewline -ForegroundColor White
            Write-Host "║" -ForegroundColor Cyan
            
            # Renomeia o rótulo do volume
            Set-Volume -DriveLetter $volumeD.DriveLetter -NewFileSystemLabel $novoRotulo
            
            # Adiciona um pequeno atraso (por exemplo, 1 segundo)
            Start-Sleep -Seconds 3
            
            # Atualiza as configurações do sistema (opcional)
            rundll32.exe user32.dll, UpdatePerUserSystemParameters
            
            # Recupera o novo nome do volume
            $novoNome = (Get-Volume -DriveLetter $volumeD.DriveLetter).FileSystemLabel
            
            Write-Host "║" -NoNewline -ForegroundColor Cyan
            Write-Host ("{0,-30} : " -f "Novo Nome") -NoNewline
            Write-Host ("{0,-86} " -f $novoNome) -NoNewline -ForegroundColor Green
            Write-Host "║" -ForegroundColor Cyan

        } else {
            Write-Host "║" -NoNewline -ForegroundColor Cyan
            Write-Host ("{0,-30} : " -f "Status") -NoNewline
            Write-Host ("{0,-86} " -f "A unidade D: não é um disco rígido interno") -NoNewline -ForegroundColor Red
            Write-Host "║" -ForegroundColor Cyan
        }
    } catch {
            Write-Host "║" -NoNewline -ForegroundColor Cyan
            Write-Host ("{0,-30} : " -f "Status") -NoNewline
            Write-Host ("{0,-86} " -f "Erro ao obter informações sobre a unidade D:") -NoNewline -ForegroundColor Red
            Write-Host "║" -ForegroundColor Cyan
    }
} else {
            Write-Host "║" -NoNewline -ForegroundColor Cyan
            Write-Host ("{0,-30} : " -f "Status") -NoNewline
            Write-Host ("{0,-86} " -f "A unidade D: não existe no computador:") -NoNewline -ForegroundColor Red
            Write-Host "║" -ForegroundColor Cyan
}
#----------------------------------------------------------------------------------------------

# Aplicando alterações
#----------------------------------------------------------------------------------------------
# Aplicar alterações
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