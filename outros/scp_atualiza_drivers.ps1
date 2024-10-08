﻿<#
    Função: Atualizar Drivers
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
    [string]$diretorio = "d:\drivers"
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
& $cabecalhoScriptPath -Script $scriptName -Titulo "Atualizar Drivers"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
# Verifica se o parâmetro foi passado e se o diretório existe
if (-not (Test-Path -Path $diretorio)) {
    Write-Host "Erro: O diretório '$direotrio' não foi encontrado." -ForegroundColor Red

    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Erro") -NoNewline
    Write-Host ("{0,-86} " -f "Diretorio não encontrado") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan

    exit
}

# Obtém todos os dispositivos de armazenamento no sistema
$storageDevices = Get-WmiObject -Query "SELECT * FROM Win32_DiskDrive"

foreach ($device in $storageDevices) {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Pesquisando") -NoNewline
    Write-Host ("{0,-86} " -f $($device.Model)) -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan
    
    # Atualiza o driver usando a pasta informada como base
    $devicePNP = Get-WmiObject Win32_PnPEntity | Where-Object { $_.DeviceID -eq $device.DeviceID }

    if ($devicePNP) {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Atualizando") -NoNewline
        Write-Host ("{0,-86} " -f $($device.Model)) -NoNewline -ForegroundColor Green
        Write-Host "║" -ForegroundColor Cyan
        
        # Forçar a atualização do driver (usando pnputil)
        $updateDriverCmd = "pnputil /add-driver ""$diretorio\*.inf"" /install"
        
        try {
            # Executa o comando para atualizar o driver
            Invoke-Expression $updateDriverCmd
            Write-Host "Driver atualizado para o dispositivo: $($devicePNP.Name)" -ForegroundColor Green

            Write-Host "║" -NoNewline -ForegroundColor Cyan
            Write-Host ("{0,-30} : " -f "Driver Atualizado") -NoNewline
            Write-Host ("{0,-86} " -f $($device.Model)) -NoNewline -ForegroundColor Green
            Write-Host "║" -ForegroundColor Cyan

        } catch {
            Write-Host "║" -NoNewline -ForegroundColor Cyan
            Write-Host ("{0,-30} : " -f "Erro ao Atualizar") -NoNewline
            Write-Host ("{0,-86} " -f $($device.Model)) -NoNewline -ForegroundColor White
            Write-Host "║" -ForegroundColor Cyan
        }
    } else {
            Write-Host "║" -NoNewline -ForegroundColor Cyan
            Write-Host ("{0,-30} : " -f "Erro ao Atualizar") -NoNewline
            Write-Host ("{0,-86} " -f "Driver não localizado") -NoNewline -ForegroundColor White
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