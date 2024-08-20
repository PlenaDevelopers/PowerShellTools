#Script que limpa as configurações do Google Chrome

# Verificar se o Google Chrome está instalado
$chromeInstalled = Test-Path "C:\Program Files\Google\Chrome\Application\chrome.exe"

if ($chromeInstalled) {

# Encerrar processos do Google Chrome
$null=Stop-Process -Name "chrome" -Force -ErrorAction SilentlyContinue

# Remover diretório de dados do Google Chrome (isso irá redefinir todas as configurações)
$chromeDataDir = [System.IO.Path]::Combine($env:LOCALAPPDATA, 'Google\Chrome\User Data')
$null=Remove-Item -Path $chromeDataDir -Recurse -Force -ErrorAction SilentlyContinue

} else {

}