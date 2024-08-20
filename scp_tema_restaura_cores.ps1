# Script para restaurar cores do tema

# Cabecalho
#----------------------------------------------------------------------------------------------
# Obter o diretório do script atual
$scriptName = [System.IO.Path]::GetFileName($MyInvocation.MyCommand.Path)
$CurrentScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path

# Construir o caminho completo para o script 'scp_script_cabecalho.ps1'
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_script_cabecalho.ps1"

& $CabecalhoScriptPath -Script $scriptName -Titulo "Temas - Restaurar cores"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
$RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent"
$AccentColor = '0xFF0078D7'  # Cor #0078D7 em formato ARGB

# Definir cor #0078D7
$AccentColorMenuKey = @{
    Key   = 'AccentColorMenu';
    Type  = "DWORD";
    Value = $AccentColor
}

If ($Null -eq (Get-ItemProperty -Path $RegPath -Name $AccentColorMenuKey.Key -ErrorAction SilentlyContinue)) {
    $null=New-ItemProperty -Path $RegPath -Name $AccentColorMenuKey.Key -Value $AccentColorMenuKey.Value -PropertyType $AccentColorMenuKey.Type -Force
} Else {
    $null=Set-ItemProperty -Path $RegPath -Name $AccentColorMenuKey.Key -Value $AccentColorMenuKey.Value -Force
}

# Accent Palette Key
$AccentPaletteKey = @{
    Key   = 'AccentPalette';
    Type  = "BINARY";
    Value = 'D7,78,00,FF,6B,BE,00,FF,5E,A5,00,FF,44,93,00,FF,37,82,00,FF,2A,71,00,FF,1D,60,00'
}
$hexified = $AccentPaletteKey.Value.Split(',') | ForEach-Object { "0x$_" }

If ($Null -eq (Get-ItemProperty -Path $RegPath -Name $AccentPaletteKey.Key -ErrorAction SilentlyContinue)) {
    $null=New-ItemProperty -Path $RegPath -Name $AccentPaletteKey.Key -PropertyType Binary -Value ([byte[]]$hexified) -Force
} Else {
    $null=Set-ItemProperty -Path $RegPath -Name $AccentPaletteKey.Key -Value ([byte[]]$hexified) -Force
}

# MotionAccentId_v1.00 Key
$MotionAccentIdKey = @{
    Key   = 'MotionAccentId_v1.00';
    Type  = "DWORD";
    Value = '0x000000db'
}

If ($Null -eq (Get-ItemProperty -Path $RegPath -Name $MotionAccentIdKey.Key -ErrorAction SilentlyContinue)) {
    $null=New-ItemProperty -Path $RegPath -Name $MotionAccentIdKey.Key -Value $MotionAccentIdKey.Value -PropertyType $MotionAccentIdKey.Type -Force
} Else {
    $null=Set-ItemProperty -Path $RegPath -Name $MotionAccentIdKey.Key -Value $MotionAccentIdKey.Value -Force
}

# Start Color Menu Key
$StartMenuKey = @{
    Key   = 'StartColorMenu';
    Type  = "DWORD";
    Value = $AccentColor  # Usando a mesma cor para o menu Iniciar
}

If ($Null -eq (Get-ItemProperty -Path $RegPath -Name $StartMenuKey.Key -ErrorAction SilentlyContinue)) {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Criando") -NoNewline -ForegroundColor White
    Write-Host ("{0,-86} " -f $RegPath) -NoNewline -ForegroundColor Cyan
    Write-Host "║" -ForegroundColor Cyan
    $null=New-ItemProperty -Path $RegPath -Name $StartMenuKey.Key -Value $StartMenuKey.Value -PropertyType $StartMenuKey.Type -Force
} Else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Alterando") -NoNewline -ForegroundColor White
    Write-Host ("{0,-86} " -f $RegPath) -NoNewline -ForegroundColor Cyan
    Write-Host "║" -ForegroundColor Cyan
    $null=Set-ItemProperty -Path $RegPath -Name $StartMenuKey.Key -Value $StartMenuKey.Value -Force
}
#----------------------------------------------------------------------------------------------

# Aplicando alterações
#----------------------------------------------------------------------------------------------
# Aplicar alterações
rundll32.exe user32.dll, UpdatePerUserSystemParameters
#----------------------------------------------------------------------------------------------

# Rodape
#----------------------------------------------------------------------------------------------
# Obter o diretório do script atual
$CurrentScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path

# Construir o caminho completo para o script 'scp_script_rodape.ps1'
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_script_rodape.ps1"

& $CabecalhoScriptPath
#----------------------------------------------------------------------------------------------