<#
    Função: Configuração Windows Defender
    Copyright: © Plena Soluções - 2024
    Date: Setembro/2024

    Licenciamento:
    Este script é fornecido "como está", sem qualquer garantia de qualquer tipo,
    expressa ou implícita, incluindo, mas não se limitando às garantias de 
    comercialização, adequação a um determinado fim e não violação. O uso deste 
    script é totalmente gratuito, mas você deve manter os créditos ao autor original.
    
    Bugs & Correções
    Em caso de Bugs encontrados pedimos a gentileza de informar por email para que possamos 
    analisar e gerar atualizações corretivas.

    Autor: Evandro Campanhã
    Contato: aurora.erp@gmail.com
    ------------------------------------------------------------------------------
#>

# Função: Configuração Windows Defender
param (
    [string]$Action = "0" # "0" - Desabilitar, "1" - Habilitar
)

# Cabeçalho
#----------------------------------------------------------------------------------------------
$scriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
$scriptName = [System.IO.Path]::GetFileName($MyInvocation.MyCommand.Path)
$cabecalhoScriptPath = Join-Path -Path $scriptDirectory -ChildPath "scp_script_cabecalho.ps1"
& $cabecalhoScriptPath -Script $scriptName -Titulo "Configuração Windows Defender"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
$keyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"
$rtKeyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection"
$ssKeyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\SmartScreen"
$suKeyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates"
$spKeyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet"
$mfKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows Defender\Features"

# Criar as chaves de registro se não existirem
$paths = @($keyPath, $rtKeyPath, $ssKeyPath, $suKeyPath, $spKeyPath, $mfKeyPath)
foreach ($path in $paths) {
    if (-not (Test-Path $path)) {
        New-Item -Path $path -Force | Out-Null
    }
}

# Definir valores no registro
$regEntries = @(
    @{ Path = $keyPath; Name = "DisableAntiSpyware"; Value = 1 },
    @{ Path = $keyPath; Name = "DisableRealtimeMonitoring"; Value = 1 },
    @{ Path = $keyPath; Name = "DisableAntiVirus"; Value = 1 },
    @{ Path = $keyPath; Name = "DisableSpecialRunningModes"; Value = 1 },
    @{ Path = $keyPath; Name = "DisableRoutinelyTakingAction"; Value = 1 },
    @{ Path = $keyPath; Name = "ServiceKeepAlive"; Value = 0 },
    @{ Path = $rtKeyPath; Name = "DisableBehaviorMonitoring"; Value = 1 },
    @{ Path = $rtKeyPath; Name = "DisableOnAccessProtection"; Value = 1 },
    @{ Path = $rtKeyPath; Name = "DisableScanOnRealtimeEnable"; Value = 1 },
    @{ Path = $rtKeyPath; Name = "DisableIOAVProtection"; Value = 1 },
    @{ Path = $rtKeyPath; Name = "DisableRealtimeMonitoring"; Value = 1 },
    @{ Path = $ssKeyPath; Name = "ConfigureAppInstallControlEnabled"; Value = 0 },
    @{ Path = $suKeyPath; Name = "ForceUpdateFromMU"; Value = 0 },
    @{ Path = $spKeyPath; Name = "DisableBlockAtFirstSeen"; Value = 1 },
    @{ Path = $spKeyPath; Name = "SubmitSamplesConsent"; Value = 2 },
    @{ Path = $spKeyPath; Name = "SpynetReporting"; Value = 0 },
    @{ Path = $mfKeyPath; Name = "TamperProtection"; Value = 0 },
    @{ Path = $keyPath; Name = "ServiceStartStates"; Value = 1 }
)

foreach ($entry in $regEntries) {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Valor") -NoNewline
    Write-Host ("{0,-86} " -f "$($entry.Name) = $($entry.Value)") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan
    New-ItemProperty -Path $entry.Path -Name $entry.Name -PropertyType DWord -Value $entry.Value -Force | Out-Null
}

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Status") -NoNewline
Write-Host ("{0,-86} " -f "Windows Defender - Configurado com Sucesso") -NoNewline -ForegroundColor White
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
