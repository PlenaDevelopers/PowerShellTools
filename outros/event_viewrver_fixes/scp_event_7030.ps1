# Função para verificar o uso de heap de área de trabalho
function Get-DesktopHeapUsage {
    $desktopHeapData = @()

    $sessions = (qwinsta) -replace '\s{2,}', ',' | ConvertFrom-Csv

    foreach ($session in $sessions) {
        if ($session.STATE -eq "Active") {
            $desktopHeapData += New-Object PSObject -Property @{
                SessionName = $session.SESSIONNAME
                SessionID = $session.ID
                UserName = $session.USERNAME
                HeapUsage = (Get-Process -SessionId $session.ID | Measure-Object WorkingSet -Sum).Sum / 1MB
            }
        }
    }

    return $desktopHeapData
}

# Executar a função para verificar o uso do heap
$desktopHeapUsage = Get-DesktopHeapUsage

# Exibir os resultados
$desktopHeapUsage | Format-Table -AutoSize
