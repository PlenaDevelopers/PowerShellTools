# Caminho para o arquivo de favoritos do Chrome
$bookmarksPath = "C:\users\$env:userprofile\appdata\local\google\chrome\default\bookmarks"

# Caminho para o arquivo CSV contendo os novos favoritos
$csvPath = "\\server\share\repository\chromebookmarks.csv"

# Verifica se o arquivo de favoritos do Chrome existe
if (-not (Test-Path $bookmarksPath)) {
    Write-Host "Arquivo de favoritos do Chrome não encontrado." -ForegroundColor Red
    exit
}

# Faz o backup do arquivo de favoritos existente
Copy-Item -Path $bookmarksPath -Destination "$bookmarksPath.bak" -Force

# Lê o arquivo de favoritos e o arquivo CSV
$bookmarks = Get-Content $bookmarksPath | ConvertFrom-Json
$data = Import-Csv $csvPath

# Adiciona os novos favoritos à barra de favoritos
$bookmarks.roots.bookmark_bar.children += $data

# Salva o arquivo JSON atualizado de volta
$bookmarks | ConvertTo-Json -Depth 10 | Set-Content -Path $bookmarksPath -Encoding UTF8 -Force

Write-Host "Favoritos adicionados com sucesso." -ForegroundColor Green
