param (
    [string]$ipInicial,
    [string]$ipFinal,
    [string]$ocultarAusentes = "1"
)

function Testar-Host {
    param ($ip)
    try {
        $nome = [System.Net.Dns]::GetHostEntry($ip).HostName
    } catch {
        $nome = $null
    }
    return $nome
}

function Validar-IP {
    param ($ip)
    return [System.Net.IPAddress]::TryParse($ip, [ref]$null)
}

function Obter-RedeLocal {
    $netIP = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -ne "127.0.0.1" -and $_.PrefixOrigin -eq "Dhcp" }
    
    if (-not $netIP) {
        Write-Host "Erro: Não foi possível obter o endereço IP da rede local."
        return $null
    }

    $enderecoIP = $netIP.IPAddress
    $prefixo = $netIP.PrefixLength

    # Calcular a faixa de IP com base no prefixo
    $subnet = [System.Net.IPAddress]::Parse($enderecoIP)
    $bytes = $subnet.GetAddressBytes()
    $numHosts = [math]::Pow(2, (32 - $prefixo)) - 2

    # Definir o IP inicial e final da faixa
    $ipInicial = $enderecoIP -replace '\.\d+$','.1'    # Usar o primeiro IP
    $ipFinal = $enderecoIP -replace '\.\d+$','.254'    # Usar o último IP

    return @{ ipInicial = $ipInicial; ipFinal = $ipFinal }
}

function IPtoInteger {
    param ($ip)
    $bytes = [System.Net.IPAddress]::Parse($ip).GetAddressBytes()
    [Array]::Reverse($bytes)
    return [BitConverter]::ToUInt32($bytes, 0)
}

function IntegerToIP {
    param ($int)
    $bytes = [BitConverter]::GetBytes($int)
    [Array]::Reverse($bytes)
    return [System.Net.IPAddress]::Parse(($bytes -join '.'))
}

function Escanear-Rede {
    param (
        [string]$ipInicial,
        [string]$ipFinal,
        [bool]$ocultarAusentes
    )

    # Se não fornecer IPs, pegar a rede local
    if (-not $ipInicial -or -not $ipFinal) {
        $faixaIP = Obter-RedeLocal
        if ($faixaIP -eq $null) { return }
        $ipInicial = $faixaIP.ipInicial
        $ipFinal = $faixaIP.ipFinal
    }

    # Validar IPs fornecidos
    if (-not (Validar-IP $ipInicial)) {
        Write-Host "Erro: IP Inicial '$ipInicial' é inválido."
        return
    }

    if (-not (Validar-IP $ipFinal)) {
        Write-Host "Erro: IP Final '$ipFinal' é inválido."
        return
    }

    # Converter IPs para inteiros para comparação
    $currentIPInt = IPtoInteger $ipInicial
    $endIPInt = IPtoInteger $ipFinal

    Write-Host "Iniciando o scan de $ipInicial até $ipFinal..."

    while ($currentIPInt -le $endIPInt) {
        $currentIP = IntegerToIP $currentIPInt
        $hostname = Testar-Host $currentIP

        if ($hostname -or $ocultarAusentes -eq $false) {
            Write-Host "$currentIP | $hostname"
        }

        # Incrementar o IP
        $currentIPInt++
    }
}

# Verificar os valores de entrada
Write-Host "IP Inicial: $ipInicial"
Write-Host "IP Final: $ipFinal"

# Chamada da função
Escanear-Rede -ipInicial $ipInicial -ipFinal $ipFinal -ocultarAusentes ($ocultarAusentes -eq "1")
