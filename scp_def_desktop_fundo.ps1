param (
    [string]$wallpaper = "$PSScriptRoot\wallpaper\wallpaper_default.jpg"
)

# Função para definir o wallpaper
function Set-Wallpaper {
    param (
        [string]$path
    )
    
    # Certifique-se de que o caminho do arquivo existe
    if (-not (Test-Path $path)) {
        Write-Host "O caminho do wallpaper '$path' não existe." -ForegroundColor Red
        return
    }

    # Verificar se o tipo 'Wallpaper' já foi adicionado
    $typeExists = [AppDomain]::CurrentDomain.GetAssemblies() | ForEach-Object { $_.GetTypes() } | Where-Object { $_.Name -eq 'Wallpaper' }

    if (-not $typeExists) {
        # Código C# para definir o wallpaper
        $setwallpapersrc = @"
using System.Runtime.InteropServices;

public class Wallpaper
{
    public const int SPI_SETDESKWALLPAPER = 20;
    public const int SPIF_UPDATEINIFILE = 0x01;
    public const int SPIF_SENDCHANGE = 0x02;

    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    private static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);

    public static void SetWallpaper(string path)
    {
        SystemParametersInfo(SPI_SETDESKWALLPAPER, 0, path, SPIF_UPDATEINIFILE | SPIF_SENDCHANGE);
    }
}
"@

        # Adiciona o tipo
        Add-Type -TypeDefinition $setwallpapersrc
    }

    # Define o wallpaper
    [Wallpaper]::SetWallpaper($path)
}

# Função para alterar a cor de fundo
function Set-BackgroundColor {
    param (
        [string]$color
    )

    # Definir a cor de fundo no registro
    $key = 'HKCU:\Control Panel\Desktop\Colors'
    Set-ItemProperty -Path $key -Name 'Background' -Value $color

    # Forçar atualização das configurações
    & "$env:SystemRoot\System32\RUNDLL32.EXE" user32.dll,UpdatePerUserSystemParameters 1, True
}

# Padronizar o Desktop
Write-Host "╔" -NoNewline -ForegroundColor Cyan
Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
Write-Host "╗" -ForegroundColor Cyan  
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Operação") -NoNewline
Write-Host ("{0,-86} " -f "Padronizar Desktop") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Yellow
Write-Host ("{0,-30} : " -f " Copyright") -NoNewline
Write-Host ("{0,-86} " -f "2023 - Evandro Campanhã") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Yellow

$computerName = (Get-ComputerInfo).CsName
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Computador") -NoNewline
Write-Host ("{0,-86} " -f $computerName) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Script") -NoNewline
Write-Host ("{0,-86} " -f $MyInvocation.MyCommand.Path) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

Write-Host "╠" -NoNewline -ForegroundColor Cyan
Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
Write-Host "╣" -ForegroundColor Cyan

# Remover wallpaper atual
$key = 'HKCU:\Control Panel\Desktop'
Set-ItemProperty -Path $key -Name 'Wallpaper' -Value ''

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Wallpaper") -NoNewline
Write-Host ("{0,-86} " -f "Removido") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan

# Definir cor de fundo
$corFundo = '74 84 89'
Set-BackgroundColor $corFundo

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Cor de Fundo") -NoNewline
Write-Host ("{0,-86} " -f $corFundo) -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Novo Wallpaper") -NoNewline
Write-Host ("{0,-86} " -f $wallpaper) -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan

if (Test-Path $wallpaper) {
    $arquivo = (Get-Item $wallpaper).Name
    $caminhoDestino = "$env:windir\Web\Wallpaper\"
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Arquivo") -NoNewline
    Write-Host ("{0,-86} " -f "$caminhoDestino$($arquivo)") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan

    Copy-Item -Path $wallpaper -Destination $caminhoDestino -Force
    Set-Wallpaper "$caminhoDestino$($arquivo)"
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Wallpaper") -NoNewline
    Write-Host ("{0,-86} " -f "Arquivo não encontrado") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
}

# Final do Script
Write-Host "╠" -NoNewline -ForegroundColor Cyan
Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
Write-Host "╣" -ForegroundColor Cyan
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Processo") -NoNewline
Write-Host ("{0,-86} " -f "Finalizado") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan
Write-Host "╚" -NoNewline -ForegroundColor Cyan
Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
Write-Host "╝" -ForegroundColor Cyan