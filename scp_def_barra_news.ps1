#Script que remove a caixa de news
param (
    [string]$acao = "0" # "0" para desativar, "1" para ativar
)

# Cabecalho
#----------------------------------------------------------------------------------------------
# Obter o diretório do script atual
$scriptName = [System.IO.Path]::GetFileName($MyInvocation.MyCommand.Path)
$CurrentScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path

# Construir o caminho completo para o script 'scp_script_cabecalho.ps1'
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_script_cabecalho.ps1"

& $CabecalhoScriptPath -Script $scriptName -Titulo "Barra de News"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
if ($acao -eq "1") {
    # Ativar a barra de notícias
    $regValue = 1
    $status = "Ativar"
    $shellFeedsTaskbarViewMode = 1
    $enShellFeedsTaskbarViewMode = 0x3AF5A154 # Valor hexadecimal para EnShellFeedsTaskbarViewMode
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Opção") -NoNewline -ForegroundColor White
    Write-Host ("{0,-86} " -f $status) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
} elseif ($acao -eq "0") {
    # Desativar a barra de notícias
    $regValue = 0
    $status = "Desativar"
    $shellFeedsTaskbarViewMode = 0
    $enShellFeedsTaskbarViewMode = 0x4E7A5612 # Valor hexadecimal para EnShellFeedsTaskbarViewMode quando desativado
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Opção") -NoNewline -ForegroundColor White
    Write-Host ("{0,-86} " -f $status) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Erro") -NoNewline -ForegroundColor Red
    Write-Host ("{0,-86} " -f "Parâmetro inválido. Use '0' para desativar ou '1' para ativar.") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
    exit
}

# Defina os valores do Registro
$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds"

# Remover a chave de registro existente
if (Test-Path $regPath) {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Apagar") -NoNewline -ForegroundColor White
    Write-Host ("{0,-86} " -f $regPath) -NoNewline -ForegroundColor Cyan
    Write-Host "║" -ForegroundColor Cyan
    Remove-Item -Path $regPath -Recurse -Force
}

# Criar a chave de registro e definir os valores
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Criando Chave") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f $regPath) -NoNewline -ForegroundColor Cyan
Write-Host "║" -ForegroundColor Cyan
$null=New-Item -Path $regPath -Force | Out-Null

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Criando Valor") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "ShellFeedsTaskbarViewMode") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan
$null=New-ItemProperty -Path $regPath -Name "ShellFeedsTaskbarViewMode" -Value $shellFeedsTaskbarViewMode -PropertyType DWord -Force | Out-Null

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Criando Valor") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "DeviceTier") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan
$null=New-ItemProperty -Path $regPath -Name "DeviceTier" -Value 2 -PropertyType DWord -Force | Out-Null

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Criando Valor") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "DeviceSSD") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan
$null=New-ItemProperty -Path $regPath -Name "DeviceSSD" -Value 1 -PropertyType DWord -Force | Out-Null

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Criando Valor") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "DeviceMemory") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan
$null=New-ItemProperty -Path $regPath -Name "DeviceMemory" -Value 32 -PropertyType DWord -Force | Out-Null

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Criando Valor") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "DeviceProcessor") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan
$null=New-ItemProperty -Path $regPath -Name "DeviceProcessor" -Value 6 -PropertyType DWord -Force | Out-Null

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Criando Valor") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "EdgeHandoffOnboardingComplete") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan
$null=New-ItemProperty -Path $regPath -Name "EdgeHandoffOnboardingComplete" -Value 0 -PropertyType DWord -Force | Out-Null

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Criando Valor") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "osLocale") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan
$null=New-ItemProperty -Path $regPath -Name "osLocale" -Value "pt-BR" -PropertyType String -Force | Out-Null

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Criando Valor") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "IsAnaheimEdgeInstalled") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan
$null=New-ItemProperty -Path $regPath -Name "IsAnaheimEdgeInstalled" -Value 1 -PropertyType DWord -Force | Out-Null

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Criando Valor") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "IsFeedsAvailable") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan
$null=New-ItemProperty -Path $regPath -Name "IsFeedsAvailable" -Value 1 -PropertyType DWord -Force | Out-Null

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Criando Valor") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "IsEnterpriseDevice") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan
$null=New-ItemProperty -Path $regPath -Name "IsEnterpriseDevice" -Value 0 -PropertyType DWord -Force | Out-Null

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Criando Valor") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "HeadlinesOnboardingComplete") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan
$null=New-ItemProperty -Path $regPath -Name "HeadlinesOnboardingComplete" -Value 1 -PropertyType DWord -Force | Out-Null

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Criando Valor") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "EnShellFeedsTaskbarViewMode") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan
$null=New-ItemProperty -Path $regPath -Name "EnShellFeedsTaskbarViewMode" -Value $enShellFeedsTaskbarViewMode -PropertyType DWord -Force | Out-Null

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Criando Valor") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "UnpinReason") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan
$null=New-ItemProperty -Path $regPath -Name "UnpinReason" -Value 0 -PropertyType DWord -Force | Out-Null

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Criando Valor") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "UnpinTimestamp") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan
$null=New-ItemProperty -Path $regPath -Name "UnpinTimestamp" -Value (Get-Date).ToString("yyyy-MM-ddTHH-mm-ss") -PropertyType String -Force | Out-Null

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Criando Valor") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "ShellFeedsTaskbarPreviousViewMode") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan
$null=New-ItemProperty -Path $regPath -Name "ShellFeedsTaskbarPreviousViewMode" -Value 1 -PropertyType DWord -Force | Out-Null

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Criando Valor") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "IsLocationTurnedOn") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan
$null=New-ItemProperty -Path $regPath -Name "IsLocationTurnedOn" -Value 0 -PropertyType DWord -Force | Out-Null

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Criando Valor") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "IsEdgeUser") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan
$null=New-ItemProperty -Path $regPath -Name "IsEdgeUser" -Value 1 -PropertyType DWord -Force | Out-Null

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Criando Valor") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "ActiveMUID") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan
$null=New-ItemProperty -Path $regPath -Name "ActiveMUID" -Value "3F9B855219DA691707B6919718CE686F" -PropertyType String -Force | Out-Null

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Criando Valor") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "ActiveId") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan
$null=New-ItemProperty -Path $regPath -Name "ActiveId" -Value "0de1b966b88745cd" -PropertyType String -Force | Out-Null

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Criando Valor") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "ActiveAccountId") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan
$null=New-ItemProperty -Path $regPath -Name "ActiveAccountId" -Value "00060000813C9381" -PropertyType String -Force | Out-Null

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Criando Valor") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "ActiveAuthority") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan
$null=New-ItemProperty -Path $regPath -Name "ActiveAuthority" -Value "consumers" -PropertyType String -Force | Out-Null

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Criando Valor") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "ActiveProfileName") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan
$null=New-ItemProperty -Path $regPath -Name "ActiveProfileName" -Value "Pessoal" -PropertyType String -Force | Out-Null

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Criando Valor") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "ActiveProfileInError") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan
$null=New-ItemProperty -Path $regPath -Name "ActiveProfileInError" -Value 0 -PropertyType DWord -Force | Out-Null

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Criando Valor") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "ActiveProfileId") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan
$null=New-ItemProperty -Path $regPath -Name "ActiveProfileId" -Value "Default" -PropertyType String -Force | Out-Null
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