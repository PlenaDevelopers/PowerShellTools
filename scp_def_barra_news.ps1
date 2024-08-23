<#
    Função: Habilita/Desabilita a barra de novidades do menu iniciar
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

# Defina o caminho da chave de registro
$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds"

# Verifique se a chave de registro existe
if (Test-Path $regPath) {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Apagar valores") -NoNewline -ForegroundColor White
    Write-Host ("{0,-86} " -f $regPath) -NoNewline -ForegroundColor Cyan
    Write-Host "║" -ForegroundColor Cyan

    # Obtenha todos os valores dentro da chave de registro
    $values = Get-ItemProperty -Path $regPath | Select-Object -Property * -ExcludeProperty PSPath, PSParentPath, PSChildName, PSDrive, PSProvider

    # Remova cada valor individualmente
    foreach ($value in $values.PSObject.Properties.Name) {
        Remove-ItemProperty -Path $regPath -Name $value -Force
    }
    
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Valores apagados") -NoNewline -ForegroundColor White
    Write-Host ("{0,-86} " -f $regPath) -NoNewline -ForegroundColor Cyan
    Write-Host "║" -ForegroundColor Cyan
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Chave não encontrada") -NoNewline -ForegroundColor Yellow
    Write-Host ("{0,-86} " -f $regPath) -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
}

# Defina o caminho da chave de registro
$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds"

$properties = @(
    @{Name="ShellFeedsTaskbarViewMode"; Value=$shellFeedsTaskbarViewMode; Type="DWord"}
    @{Name="DeviceTier"; Value=2; Type="DWord"}
    @{Name="DeviceSSD"; Value=1; Type="DWord"}
    @{Name="DeviceMemory"; Value=32; Type="DWord"}
    @{Name="DeviceProcessor"; Value=6; Type="DWord"}
    @{Name="EdgeHandoffOnboardingComplete"; Value=0; Type="DWord"}
    @{Name="osLocale"; Value="pt-BR"; Type="String"}
    @{Name="IsAnaheimEdgeInstalled"; Value=1; Type="DWord"}
    @{Name="IsFeedsAvailable"; Value=1; Type="DWord"}
    @{Name="IsEnterpriseDevice"; Value=0; Type="DWord"}
    @{Name="HeadlinesOnboardingComplete"; Value=1; Type="DWord"}
    @{Name="EnShellFeedsTaskbarViewMode"; Value=$enShellFeedsTaskbarViewMode; Type="DWord"}
    @{Name="UnpinReason"; Value=0; Type="DWord"}
    @{Name="UnpinTimestamp"; Value=(Get-Date).ToString("yyyy-MM-ddTHH-mm-ss"); Type="String"}
    @{Name="ShellFeedsTaskbarPreviousViewMode"; Value=1; Type="DWord"}
    @{Name="IsLocationTurnedOn"; Value=0; Type="DWord"}
    @{Name="IsEdgeUser"; Value=1; Type="DWord"}
    @{Name="ActiveMUID"; Value="3F9B855219DA691707B6919718CE686F"; Type="String"}
    @{Name="ActiveId"; Value="0de1b966b88745cd"; Type="String"}
    @{Name="ActiveAccountId"; Value="00060000813C9381"; Type="String"}
    @{Name="ActiveAuthority"; Value="consumers"; Type="String"}
    @{Name="ActiveProfileName"; Value="Pessoal"; Type="String"}
    @{Name="ActiveProfileInError"; Value=0; Type="DWord"}
    @{Name="ActiveProfileId"; Value="A1B2C3D4"; Type="String"}
)

foreach ($prop in $properties) {
    try {
                Write-Host "║" -NoNewline -ForegroundColor Cyan
                Write-Host ("{0,-30} : " -f "Verificando Valor") -NoNewline -ForegroundColor White
                Write-Host ("{0,-86} " -f $prop.Name) -NoNewline -ForegroundColor White
                Write-Host "║" -ForegroundColor Cyan
       
        # Verificar se a chave de registro existe
        if (Test-Path $regPath) {
            # Verificar se o valor existe
            if (Get-ItemProperty -Path $regPath -Name $prop.Name -ErrorAction SilentlyContinue) {
                Write-Host "║" -NoNewline -ForegroundColor Cyan
                Write-Host ("{0,-30} : " -f "Alterando Valor") -NoNewline -ForegroundColor Yellow
                Write-Host ("{0,-86} " -f $prop.Name) -NoNewline -ForegroundColor Red
                Write-Host "║" -ForegroundColor Cyan
                
                if ($prop.Type -eq "DWord") {
                    $null=Set-ItemProperty -Path $regPath -Name $prop.Name -Value [UInt32]$prop.Value -Type DWord -Force
                } elseif ($prop.Type -eq "String") {
                    $null=Set-ItemProperty -Path $regPath -Name $prop.Name -Value $prop.Value -Type String -Force
                }
            } else {
                Write-Host "║" -NoNewline -ForegroundColor Cyan
                Write-Host ("{0,-30} : " -f "Status") -NoNewline -ForegroundColor Yellow
                Write-Host ("{0,-86} " -f "Valor não encontrado para alteração") -NoNewline -ForegroundColor Red
                Write-Host "║" -ForegroundColor Cyan
            }
        } else {
                Write-Host "║" -NoNewline -ForegroundColor Cyan
                Write-Host ("{0,-30} : " -f "Status") -NoNewline -ForegroundColor Yellow
                Write-Host ("{0,-86} " -f "Chave de registro não encontrada") -NoNewline -ForegroundColor Red
                Write-Host "║" -ForegroundColor Cyan
        }
    } catch {
                Write-Host "║" -NoNewline -ForegroundColor Cyan
                Write-Host ("{0,-30} : " -f "Status") -NoNewline -ForegroundColor Yellow
                Write-Host ("{0,-86} " -f "Falha ao alterar valor") -NoNewline -ForegroundColor Red
                Write-Host "║" -ForegroundColor Cyan
    }
}
#----------------------------------------------------------------------------------------------


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