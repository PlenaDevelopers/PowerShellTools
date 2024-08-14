# Script para remover personalizações de aparência no Windows

# Restaurar o papel de parede padrão do Windows
function Restore-Wallpaper {
    $defaultWallpaper = "C:\Windows\Web\Wallpaper\Windows\img0.jpg"
    # Usar RUNDLL32.EXE diretamente para definir o papel de parede
    RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters
}

# Reverter para o tema padrão do Windows
function Restore-Theme {
    $defaultThemePath = "C:\Windows\Resources\Themes\aero.theme"
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes" -Name "CurrentTheme" -Value $defaultThemePath -Force
    # Atualizar as configurações de usuário
    RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters
}

# Reverter cores de destaque para o padrão
function Restore-Colors {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "ColorPrevalence" -Value 0
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 1
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 1
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\DWM" -Name "AccentColor" -Value 0xFF000000
}

# Restaurar fonte padrão do sistema
function Restore-Font {
    Remove-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "FontSmoothing" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "FontSmoothingType" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "FontSmoothingGamma" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "FontSmoothingOrientation" -ErrorAction SilentlyContinue
}

# Execução das funções
Restore-Wallpaper
Restore-Theme
Restore-Colors
Restore-Font

Write-Host "As personalizações de aparência foram removidas e as configurações padrão do Windows foram restauradas."
