﻿<#
    Função: Limpar o histórico de cores do Windows
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
& $cabecalhoScriptPath -Script $scriptName -Titulo "Remover o histórico de cores do Windows"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
# Função para apagar todo o conteúdo de uma chave de registro
function Remove-RegistryKeyContent {
    param (
        [string]$keyPath
    )
    
    if (Test-Path $keyPath) {
        # Obter todas as subchaves da chave principal
        $subKeys = Get-ChildItem -Path $keyPath -Recurse -ErrorAction SilentlyContinue

        foreach ($subKey in $subKeys) {
            try {
                $null=Remove-Item -Path $subKey.PSPath -Recurse -Force
                Write-Host "║" -NoNewline -ForegroundColor Cyan
                Write-Host ("{0,-30} : " -f "Sucesso ao remover") -NoNewline
                Write-Host ("{0,-86} " -f $subKey.PSPath) -NoNewline -ForegroundColor Green
                Write-Host "║" -ForegroundColor Cyan
            } catch {
                Write-Host "║" -NoNewline -ForegroundColor Cyan
                Write-Host ("{0,-30} : " -f "Erro ao remover") -NoNewline
                Write-Host ("{0,-86} " -f "$($subKey.PSPath): $($_.Exception.Message)") -NoNewline -ForegroundColor Red
                Write-Host "║" -ForegroundColor Cyan
            }
        }
        
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Sucesso ao remover") -NoNewline
        Write-Host ("{0,-86} " -f $keyPath) -NoNewline -ForegroundColor Green
        Write-Host "║" -ForegroundColor Cyan
    } else {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Alerta ao remover") -NoNewline
        Write-Host ("{0,-86} " -f "$keyPath não encontrada.") -NoNewline -ForegroundColor Yellow
        Write-Host "║" -ForegroundColor Cyan
    }
}

# Caminhos para as chaves de registro de cores
$RegPath1 = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent"
$RegPath2 = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\History\Colors"

# Apagar o conteúdo das chaves de registro de cores
$null=Remove-RegistryKeyContent -keyPath $RegPath1
$null=Remove-RegistryKeyContent -keyPath $RegPath2
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