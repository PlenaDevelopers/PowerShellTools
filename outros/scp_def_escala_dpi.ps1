<#
    Função: Alterar a Escala DPI 
    Copyright: © Plena Soluções - 2024
    Data: Agosto/2024
    Autor: Evandro Campanhã
    Contato: aurora.erp@gmail.com
    ------------------------------------------------------------------------------
#>

function Set-DpiScaling {
    param (
        [int]$ScalingLevel
    )
    
    if ($ScalingLevel -lt 100 -or $ScalingLevel -gt 500) {
        Write-Host "Por favor, insira um nível de escala entre 100 e 500."
        return
    }

    # Definir os valores de registro para a escala DPI
    $regPath = "HKCU:\Control Panel\Desktop"
    $logPixelsName = "LogPixels"
    $win8DpiScalingName = "Win8DpiScaling"
    $desktopDpiOverrideName = "DesktopDPIOverride"

    # Mapear nível de escala para valores de registro
    $scalingValues = @{
        100 = 96
        125 = 120
        150 = 144
        200 = 192
    }

    # Configurar o modo de escala global
    Set-ItemProperty -Path $regPath -Name $win8DpiScalingName -Value 1

    # Configurar a escala DPI
    if ($scalingValues.ContainsKey($ScalingLevel)) {
        $dpiValue = $scalingValues[$ScalingLevel]
        Set-ItemProperty -Path $regPath -Name $logPixelsName -Value $dpiValue

        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Escala") -NoNewline
        Write-Host ("{0,-86} " -f "$ScalingLevel%") -NoNewline -ForegroundColor White
        Write-Host "║" -ForegroundColor Cyan
        
        # Forçar reinicialização do Explorer para aplicar as mudanças
        Stop-Process -Name explorer -Force
    } else {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Escala") -NoNewline
        Write-Host ("{0,-86} " -f "Não suportada") -NoNewline -ForegroundColor White
        Write-Host "║" -ForegroundColor Cyan
    }
}

# Exemplo de uso
Set-DpiScaling -ScalingLevel 125
