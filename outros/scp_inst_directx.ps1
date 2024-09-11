# Defina o caminho correto do instalador DirectX
$directxUrl = "https://download.microsoft.com/download/1/7/1/1718CCC4-6315-4D8E-9543-8E28A4E18C4C/dxwebsetup.exe"
$downloadPath = "$env:TEMP\dxwebsetup.exe"

# Baixa o instalador DirectX
Write-Host "Baixando o instalador do DirectX..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $directxUrl -OutFile $downloadPath

# Verifica se o arquivo foi baixado com sucesso
if (Test-Path $downloadPath) {
    Write-Host "Download concluído com sucesso." -ForegroundColor Green

    # Executa o instalador em modo silencioso
    Write-Host "Instalando o DirectX em modo silencioso..." -ForegroundColor Cyan
    Start-Process -FilePath $downloadPath -ArgumentList "/q" -Wait

    # Verifica o status da instalação
    if ($LASTEXITCODE -eq 0) {
        Write-Host "DirectX instalado com sucesso." -ForegroundColor Green
    } else {
        Write-Host "Ocorreu um erro durante a instalação do DirectX." -ForegroundColor Red
    }

    # Remove o instalador após a instalação
    Remove-Item $downloadPath -Force
} else {
    Write-Host "Falha ao baixar o instalador do DirectX." -ForegroundColor Red
}
