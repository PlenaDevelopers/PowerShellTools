<#
    Função: Altera o wallpaper de fundo do Desktop
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
    [string]$imagem = "$PSScriptRoot\wallpaper\wallpaper_default.jpg"
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
& $cabecalhoScriptPath -Script $scriptName -Titulo "Defnir a imagem de fundo do desktop"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------

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

# Remover wallpaper atual
$key = 'HKCU:\Control Panel\Desktop'
Set-ItemProperty -Path $key -Name 'Wallpaper' -Value ''

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Wallpaper") -NoNewline
Write-Host ("{0,-86} " -f "Removido") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan

if (Test-Path $imagem) {
    $arquivo = (Get-Item $imagem).Name
    $caminhoDestino = "$env:windir\Web\Wallpaper\"

    # Copia a imagem para o diretório
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Copiando Imagem (Origem)") -NoNewline
    Write-Host ("{0,-86} " -f $imagem) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
    
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Copiando Imagem (Destino)") -NoNewline
    Write-Host ("{0,-86} " -f $caminhoDestino) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan

    $null=Copy-Item -Path $imagem -Destination $caminhoDestino -Force
    $null=Set-Wallpaper "$caminhoDestino$($arquivo)"

    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Novo Wallpaper") -NoNewline
    Write-Host ("{0,-86} " -f $arquivo) -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Wallpaper") -NoNewline
    Write-Host ("{0,-86} " -f "Arquivo não encontrado") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
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