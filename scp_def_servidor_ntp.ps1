<#
    Função: Configurar servidor NTP
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
& $cabecalhoScriptPath -Script $scriptName -Titulo "Alterar o servidor NTP"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
# Ajustar o servidor NTP para 200.160.7.186
$Service = Get-Service -Name w32time

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Nome do Serviço") -NoNewline
Write-Host ("{0,-86} " -f $Service.ServiceName) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Status do Serviço") -NoNewline
Write-Host ("{0,-86} " -f $Service.Status) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Inicialização do Serviço") -NoNewline
Write-Host ("{0,-86} " -f $Service.StartType) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Tarefa") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "Iniciar o serviço") -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor gray
Write-Host "║" -ForegroundColor Cyan

Set-Service -Name $Service.ServiceName -StartupType Automatic
Start-Service -Name $Service.ServiceName
Start-Sleep -Seconds 5

if ($Service.Status -eq 'Running') {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Status do Serviço") -NoNewline
    Write-Host ("{0,-86} " -f "O serviço $($Service.DisplayName) está em execução.") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan
}
else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Status do Serviço") -NoNewline
    Write-Host ("{0,-86} " -f "O serviço $($Service.DisplayName) não está em execução.") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
}

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Tarefa") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "Ajustar o fuso-horário") -NoNewline -ForegroundColor cyan
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor gray
Write-Host "║" -ForegroundColor Cyan

# Obter informações do fuso horário atual
$timeZone = [System.TimeZoneInfo]::Local
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Fuso-horário anterior") -NoNewline
Write-Host ("{0,-86} " -f $($timeZone.Id)) -NoNewline -ForegroundColor yellow
Write-Host "║" -ForegroundColor Cyan

Set-TimeZone -Id "E. South America Standard Time"

$timeZone = [System.TimeZoneInfo]::Local
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Fuso-horário atual") -NoNewline
Write-Host ("{0,-86} " -f $($timeZone.Id)) -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Tarefa") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "Ajustar o servidor NTP para 200.160.7.186") -NoNewline -ForegroundColor cyan
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor gray
Write-Host "║" -ForegroundColor Cyan

$null = w32tm /config /manualpeerlist:"200.160.7.186" /syncfromflags:manual /reliable:YES /update
$null = w32tm /resync

# Armazenar a saída do comando w32tm /query /status em uma variável
$statusInfo = w32tm /query /status

# Obter a fonte de tempo configurada
$ntpSource = w32tm /query /source
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Fonte de Tempo") -NoNewline
Write-Host ("{0,-86} " -f $($ntpSource)) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

$currentDateTime = Get-Date
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Hora atual") -NoNewline
Write-Host ("{0,-86} " -f $($currentDateTime)) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan
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