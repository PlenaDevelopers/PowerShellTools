<#
    Função: Exportar Drivers
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

# Define o diretório de backup de drivers
$backupDir = "C:\Temp\Drivers"
# Cabeçalho
#----------------------------------------------------------------------------------------------
# Obter o diretório do script atual
$scriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path -Parent

# Obter o nome do script atual
$scriptName = [System.IO.Path]::GetFileName($MyInvocation.MyCommand.Path)

# Construir o caminho completo para o script 'scp_script_cabecalho.ps1'
$cabecalhoScriptPath = Join-Path -Path $scriptDirectory -ChildPath "scp_script_cabecalho.ps1"

# Executar o script de cabeçalho
& $cabecalhoScriptPath -Script $scriptName -Titulo "Exportar Drivers"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
# Cria a pasta de destino, caso ela não exista
if (-not (Test-Path $backupDir)) {
    New-Item -Path $backupDir -ItemType Directory | Out-Null

    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Diretorio") -NoNewline
    Write-Host ("{0,-86} " -f "$backupDir criado") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan
}

# Exporta todos os drivers instalados para o diretório de destino
$drivers = Export-WindowsDriver -Online -Destination $backupDir

# Exporta as informações dos drivers para um arquivo texto
$drivers | Format-Table ProviderName, ClassName, Date, Version -AutoSize | Out-File "$backupDir\drivers.txt"

# Função para obter o nome do dispositivo a partir do arquivo INF
function Get-DeviceNameFromInf {
    param (
        [string]$infPath
    )

    # Tenta abrir e ler o arquivo INF
    try {
        $infContent = Get-Content $infPath -Raw
        # Procurar a seção que contém o nome do dispositivo
        if ($infContent -match 'DeviceDescription\s*=\s*"(.+?)"') {
            return $matches[1]
        } else {
            Write-Host "║" -NoNewline -ForegroundColor Cyan
            Write-Host ("{0,-30} : " -f "Status") -NoNewline
            Write-Host ("{0,-86} " -f "Erro no INF: $infPath") -NoNewline -ForegroundColor White
            Write-Host "║" -ForegroundColor Cyan

            return $null
        }
    } catch {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Status") -NoNewline
        Write-Host ("{0,-86} " -f "Não foi possível ler o arquivo INF: $infPath") -NoNewline -ForegroundColor Green
        Write-Host "║" -ForegroundColor Cyan

        return $null
    }
}

# Obtém todas as subpastas no diretório de backup
$subfolders = Get-ChildItem -Path $backupDir -Directory

foreach ($folder in $subfolders) {
    $deviceNames = @()

    # Obtém todos os arquivos INF dentro da subpasta
    $infFiles = Get-ChildItem -Path $folder.FullName -Filter *.inf -File

    foreach ($infFile in $infFiles) {
        # Obtém o nome do dispositivo a partir do arquivo INF
        $deviceName = Get-DeviceNameFromInf -infPath $infFile.FullName

        if ($deviceName) {
            # Adiciona o nome do dispositivo à lista
            $deviceNames += $deviceName
        }
    }

    if ($deviceNames.Count -gt 0) {
        # Usa o primeiro nome de dispositivo encontrado ou um nome padrão se a lista estiver vazia
        $finalDeviceName = $deviceNames[0] -replace '[\\/:*?"<>|]', '-'
        $newFolderName = Join-Path $backupDir $finalDeviceName

        # Renomeia a pasta, se necessário
        if ($folder.FullName -ne $newFolderName) {

            Write-Host "║" -NoNewline -ForegroundColor Cyan
            Write-Host ("{0,-30} : " -f "Status") -NoNewline
            Write-Host ("{0,-86} " -f "Renomeando a pasta '$($folder.FullName)' para '$newFolderName'") -NoNewline -ForegroundColor Green
            Write-Host "║" -ForegroundColor Cyan

            Rename-Item -Path $folder.FullName -NewName $finalDeviceName -Force
        }
    } else {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Status") -NoNewline
        Write-Host ("{0,-86} " -f "Erro ao renomear a pasta '$($folder.FullName)'") -NoNewline -ForegroundColor DarkCyan
        Write-Host "║" -ForegroundColor Cyan
    }
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