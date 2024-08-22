#Script para criar regras de entrada e saída no Firewall do Windows
param (
    [string]$regra_nome = 'Firebird',
    [string]$regra_porta = "3050",
    [string]$regra_protocolo = "1", # 0 = UDP, 1 = TCP, 2 = TCP and UDP
    [string]$regra_direcao = "2",   # 0 = saída, 1 = entrada, 2 = saída e entrada
    [string]$regra_rede = "5"       # 0 = pública, 1 = privada, 2 = domínio, 3 = privada + pública, 4 = privada + domínio, 5 = privada + pública + domínio
)

function RemoverRegrasExistentes {
    param (
        [string]$nomePrefixo
    )
    $regras = Get-NetFirewallRule | Where-Object { $_.Name -like "$nomePrefixo*" }
    if ($regras) {
        $regras | Remove-NetFirewallRule -Confirm:$false
    }
}

# Perfil de rede: Domain, Private, Public
$perfis = @()
if ($regra_rede -eq "0") { $perfis += "Public" }
if ($regra_rede -eq "1") { $perfis += "Private" }
if ($regra_rede -eq "2") { $perfis += "Domain" }
if ($regra_rede -eq "3") { $perfis += "Public", "Private" }
if ($regra_rede -eq "4") { $perfis += "Private", "Domain" }
if ($regra_rede -eq "5") { $perfis += "Public", "Private", "Domain" }

# Mapeamento dos protocolos
$protocolos = @()
if ($regra_protocolo -eq "0") { $protocolos += "UDP" }
if ($regra_protocolo -eq "1") { $protocolos += "TCP" }
if ($regra_protocolo -eq "2") { $protocolos += "UDP", "TCP" }

# Remover regras existentes
$prefixoRegra = "$regra_nome-*"
RemoverRegrasExistentes -nomePrefixo $prefixoRegra

# Criar regras de firewall de acordo com a direção especificada
if ($regra_direcao -eq "0" -or $regra_direcao -eq "2") {
    # Criar regra de saída
    foreach ($protocolo in $protocolos) {
        $nomeRegraOut = "$regra_nome-$protocolo-Outbound"
        $paramsRegraOut = @{
            Name        = $nomeRegraOut
            DisplayName = "$regra_nome ($protocolo) (Saida)"
            Action      = "Allow"
            Direction   = "Outbound"
            Protocol    = $protocolo
            Profile     = $perfis
        }
        if ($protocolo -in "UDP", "TCP") {
            $paramsRegraOut["LocalPort"] = $regra_porta
        }
        $null = New-NetFirewallRule @paramsRegraOut
    }
}

if ($regra_direcao -eq "1" -or $regra_direcao -eq "2") {
    # Criar regra de entrada
    foreach ($protocolo in $protocolos) {
        $nomeRegraIn = "$regra_nome-$protocolo-Inbound"
        $paramsRegraIn = @{
            Name        = $nomeRegraIn
            DisplayName = "$regra_nome ($protocolo) (Entrada)"
            Action      = "Allow"
            Direction   = "Inbound"
            Protocol    = $protocolo
            Profile     = $perfis
        }
        if ($protocolo -in "UDP", "TCP") {
            $paramsRegraIn["LocalPort"] = $regra_porta
        }
        $null = New-NetFirewallRule @paramsRegraIn
    }
}
