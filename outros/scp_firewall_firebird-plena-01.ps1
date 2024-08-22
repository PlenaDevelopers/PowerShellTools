Write-Host "╔" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
write-host "╗" -ForegroundColor Cyan  
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Operação") -NoNewline
Write-Host ("{0,-86} " -f "Criar regras de firewall para o Firebird") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Yellow
Write-Host ("{0,-30} : " -f " Copyright") -NoNewline
Write-Host ("{0,-86} " -f "2023 - Evandro Campanhã") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Yellow

$computerName = (Get-ComputerInfo).CsName
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Computador") -NoNewline
Write-Host ("{0,-86} " -f $computerName) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Script") -NoNewline
Write-Host ("{0,-86} " -f $MyInvocation.MyCommand.Path) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

Write-Host "╠" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
write-host "╣" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor gray
Write-Host "║" -ForegroundColor Cyan
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Tarefa") -NoNewline -ForegroundColor cyan
Write-Host ("{0,-86} " -f "Remover regras do Firewall") -NoNewline -ForegroundColor cyan
Write-Host "║" -ForegroundColor Cyan
Write-Host "║" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor gray
Write-Host "║" -ForegroundColor Cyan

# Palavra específica que você deseja buscar nas regras do firewall
$palavraChave = "Firebird"

# Obter todas as regras do firewall
$regras = Get-NetFirewallRule

# Filtrar regras que contenham a palavra-chave no nome ou no perfil de serviço
$regrasFiltradas = $regras | Where-Object { $_.DisplayName -like "*$palavraChave*" -or $_.ServiceDisplayName -like "*$palavraChave*" }

# Remover as regras filtradas
foreach ($regra in $regrasFiltradas) {
    Remove-NetFirewallRule -Name $regra.Name
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Regra Removida") -NoNewline -ForegroundColor cyan
    Write-Host ("{0,-86} " -f $($regra.DisplayName)) -NoNewline -ForegroundColor cyan
    Write-Host "║" -ForegroundColor Cyan

}

Write-Host "║" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor gray
Write-Host "║" -ForegroundColor Cyan
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Tarefa") -NoNewline -ForegroundColor cyan
Write-Host ("{0,-86} " -f "Adicionar regras no Firewall") -NoNewline -ForegroundColor cyan
Write-Host "║" -ForegroundColor Cyan
Write-Host "║" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor gray
Write-Host "║" -ForegroundColor Cyan

# Nome da regra
$nomeRegra = "Firebird"

# Porta do serviço Firebird (por padrão, é a porta UDP 3050)
$portaSNMP = 3050

# Perfil de rede: Domain, Private, Public
$perfis = "Domain", "Private", "Public"

# Criar regras de entrada para cada perfil
foreach ($perfil in $perfis) {
    $paramsEntrada = @{
        Name        = "$nomeRegra-In-$perfil"
        DisplayName = "Permitir Firebird (Entrada) - $perfil"
        Direction   = "Inbound"
        Action      = "Allow"
        Protocol    = "UDP"
        LocalPort   = $portaSNMP
        Profile     = $perfil
    }

    $null = New-NetFirewallRule @paramsEntrada
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Regra Adicionada (Entrada)") -NoNewline -ForegroundColor White
    Write-Host ("{0,-86} " -f "DisplayName: $($paramsEntrada['DisplayName'])") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan
    
}

# Criar regras de saída para cada perfil
foreach ($perfil in $perfis) {
    $paramsSaida = @{
        Name        = "$nomeRegra-Out-$perfil"
        DisplayName = "Permitir Firebird (Saída) - $perfil"
        Direction   = "Outbound"
        Action      = "Allow"
        Protocol    = "UDP"
        LocalPort   = $portaSNMP
        Profile     = $perfil
    }

    $null = New-NetFirewallRule @paramsSaida

    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Regra Adicionada (Saída)") -NoNewline -ForegroundColor White
    Write-Host ("{0,-86} " -f "DisplayName: $($paramsSaida['DisplayName'])") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan
}

rundll32.exe user32.dll, UpdatePerUserSystemParameters

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