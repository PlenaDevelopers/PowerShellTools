<#
    Função: Encerrar processos
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

param (
    [string]$processName = "notepad"  # Nome do processo a ser encerrado
)

# Cabeçalho
#----------------------------------------------------------------------------------------------
# Obter o diretório do script atual
$scriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path -Parent

# Obter o nome do script atual
$scriptName = [System.IO.Path]::GetFileName($MyInvocation.MyCommand.Path)

# Construir o caminho completo para o script 'scp_script_cabecalho.ps1'
$cabecalhoScriptPath = Join-Path -Path $scriptDirectory -ChildPath "scp_script_cabecalho.ps1"

# Executar o script de cabeçalho
& $cabecalhoScriptPath -Script $scriptName -Titulo "Encerrar processos"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
# Verifica se o nome do processo foi fornecido
if (-not $processName) {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Erro") -NoNewline
    Write-Host ("{0,-86} " -f "$processName não encontrado") -NoNewline -ForegroundColor DarkMagenta 
    Write-Host "║" -ForegroundColor Cyan
    exit
}

# Obtém todos os processos com o nome fornecido
$processes = Get-Process -Name $processName -ErrorAction SilentlyContinue

# Verifica se algum processo foi encontrado
if ($processes) {
    $processCount = $processes | Measure-Object | Select-Object -ExpandProperty Count
    
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Quantidade de Processos") -NoNewline
    Write-Host ("{0,-86} " -f "$processCount processo(s)") -NoNewline -ForegroundColor White 
    Write-Host "║" -ForegroundColor Cyan

    Write-Host "╠" -NoNewline -ForegroundColor Cyan
    write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
    write-host "╣" -ForegroundColor Cyan

    foreach ($process in $processes) {

        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "ID do Processo") -NoNewline
        Write-Host ("{0,-86} " -f $process.Id) -NoNewline -ForegroundColor White
        Write-Host "║" -ForegroundColor Cyan

        # Exibe a quantidade de memória usada pelo processo (em MB)
        $memoryUsedMB = [math]::Round($process.WorkingSet64 / 1MB, 2)
        
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Memória em Uso (MB)") -NoNewline
        Write-Host ("{0,-86} " -f "$memoryUsedMB MB") -NoNewline -ForegroundColor Yellow
        Write-Host "║" -ForegroundColor Cyan
        
        try {
            Stop-Process -Id $process.Id -Force

            Write-Host "║" -NoNewline -ForegroundColor Cyan
            Write-Host ("{0,-30} : " -f "Status") -NoNewline
            Write-Host ("{0,-86} " -f ("{0} encerrado" -f $process.ProcessName)) -NoNewline -ForegroundColor Green
            Write-Host "║" -ForegroundColor Cyan

            Write-Host "╠" -NoNewline -ForegroundColor Cyan
            write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
            write-host "╣" -ForegroundColor Cyan

        } catch {
            Write-Host "║" -NoNewline -ForegroundColor Cyan
            Write-Host ("{0,-30} : " -f "Status") -NoNewline
            Write-Host ("{0,-86} " -f ("Erro ao encerrar o processo {0}" -f $process.ProcessName)) -NoNewline -ForegroundColor Red
            Write-Host "║" -ForegroundColor Cyan

            Write-Host "╠" -NoNewline -ForegroundColor Cyan
            write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
            write-host "╣" -ForegroundColor Cyan
        }

    }
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Erro") -NoNewline
    Write-Host ("{0,-86} " -f "$processName não encontrado") -NoNewline -ForegroundColor DarkMagenta 
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