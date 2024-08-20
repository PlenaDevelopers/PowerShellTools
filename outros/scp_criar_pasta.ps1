#Script para criar uma pasta 
param (
    [string]$caminhoPasta
)

# Verifica se o caminho da pasta existe
if (-not (Test-Path -Path $caminhoPasta -PathType Container)) {
    # Cria a pasta se não existir
    New-Item -Path $caminhoPasta -ItemType Directory -Force
    Write-Host "A pasta foi criada em: $caminhoPasta"
} else {
    Write-Host "A pasta já existe em: $caminhoPasta"
}