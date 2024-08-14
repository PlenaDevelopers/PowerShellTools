# Script para limpar os "Blocos Dinâmicos" do "Menu Iniciar"
# Cabeçalho
#----------------------------------------------------------------------------------------------
Write-Host "╔" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
write-host "╗" -ForegroundColor Cyan  

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Menu Iniciar") -NoNewline
Write-Host ("{0,-86} " -f "Remover blocos dinâmicos") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Yellow
Write-Host ("{0,-30} : " -f " Copyright") -NoNewline
Write-Host ("{0,-86} " -f "2023 - Evandro Campanhã") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Yellow

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Script") -NoNewline
Write-Host ("{0,-86} " -f $MyInvocation.MyCommand.Path) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

Write-Host "╠" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
write-host "╣" -ForegroundColor Cyan
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
    Write-Host ("{0,-30} : " -f " Remover Arquivo") -NoNewline
    Write-Host ("{0,-86} " -f $layoutFile) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
    Remove-Item $layoutFile
}

# Criar o arquivo de layout em branco
$START_MENU_LAYOUT | Out-File $layoutFile -Encoding ASCII

$regAliases = @("HKLM", "HKCU")

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Usando a Chave") -NoNewline
Write-Host ("{0,-86} " -f $keyPath) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

# Atribuir o layout do menu Iniciar e forçar a aplicação com "LockedStartLayout" em ambos os níveis, máquina e usuário
foreach ($regAlias in $regAliases){
    $basePath = $regAlias + ":\SOFTWARE\Policies\Microsoft\Windows"
    $keyPath = $basePath + "\Explorer" 
    IF(!(Test-Path -Path $keyPath)) { 
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f " Criar Chave") -NoNewline
        Write-Host ("{0,-86} " -f $basePath) -NoNewline -ForegroundColor White
        Write-Host "║" -ForegroundColor Cyan
        New-Item -Path $basePath -Name "Explorer"
    }
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f " Criar Valor") -NoNewline
        Write-Host ("{0,-86} " -f "LockedStartLayout = 1") -NoNewline -ForegroundColor White
        Write-Host "║" -ForegroundColor Cyan
        Set-ItemProperty -Path $keyPath -Name "LockedStartLayout" -Value 1
    
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f " Criar Valor") -NoNewline
        Write-Host ("{0,-86} " -f $layoutFile) -NoNewline -ForegroundColor White
        Write-Host "║" -ForegroundColor Cyan
        Set-ItemProperty -Path $keyPath -Name "StartLayoutFile" -Value $layoutFile
}

# Reiniciar o Explorer, abrir o menu iniciar (necessário para carregar o novo layout) e aguardar alguns segundos para processar
Stop-Process -name explorer
Start-Sleep -s 5
$wshell = New-Object -ComObject wscript.shell; $wshell.SendKeys('^{ESCAPE}')

# Habilitar a capacidade de fixar itens novamente desativando "LockedStartLayout"
foreach ($regAlias in $regAliases){
    $basePath = $regAlias + ":\SOFTWARE\Policies\Microsoft\Windows"
    $keyPath = $basePath + "\Explorer" 
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Criar Valor") -NoNewline
    Write-Host ("{0,-86} " -f "LockedStartLayout = 0") -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
    Set-ItemProperty -Path $keyPath -Name "LockedStartLayout" -Value 0
}

# Reiniciar o Explorer e remover o arquivo de layout
Stop-Process -name explorer
#----------------------------------------------------------------------------------------------

# Rodapé
#----------------------------------------------------------------------------------------------
Write-Host "╠" -NoNewline -ForegroundColor Cyan
Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
Write-Host "╣" -ForegroundColor Cyan  

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Processo") -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-86} " -f "Finalizado") -NoNewline -ForegroundColor Cyan
Write-Host "║" -ForegroundColor Cyan

Write-Host "╚" -NoNewline -ForegroundColor Cyan
Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
Write-Host "╝" -ForegroundColor Cyan
