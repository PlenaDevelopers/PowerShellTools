<#
    Função: Renomear a unidade de disco D, se houver
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
# Cabeçalho
#----------------------------------------------------------------------------------------------
# Obter o diretório do script atual
$scriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path -Parent

# Obter o nome do script atual
$scriptName = [System.IO.Path]::GetFileName($MyInvocation.MyCommand.Path)

# Construir o caminho completo para o script 'scp_script_cabecalho.ps1'
$cabecalhoScriptPath = Join-Path -Path $scriptDirectory -ChildPath "scp_script_cabecalho.ps1"

# Executar o script de cabeçalho
& $cabecalhoScriptPath -Script $scriptName -Titulo "Renomear o disco D"
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
rundll32.exe user32.dll, UpdatePerUserSystemParameters
#----------------------------------------------------------------------------------------------

# Rodapé
#----------------------------------------------------------------------------------------------
# Obter o diretório do script atual
$CurrentScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path -Parent

# Construir o caminho completo para o script 'scp_script_rodape.ps1'
$rodapeScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_script_rodape.ps1"

# Executar o script de rodapé
& $rodapeScriptPath
#----------------------------------------------------------------------------------------------