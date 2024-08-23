<#
    Função: Habilitar o DHCP em todos os adpatadores
	Copyright: © Plena Soluções - 2024
	Date: Agosto/2024

	Licenciamento:
	Este script é fornecido "como está", sem qualquer garantia de qualquer tipo,
	expressa ou implícita, incluindo, mas não se limitando às garantias de 
	comercialização, adequação a um determinado fim e não violação. O uso deste 
	script é totalmente gratuito, mas você deve manter os créditos ao autor original.
	
	Seriais/Keys:
	Os Seriais/Keys para licenciamento de software contidos neste ou em outros
	arquivos são meramente ilustrativos para a utilização do script, sendo assim cabe
	ao utilizador do script alterar estas chaves para uma válida que represente o 
	licenciamento vigente.

	Bugs & Correções
	Em caso de Bugs encontrado pedimos a gentileza de informar por email para que possamos 
	analizar e gerar atualizações corretivas.

	Autor: Evandro Campanhã
	Contato: aurora.erp@gmail.com
	------------------------------------------------------------------------------
#>

# Cabecalho
#----------------------------------------------------------------------------------------------
# Obter o diretório do script atual
$scriptName = [System.IO.Path]::GetFileName($MyInvocation.MyCommand.Path)
$CurrentScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path

# Construir o caminho completo para o script 'scp_script_cabecalho.ps1'
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_script_cabecalho.ps1"

& $CabecalhoScriptPath -Script $scriptName -Titulo "Definir protocolo DHCP"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
# Obtém todas as interfaces de rede
$networkInterfaces = Get-NetAdapter

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
            Write-Host ("{0,-30} : " -f "Tarefa") -NoNewline -ForegroundColor cyan
            Write-Host ("{0,-86} " -f "Reiniciar o adaptador") -NoNewline -ForegroundColor cyan
            Write-Host "║" -ForegroundColor Cyan

            Write-Host "║" -NoNewline -ForegroundColor Cyan
            write-host ("═" * 120) -NoNewline -ForegroundColor gray
            Write-Host "║" -ForegroundColor Cyan 

            Disable-NetAdapter -InterfaceAlias $interface.InterfaceAlias -Confirm:$false
            Restart-NetAdapter -InterfaceAlias $interface.InterfaceAlias -Confirm:$false
            Enable-NetAdapter -InterfaceAlias $interface.InterfaceAlias -Confirm:$false
                
            Write-Host "║" -NoNewline -ForegroundColor Cyan
            Write-Host ("{0,-30} : " -f "Interface") -NoNewline
            Write-Host ("{0,-86} " -f "Reiniciada com sucesso") -NoNewline -ForegroundColor Green
            Write-Host "║" -ForegroundColor Cyan

        }
        else {
            Write-Host "║" -NoNewline -ForegroundColor Cyan
            Write-Host ("{0,-30} : " -f "Interface") -NoNewline
            Write-Host ("{0,-86} " -f "Não tem um nome válido") -NoNewline -ForegroundColor Gray
            Write-Host "║" -ForegroundColor Cyan
        }
        Start-Sleep -Seconds 5

        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Interface ID") -NoNewline
        Write-Host ("{0,-86} " -f $($ip.InterfaceIndex)) -NoNewline -ForegroundColor Green
        Write-Host "║" -ForegroundColor Cyan

        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Nome") -NoNewline
        Write-Host ("{0,-86} " -f $($ip.InterfaceAlias)) -NoNewline -ForegroundColor Green
        Write-Host "║" -ForegroundColor Cyan

        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Descrição") -NoNewline
        Write-Host ("{0,-86} " -f $($ip.InterfaceDescription)) -NoNewline -ForegroundColor Green
        Write-Host "║" -ForegroundColor Cyan

        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Endereço IP") -NoNewline
        Write-Host ("{0,-86} " -f $($ip.IPAddress)) -NoNewline -ForegroundColor Green
        Write-Host "║" -ForegroundColor Cyan

        # Obtém o endereço MAC da interface de rede
        $macAddress = Get-NetAdapter | Where-Object { $_.InterfaceIndex -eq $ip.InterfaceIndex } | Select-Object -ExpandProperty MacAddress
        # Exibe o endereço MAC
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Endereço MAC") -NoNewline
        Write-Host ("{0,-86} " -f $($macAddress)) -NoNewline -ForegroundColor Green
        Write-Host "║" -ForegroundColor Cyan

        # Obtém informações da interface de rede para verificar o estado do DHCP
        $networkAdapter = Get-NetAdapter | Where-Object { $_.InterfaceIndex -eq $ip.InterfaceIndex }
    }

    if ($networkAdapter.Status -eq 'Up') {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Status") -NoNewline
        Write-Host ("{0,-86} " -f "Conectada") -NoNewline -ForegroundColor Green
        Write-Host "║" -ForegroundColor Cyan

    }
    else {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Status") -NoNewline
        Write-Host ("{0,-86} " -f "Desconectada") -NoNewline -ForegroundColor Red
        Write-Host "║" -ForegroundColor Cyan
    }

    if ($networkAdapter.Dhcp -eq 'Disabled') {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "DHCP") -NoNewline
        Write-Host ("{0,-86} " -f "SIM") -NoNewline -ForegroundColor Green
        Write-Host "║" -ForegroundColor Cyan
    }
    else {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "DHCP") -NoNewline
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
#----------------------------------------------------------------------------------------------

# Aplicando alterações
#----------------------------------------------------------------------------------------------
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