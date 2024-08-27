<#
    Função: Remover os Blocos Dinâmicos do Menu Iniciar
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
& $cabecalhoScriptPath -Script $scriptName -Titulo "Remover os Blocos Dinâmicos"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
$START_MENU_LAYOUT = @"
<LayoutModificationTemplate xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout" xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout" Version="1" xmlns:taskbar="http://schemas.microsoft.com/Start/2014/TaskbarLayout" xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification">
    <LayoutOptions StartTileGroupCellWidth="6" />
    <DefaultLayoutOverride>
        <StartLayoutCollection>
            <defaultlayout:StartLayout GroupCellWidth="6" />
        </StartLayoutCollection>
    </DefaultLayoutOverride>
</LayoutModificationTemplate>
"@

$layoutFile="C:\Windows\StartMenuLayout.xml"

# Remover arquivo de layout se já existir
If(Test-Path $layoutFile)
{
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Remover Arquivo") -NoNewline
    Write-Host ("{0,-86} " -f $layoutFile) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
    $null=Remove-Item $layoutFile
}

# Criar o arquivo de layout em branco
$START_MENU_LAYOUT | Out-File $layoutFile -Encoding ASCII

$regAliases = @("HKLM", "HKCU")

# Atribuir o layout do menu Iniciar e forçar a aplicação com "LockedStartLayout" em ambos os níveis, máquina e usuário
foreach ($regAlias in $regAliases){
    $basePath = $regAlias + ":\SOFTWARE\Policies\Microsoft\Windows"
    $keyPath = $basePath + "\Explorer" 
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Usando a Chave") -NoNewline
    Write-Host ("{0,-86} " -f $keyPath) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan

    IF(!(Test-Path -Path $keyPath)) { 
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Criar Chave") -NoNewline
        Write-Host ("{0,-86} " -f $basePath) -NoNewline -ForegroundColor White
        Write-Host "║" -ForegroundColor Cyan
        $null=New-Item -Path $basePath -Name "Explorer"
    }
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Criar Valor") -NoNewline
        Write-Host ("{0,-86} " -f "LockedStartLayout = 1") -NoNewline -ForegroundColor White
        Write-Host "║" -ForegroundColor Cyan
        $null=Set-ItemProperty -Path $keyPath -Name "LockedStartLayout" -Value 1
    
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Criar Valor") -NoNewline
        Write-Host ("{0,-86} " -f $layoutFile) -NoNewline -ForegroundColor White
        Write-Host "║" -ForegroundColor Cyan
        $null=Set-ItemProperty -Path $keyPath -Name "StartLayoutFile" -Value $layoutFile
}

# Reiniciar o Explorer, abrir o menu iniciar (necessário para carregar o novo layout) e aguardar alguns segundos para processar
Stop-Process -name explorer
Start-Sleep -s 5
#$wshell = New-Object -ComObject wscript.shell; $wshell.SendKeys('^{ESCAPE}')

# Habilitar a capacidade de fixar itens novamente desativando "LockedStartLayout"
foreach ($regAlias in $regAliases){
    $basePath = $regAlias + ":\SOFTWARE\Policies\Microsoft\Windows"
    $keyPath = $basePath + "\Explorer" 
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Criar Valor") -NoNewline
    Write-Host ("{0,-86} " -f "LockedStartLayout = 0") -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
    $null=Set-ItemProperty -Path $keyPath -Name "LockedStartLayout" -Value 0
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