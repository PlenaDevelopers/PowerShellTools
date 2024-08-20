#Script que limpa as configurações do Internet Explorer

# Verificar se o Internet Explorer está instalado
$ieInstalled = Test-Path "C:\Program Files\Internet Explorer\iexplore.exe"

if ($ieInstalled) {
    # Encerrar processos do Internet Explorer
    $null=Stop-Process -Name "iexplore" -Force -ErrorAction SilentlyContinue

    # Remover diretório de dados do Internet Explorer (isso irá redefinir todas as configurações)
    $ieDataDir = [System.IO.Path]::Combine($env:LOCALAPPDATA, 'Microsoft\Internet Explorer')
    $null=Remove-Item -Path $ieDataDir -Recurse -Force -ErrorAction SilentlyContinue
} else {
    Write-Host "O Internet Explorer não está instalado."
}