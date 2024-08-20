#Script que limpa as configurações do Microsoft Edge

# Verificar se o Microsoft Edge está instalado
$edgeInstalled = Test-Path "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"

if ($edgeInstalled) {
    # Encerrar processos do Microsoft Edge
    $null=Stop-Process -Name "msedge" -Force -ErrorAction SilentlyContinue
    
    # Remover diretório de dados do Microsoft Edge (isso irá redefinir todas as configurações)
    $edgeDataDir = [System.IO.Path]::Combine($env:LOCALAPPDATA, 'Microsoft\Edge\User Data')
    $null=Remove-Item -Path $edgeDataDir -Recurse -Force -ErrorAction SilentlyContinue
}
else {
    Write-Host "Microsoft Edge não está instalado."
}
