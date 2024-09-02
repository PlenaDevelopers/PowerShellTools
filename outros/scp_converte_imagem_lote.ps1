<#
    Função: Converter imagens em uma pasta
    Copyright: © Plena Soluções - 2024
    Date: Setembro/2024

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

param(
    [string]$pasta = "C:\Temp\JPG",
    [string]$formatoEntrada = "jpg",
    [string]$formatoSaida = "bmp"
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
& $cabecalhoScriptPath -Script $scriptName -Titulo "Converter imagens em uma pasta"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
function Convert-ImageFormat {
    param(
        [string]$filePath,
        [string]$targetFormat
    )

    Add-Type -AssemblyName System.Drawing

    $supportedFormats = @("bmp", "gif", "jpg", "jpeg", "png", "tiff", "ico")
    $fileExtension = [System.IO.Path]::GetExtension($filePath).TrimStart('.').ToLower()

    if (-not $supportedFormats.Contains($fileExtension)) {
        throw "Formato de arquivo '$fileExtension' não suportado."
    }

    if (-not $supportedFormats.Contains($targetFormat.ToLower())) {
        throw "Formato de destino '$targetFormat' não suportado."
    }

    if (-not (Test-Path $filePath)) {
        throw [System.IO.FileNotFoundException] "O arquivo fornecido não foi encontrado em '$filePath'."
    }

    try {
        $image = [System.Drawing.Image]::FromFile($filePath)
        $targetPath = [System.IO.Path]::ChangeExtension($filePath, $targetFormat)

        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Convertendo") -NoNewline
        Write-Host ("{0,-86} " -f $targetPath) -NoNewline -ForegroundColor Green
        Write-Host "║" -ForegroundColor Cyan

        switch ($targetFormat.ToLower()) {
            "bmp"   { $image.Save($targetPath, [System.Drawing.Imaging.ImageFormat]::Bmp) }
            "gif"   { $image.Save($targetPath, [System.Drawing.Imaging.ImageFormat]::Gif) }
            "jpg"   { $image.Save($targetPath, [System.Drawing.Imaging.ImageFormat]::Jpeg) }
            "jpeg"  { $image.Save($targetPath, [System.Drawing.Imaging.ImageFormat]::Jpeg) }
            "png"   { $image.Save($targetPath, [System.Drawing.Imaging.ImageFormat]::Png) }
            "tiff"  { $image.Save($targetPath, [System.Drawing.Imaging.ImageFormat]::Tiff) }
            "ico"   {
                $icon = [System.Drawing.Icon]::FromHandle($image.GetHicon())
                $file = New-Object System.IO.FileStream($targetPath, 'OpenOrCreate')
                $icon.Save($file)
                $file.Close()
                $icon.Dispose()
            }
        }

        $image.Dispose()
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Arquivo Convertido") -NoNewline
        Write-Host ("{0,-86} " -f $targetPath) -NoNewline -ForegroundColor Green
        Write-Host "║" -ForegroundColor Cyan
    } catch {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Erro") -NoNewline
        Write-Host ("{0,-86} " -f $_) -NoNewline -ForegroundColor Green
        Write-Host "║" -ForegroundColor Cyan
    }
}

#----------------------------------------------------------------------------------------------

# Percorrer todos os arquivos na pasta
$files = Get-ChildItem -Path $pasta -Recurse -Filter "*.$formatoEntrada"

foreach ($file in $files) {
    Convert-ImageFormat -filePath $file.FullName -targetFormat $formatoSaida
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
