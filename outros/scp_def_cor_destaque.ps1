param (
    [string]$HexColor = "#BAD357" # Cor padrão caso nenhum parâmetro seja fornecido
)

function Convert-HexToARGB {
    param (
        [string]$HexColor
    )
    # Remover o "#" se estiver presente
    $HexColor = $HexColor.TrimStart('#')

    # Converter para ARGB
    $a = 'FF' # Define Alpha como FF para cores opacas
    $r = $HexColor.Substring(0, 2)
    $g = $HexColor.Substring(2, 2)
    $b = $HexColor.Substring(4, 2)

    return "$a$r$g$b"
}

function Generate-AccentPalette {
    param (
        [string]$HexColor
    )

    # Converte a cor hexadecimal para ARGB
    $ArgbColor = Convert-HexToARGB -HexColor $HexColor

    # Converte ARGB para bytes
    $a = [byte]([convert]::ToInt32($ArgbColor.Substring(0, 2), 16))
    $r = [byte]([convert]::ToInt32($ArgbColor.Substring(2, 2), 16))
    $g = [byte]([convert]::ToInt32($ArgbColor.Substring(4, 2), 16))
    $b = [byte]([convert]::ToInt32($ArgbColor.Substring(6, 2), 16))

    # Gera a paleta binária com o valor ARGB repetido para garantir a correspondência
    $palette = @(
        $r, $g, $b, $a,  # Cor principal
        $r, $g, $b, $a,
        $r, $g, $b, $a,
        $r, $g, $b, $a,
        $r, $g, $b, $a,
        $r, $g, $b, $a,
        $r, $g, $b, $a,
        $r, $g, $b, $a
    )

    return $palette
}

# Converter a cor hexadecimal para ARGB
$ArgbColor = Convert-HexToARGB -HexColor $HexColor
$Palette = Generate-AccentPalette -HexColor $HexColor

$RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent"

# Accent Color Menu Key
$AccentColorMenuKey = @{
    Key   = 'AccentColorMenu';
    Type  = "DWORD";
    Value = [convert]::ToInt32($ArgbColor, 16)
}

if ($Null -eq (Get-ItemProperty -Path $RegPath -Name $AccentColorMenuKey.Key -ErrorAction SilentlyContinue)) {
    New-ItemProperty -Path $RegPath -Name $AccentColorMenuKey.Key -Value $AccentColorMenuKey.Value -PropertyType $AccentColorMenuKey.Type -Force
} else {
    Set-ItemProperty -Path $RegPath -Name $AccentColorMenuKey.Key -Value $AccentColorMenuKey.Value -Force
}

# Accent Palette Key
$AccentPaletteKey = @{
    Key   = 'AccentPalette';
    Type  = "BINARY";
    Value = $Palette
}

if ($Null -eq (Get-ItemProperty -Path $RegPath -Name $AccentPaletteKey.Key -ErrorAction SilentlyContinue)) {
    New-ItemProperty -Path $RegPath -Name $AccentPaletteKey.Key -PropertyType Binary -Value $Palette
} else {
    Set-ItemProperty -Path $RegPath -Name $AccentPaletteKey.Key -Value $Palette -Force
}

# MotionAccentId_v1.00 Key
$MotionAccentIdKey = @{
    Key   = 'MotionAccentId_v1.00';
    Type  = "DWORD";
    Value = '0x000000db'
}

if ($Null -eq (Get-ItemProperty -Path $RegPath -Name $MotionAccentIdKey.Key -ErrorAction SilentlyContinue)) {
    New-ItemProperty -Path $RegPath -Name $MotionAccentIdKey.Key -Value $MotionAccentIdKey.Value -PropertyType $MotionAccentIdKey.Type -Force
} else {
    Set-ItemProperty -Path $RegPath -Name $MotionAccentIdKey.Key -Value $MotionAccentIdKey.Value -Force
}

# Start Color Menu Key
$StartMenuKey = @{
    Key   = 'StartColorMenu';
    Type  = "DWORD";
    Value = [convert]::ToInt32($ArgbColor, 16)
}

if ($Null -eq (Get-ItemProperty -Path $RegPath -Name $StartMenuKey.Key -ErrorAction SilentlyContinue)) {
    New-ItemProperty -Path $RegPath -Name $StartMenuKey.Key -Value $StartMenuKey.Value -PropertyType $StartMenuKey.Type -Force
} else {
    Set-ItemProperty -Path $RegPath -Name $StartMenuKey.Key -Value $StartMenuKey.Value -Force
}

# Reiniciar o processo Explorer para aplicar as mudanças
Stop-Process -ProcessName explorer -Force -ErrorAction SilentlyContinue
Start-Process explorer

Write-Host "Cor de destaque alterada para $HexColor com sucesso!" -ForegroundColor Green
