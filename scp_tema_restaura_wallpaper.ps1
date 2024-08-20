# Script para restaurar o wallpaper

# Cabecalho
#----------------------------------------------------------------------------------------------
# Obter o diretório do script atual
$scriptName = [System.IO.Path]::GetFileName($MyInvocation.MyCommand.Path)
$CurrentScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path

# Construir o caminho completo para o script 'scp_script_cabecalho.ps1'
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_script_cabecalho.ps1"

& $CabecalhoScriptPath -Script $scriptName -Titulo "Temas - Restaurar Wallpaper"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
$defaultWallpaperPath = "$env:SystemRoot\Web\Wallpaper\Windows\img0.jpg"

# Função para restaurar o papel de parede padrão
function Restore-Wallpaper {
    if (-not ([System.Management.Automation.PSTypeName]'Wallpaper').Type) {
        $null=Add-Type -TypeDefinition @"
        using System;
        using System.Runtime.InteropServices;
        public class Wallpaper {
            [DllImport("user32.dll", CharSet = CharSet.Auto)]
            public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
            public const int SPI_SETDESKWALLPAPER = 20;
            public const int SPIF_UPDATEINIFILE = 0x01;
            public const int SPIF_SENDCHANGE = 0x02;
            public static void SetWallpaper(string path) {
                SystemParametersInfo(SPI_SETDESKWALLPAPER, 0, path, SPIF_UPDATEINIFILE | SPIF_SENDCHANGE);
            }
        }
"@
    }

    [Wallpaper]::SetWallpaper($defaultWallpaperPath)
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Papel de Parede") -NoNewline
    Write-Host ("{0,-86} " -f $defaultWallpaperPath) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan

    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Status") -NoNewline
    Write-Host ("{0,-86} " -f "Restaurado para o padrão de instalação") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan
}
# Executando a função
Restore-Wallpaper
#----------------------------------------------------------------------------------------------

# Aplicando alterações
#----------------------------------------------------------------------------------------------
# Aplicar alterações
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