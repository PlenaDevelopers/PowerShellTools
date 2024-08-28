<#
    Função: Restaurar personalizações do Windows
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
    analisar e gerar atualizações corretivas.

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
& $cabecalhoScriptPath -Script $scriptName -Titulo "Restaurar personalizações do Windows"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
# Restaurar o papel de parede padrão do Windows
function Restore-Wallpaper {
    $defaultWallpaper = Join-Path $env:SystemRoot "Web\Wallpaper\Windows\img0.jpg"
    
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Wallpaper") -NoNewline
    Write-Host ("{0,-86} " -f $defaultWallpaper) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan

    # Definir o papel de parede usando SystemParametersInfo
    $SPI_SETDESKWALLPAPER = 0x0014
    $UpdateIniFile = 0x01
    $SendWinIniChange = 0x02

    # Definir o papel de parede usando P/Invoke
    $null=Add-Type @"
        using System;
        using System.Runtime.InteropServices;
        public class WallpaperHelper {
            [DllImport("user32.dll", CharSet = CharSet.Auto)]
            public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
        }
"@

    # Chamar a função SystemParametersInfo para definir o wallpaper
   [void][WallpaperHelper]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $defaultWallpaper, $UpdateIniFile -bor $SendWinIniChange)
}

# Reverter para o tema padrão do Windows
function Restore-Theme {
    $defaultThemePath = Join-Path $env:SystemRoot "Resources\Themes\aero.theme"
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Tema") -NoNewline
    Write-Host ("{0,-86} " -f $defaultThemePath) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan

    $chave="HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes"
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Chave") -NoNewline
    Write-Host ("{0,-86} " -f $chave) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan

    $valor="CurrentTheme"
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Alterar valor") -NoNewline
    Write-Host ("{0,-86} " -f $valor) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
    $null=Set-ItemProperty -Path $chave -Name $valor -Value $defaultThemePath -Force

    # Atualizar as configurações de usuário
    RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters
}

# Reverter cores de destaque para o padrão
function Restore-Colors {
    $chave="HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Chave") -NoNewline
    Write-Host ("{0,-86} " -f $chave) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
    $valor="ColorPrevalence"
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Alterar valor") -NoNewline
    Write-Host ("{0,-86} " -f $valor) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
    $null=Set-ItemProperty -Path $chave -Name $valor -Value 0

    $chave="HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Chave") -NoNewline
    Write-Host ("{0,-86} " -f $chave) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
    $valor="AppsUseLightTheme"
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Alterar valor") -NoNewline
    Write-Host ("{0,-86} " -f $valor) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
    $null=Set-ItemProperty -Path $chave -Name $valor -Value 1

    $chave="HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Chave") -NoNewline
    Write-Host ("{0,-86} " -f $chave) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
    $valor="SystemUsesLightTheme"
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Alterar valor") -NoNewline
    Write-Host ("{0,-86} " -f $valor) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
    $null=Set-ItemProperty -Path $chave -Name $valor -Value 1

    $chave="HKCU:\Software\Microsoft\Windows\DWM"
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Chave") -NoNewline
    Write-Host ("{0,-86} " -f $chave) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
    $valor="AccentColor"
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Alterar valor") -NoNewline
    Write-Host ("{0,-86} " -f $valor) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
    $null=Set-ItemProperty -Path $chave -Name $valor -Value 0xFF000000

    # Atualizar as configurações de usuário
    RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters
}

# Restaurar fonte padrão do sistema
function Restore-Font {
    $chave="HKCU:\Control Panel\Desktop"
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Chave") -NoNewline
    Write-Host ("{0,-86} " -f $chave) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan

    $valor="FontSmoothing"
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Remover") -NoNewline
    Write-Host ("{0,-86} " -f $valor) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
    $null=Remove-ItemProperty -Path $chave -Name $valor -ErrorAction SilentlyContinue

    $valor="FontSmoothingType"
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Remover") -NoNewline
    Write-Host ("{0,-86} " -f $valor) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
    $null=Remove-ItemProperty -Path $chave -Name $valor -ErrorAction SilentlyContinue

    $valor="FontSmoothingGamma"
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Remover") -NoNewline
    Write-Host ("{0,-86} " -f $valor) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
    $null=Remove-ItemProperty -Path $chave -Name $valor -ErrorAction SilentlyContinue

    $valor="FontSmoothingOrientation"
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Remover") -NoNewline
    Write-Host ("{0,-86} " -f $valor) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
    $null=Remove-ItemProperty -Path $chave -Name $valor -ErrorAction SilentlyContinue

    # Atualizar as configurações de usuário
    RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters
}

# Execução das funções
Restore-Wallpaper
Restore-Theme
Restore-Colors
Restore-Font
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