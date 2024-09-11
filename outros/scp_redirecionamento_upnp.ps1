function Open-PortViaAPI {
    param (
        [int]$ExternalPort = 9999,          # Porta externa no roteador
        [int]$InternalPort = 9999,          # Porta interna no dispositivo
        [string]$InternalIP = "192.168.15.99",  # IP do dispositivo na rede local
        [string]$Protocol = "TCP",          # Protocolo, pode ser "TCP" ou "UDP"
        [string]$RouterIP = "192.168.15.1",  # IP do roteador
        [string]$Username = "admin",         # Nome de usuário do roteador
        [string]$Password = "password"       # Senha do roteador
    )

    # URL da API para adicionar uma regra de redirecionamento de porta (ajuste conforme a documentação do roteador)
    $apiUrl = "http://$RouterIP/api/portmapping"

    # Corpo da solicitação HTTP para adicionar uma regra de redirecionamento de porta
    $body = @{
        ExternalPort = $ExternalPort
        InternalPort = $InternalPort
        InternalIP = $InternalIP
        Protocol = $Protocol
        Enabled = $true
    }

    # Autenticação básica (ajuste conforme a API do roteador)
    $credentials = [System.Text.Encoding]::UTF8.GetBytes("${Username}:${Password}")
    $encodedCredentials = [System.Convert]::ToBase64String($credentials)

    # Enviar a solicitação HTTP para adicionar a regra de redirecionamento de porta
    try {
        $response = Invoke-RestMethod -Uri $apiUrl -Method Post -Headers @{
            "Authorization" = "Basic $encodedCredentials"
        } -Body $body -ContentType "application/x-www-form-urlencoded"

        Write-Host "Porta ${ExternalPort} (${Protocol}) redirecionada para ${InternalIP}:${InternalPort}." -ForegroundColor Green
    } catch {
        Write-Host "Erro ao redirecionar a porta." -ForegroundColor Red
    }
}

# Chamar a função para abrir a porta
Open-PortViaAPI -ExternalPort 9999 -InternalPort 9999 -InternalIP "192.168.15.99" -Protocol "TCP" -RouterIP "192.168.15.1" -Username "admin" -Password "sqdyhb7x"
