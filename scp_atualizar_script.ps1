Clear
# Cabeçalho
#----------------------------------------------------------------------------------------------
Write-Host "╔" -NoNewline -ForegroundColor Yellow
write-host ("═" * 120) -NoNewline -ForegroundColor Yellow
write-host "╗" -ForegroundColor Yellow  

Write-Host "║" -NoNewline -ForegroundColor Yellow
Write-Host ("{0,-30} : " -f " Iniciar") -NoNewline
Write-Host ("{0,-86} " -f "Script de Download") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Yellow

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Copyright") -NoNewline
Write-Host ("{0,-86} " -f "2023 - Evandro Campanhã") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Script") -NoNewline
Write-Host ("{0,-86} " -f $MyInvocation.MyCommand.Path) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

Write-Host "╠" -NoNewline -ForegroundColor Cyan
Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
Write-Host "╣" -ForegroundColor Cyan
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
# Define o repositório e a branch
$owner = "Underrun2016"
$repo = "PowerShellTools"
$branch = "main"

# Define o URL base do repositório e o diretório local para salvar os arquivos
$baseUrl = "https://raw.githubusercontent.com/$owner/$repo/$branch/"

# Obtém o diretório atual do script e define o diretório de destino
$currentScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
$localPath = $currentScriptDirectory

# Cria o diretório se não existir
if (-not (Test-Path $localPath)) {
    New-Item -ItemType Directory -Path $localPath -Force
}

# Função para baixar arquivos recursivamente
function Download-Files {
    param (
        [string]$url,
        [string]$localDir
    )

    # Obtém a lista de arquivos e pastas no repositório
    $items = Invoke-RestMethod -Uri $url -Headers @{ "User-Agent" = "PowerShell" }

    foreach ($item in $items) {
        if ($item.type -eq "dir") {
            # Se for uma pasta, cria a pasta local e chama a função recursivamente
            $newLocalDir = Join-Path $localDir $item.name
            if (-not (Test-Path $newLocalDir)) {
                New-Item -ItemType Directory -Path $newLocalDir -Force
            }
            Download-Files -url $item._links.self -localDir $newLocalDir
        } elseif ($item.type -eq "file") {
            # Se for um arquivo, baixa o arquivo
            $fileUrl = $item.download_url
            $localFilePath = Join-Path $localDir $item.name

            try {
                Invoke-WebRequest -Uri $fileUrl -OutFile $localFilePath
                $fileName = Split-Path -Path $localFilePath -Leaf
                Write-Host "║" -NoNewline -ForegroundColor Cyan
                Write-Host ("{0,-30} : " -f " Arquivo Baixado") -NoNewline -ForegroundColor Cyan
                Write-Host ("{0,-86} " -f $fileName) -NoNewline -ForegroundColor Green
                Write-Host "║" -ForegroundColor Cyan
            } catch {
                Write-Host "║" -NoNewline -ForegroundColor Cyan
                Write-Host ("{0,-30} : " -f " Arquivo com Erro") -NoNewline -ForegroundColor Cyan
                Write-Host ("{0,-86} " -f $item.name) -NoNewline -ForegroundColor Red
                Write-Host "║" -ForegroundColor Cyan
            }
        }
    }
}

# Inicia o download recursivo
Download-Files -url "https://api.github.com/repos/$owner/$repo/contents?ref=$branch" -localDir $localPath
#----------------------------------------------------------------------------------------------

# Rodape
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