# Obtém todas as interfaces de rede
$networkInterfaces = Get-NetAdapter

Write-Host "╔" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
write-host "╗" -ForegroundColor Cyan  
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Configurar Serviço") -NoNewline
Write-Host ("{0,-86} " -f "DHCP") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Yellow
Write-Host ("{0,-30} : " -f " Copyright") -NoNewline
Write-Host ("{0,-86} " -f "2023 - Evandro Campanhã") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Yellow

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Script") -NoNewline
Write-Host ("{0,-86} " -f $MyInvocation.MyCommand.Path) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

Write-Host "╠" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
write-host "╣" -ForegroundColor Cyan

$ipInfo = Get-NetIPAddress -AddressFamily IPv4

# Exibe os endereços IP
foreach ($ip in $ipInfo) {
    if ($ip.InterfaceAlias -ne $null) {
        # Obtém a interface de rede pelo nome
        $interface = Get-NetAdapter | Where-Object { $_.InterfaceIndex -eq $ip.InterfaceIndex }

        # Verifica se a interface existe antes de reiniciar
        if ($interface -ne $null) {
            # Reinicia a interface de rede
            Set-NetIPInterface -InterfaceIndex $interface.InterfaceIndex -Dhcp Enabled

            Write-Host "║" -NoNewline -ForegroundColor Cyan
            Write-Host ("{0,-30} : " -f " Tarefa") -NoNewline -ForegroundColor cyan
            Write-Host ("{0,-86} " -f "Reiniciar o adaptador") -NoNewline -ForegroundColor cyan
            Write-Host "║" -ForegroundColor Cyan
            Write-Host "║" -NoNewline -ForegroundColor Cyan
            write-host ("═" * 120) -NoNewline -ForegroundColor gray
            Write-Host "║" -ForegroundColor Cyan 

            Disable-NetAdapter -InterfaceAlias $interface.InterfaceAlias -Confirm:$false
            Restart-NetAdapter -InterfaceAlias $interface.InterfaceAlias -Confirm:$false
            Enable-NetAdapter -InterfaceAlias $interface.InterfaceAlias -Confirm:$false
                
            Write-Host "║" -NoNewline -ForegroundColor Cyan
            Write-Host ("{0,-30} : " -f " Interface") -NoNewline
            Write-Host ("{0,-86} " -f "Reiniciada com sucesso") -NoNewline -ForegroundColor Green
            Write-Host "║" -ForegroundColor Cyan

        }
        else {
            Write-Host "║" -NoNewline -ForegroundColor Cyan
            Write-Host ("{0,-30} : " -f " Interface") -NoNewline
            Write-Host ("{0,-86} " -f "Não tem um nome válido") -NoNewline -ForegroundColor Gray
            Write-Host "║" -ForegroundColor Cyan
        }
        Start-Sleep -Seconds 5

        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f " Interface ID") -NoNewline
        Write-Host ("{0,-86} " -f $($ip.InterfaceIndex)) -NoNewline -ForegroundColor Green
        Write-Host "║" -ForegroundColor Cyan

        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f " Nome") -NoNewline
        Write-Host ("{0,-86} " -f $($ip.InterfaceAlias)) -NoNewline -ForegroundColor Green
        Write-Host "║" -ForegroundColor Cyan

        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f " Descrição") -NoNewline
        Write-Host ("{0,-86} " -f $($ip.InterfaceDescription)) -NoNewline -ForegroundColor Green
        Write-Host "║" -ForegroundColor Cyan

        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f " Endereço IP") -NoNewline
        Write-Host ("{0,-86} " -f $($ip.IPAddress)) -NoNewline -ForegroundColor Green
        Write-Host "║" -ForegroundColor Cyan

        # Obtém o endereço MAC da interface de rede
        $macAddress = Get-NetAdapter | Where-Object { $_.InterfaceIndex -eq $ip.InterfaceIndex } | Select-Object -ExpandProperty MacAddress
        # Exibe o endereço MAC
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f " Endereço MAC") -NoNewline
        Write-Host ("{0,-86} " -f $($macAddress)) -NoNewline -ForegroundColor Green
        Write-Host "║" -ForegroundColor Cyan

        # Obtém informações da interface de rede para verificar o estado do DHCP
        $networkAdapter = Get-NetAdapter | Where-Object { $_.InterfaceIndex -eq $ip.InterfaceIndex }
    }

    if ($networkAdapter.Status -eq 'Up') {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f " Status") -NoNewline
        Write-Host ("{0,-86} " -f "Conectada") -NoNewline -ForegroundColor Green
        Write-Host "║" -ForegroundColor Cyan

    }
    else {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f " Status") -NoNewline
        Write-Host ("{0,-86} " -f "Desconectada") -NoNewline -ForegroundColor Red
        Write-Host "║" -ForegroundColor Cyan
    }

    if ($networkAdapter.Dhcp -eq 'Disabled') {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f " DHCP") -NoNewline
        Write-Host ("{0,-86} " -f "SIM") -NoNewline -ForegroundColor Green
        Write-Host "║" -ForegroundColor Cyan
    }
    else {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f " DHCP") -NoNewline
        Write-Host ("{0,-86} " -f "NÃO") -NoNewline -ForegroundColor Red
        Write-Host "║" -ForegroundColor Cyan
    }
   
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    write-host ("═" * 120) -NoNewline -ForegroundColor gray
    Write-Host "║" -ForegroundColor Cyan
}


# Aguarda alguns segundos antes de reabilitar as interfaces
Start-Sleep -Seconds 5

foreach ($interface in $networkInterfaces) {
    # Reabilita a interface de rede
    Enable-NetAdapter -InterfaceAlias $interface.InterfaceAlias
}

#Final do Script
Write-Host "╠" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
write-host "╣" -ForegroundColor Cyan  

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Processo")   -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-86} " -f "Finalizado") -NoNewline -ForegroundColor Cyan
Write-Host "║" -ForegroundColor Cyan

Write-Host "╚" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
write-host "╝" -ForegroundColor Cyan 