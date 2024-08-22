param (
    [string]$snmp_endereco = 'Rua Doutor Bittencourt Rodrigues, 112',
    [string]$snmp_contato = 'Evandro Campanha',
    [string]$snmp_firewall_nome = "PermitirSNMP",
    [string]$snmp_firewall_porta = "161",
    [string]$snmp_manager_1 = "192.168.120.200",
    [string]$snmp_manager_2 = "192.168.120.253",
    [string]$snmp_comunidade_leitura = "public",
    [string]$snmp_comunidade_gravacao = "private"
)

Write-Host "╔" -NoNewline -ForegroundColor Cyan
Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
Write-Host "╗" -ForegroundColor Cyan  
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Configurar Serviço") -NoNewline
Write-Host ("{0,-86} " -f "Protocolo SNMP") -NoNewline -ForegroundColor Yellow
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
Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
Write-Host "╣" -ForegroundColor Cyan

# Detecta o nome do sistema operacional
$os = (Get-CimInstance Win32_OperatingSystem).Caption

# Instala o serviço SNMP com a sintaxe correta com base no sistema operacional
if ($os -like '*Windows 11*' -or $os -like '*Windows 10*') {
    $null = Add-WindowsCapability -Online -Name "SNMP.Client~~~~0.0.1.0"
    $snmpCapability = Get-WindowsCapability -Online | Where-Object { $_.Name -eq 'SNMP.Client' }

    $null = Add-WindowsCapability -Online -Name "WMI-SNMP-Provider.Client~~~~0.0.1.0"
    $wmiSnmpCapability = Get-WindowsCapability -Online | Where-Object { $_.Name -eq 'WMI-SNMP-Provider.Client' }
} elseif ($os -like '*Windows Server*') {
    $null = Add-WindowsCapability -Online -Name "SNMP.Client~~~~0.0.1.0"
    $snmpCapability = Get-WindowsCapability -Online | Where-Object { $_.Name -eq 'SNMP.Client' }

    $null = Install-WindowsFeature SNMP-Service, SNMP-WMI-Provider -IncludeManagementTools
    $wmiSnmpCapability = Get-WindowsCapability -Online | Where-Object { $_.Name -eq 'WMI-SNMP-Provider.Client' }
}

rundll32.exe user32.dll, UpdatePerUserSystemParameters

$regPaths = @(
    "HKLM:\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\TrapConfiguration",
    "HKLM:\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\PermittedManagers",
    "HKLM:\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\ValidCommunities"
)

foreach ($regPath in $regPaths) {
    $null = Remove-Item -Path $regPath -Recurse -ErrorAction SilentlyContinue

    # Verificar se a chave do registro existe
    if (-not (Test-Path $regPath)) {
        # Criar a chave do registro se não existir
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f " Criando Item") -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-86} " -f "$regPath") -NoNewline -ForegroundColor Green
        Write-Host "║" -ForegroundColor Cyan
        $null = New-Item -Path $regPath -Force
    }
}

$regSettings = @{
    "HKLM:\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\RFC1156Agent" = @{
        "sysServices" = 79
        "sysLocation" = $snmp_endereco
        "sysContact" = $snmp_contato
    }
    "HKLM:\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\ValidCommunities" = @{
        $snmp_comunidade_leitura = "public"   # Comunidade de somente leitura
        $snmp_comunidade_gravacao = "private"  # Comunidade de leitura e gravação
    }
}

foreach ($key in $regSettings.Keys) {
    foreach ($property in $regSettings[$key].Keys) {
        $value = $regSettings[$key][$property]
        try {
            if ($property -eq "sysServices") {
                # Adiciona como REG_DWORD
                Write-Host "║" -NoNewline -ForegroundColor Cyan
                Write-Host ("{0,-30} : " -f " Criando Item") -NoNewline -ForegroundColor Cyan
                Write-Host ("{0,-86} " -f "$property") -NoNewline -ForegroundColor Green
                Write-Host "║" -ForegroundColor Cyan
                $Null=New-ItemProperty -Path $key -Name $property -PropertyType DWord -Value $value -Force
            } else {
                # Adiciona como REG_SZ
                Write-Host "║" -NoNewline -ForegroundColor Cyan
                Write-Host ("{0,-30} : " -f " Criando Item") -NoNewline -ForegroundColor Cyan
                Write-Host ("{0,-86} " -f "$property") -NoNewline -ForegroundColor Green
                Write-Host "║" -ForegroundColor Cyan
                $Null=New-ItemProperty -Path $key -Name $property -PropertyType String -Value $value -Force
            }
        } catch {
            Write-Host "Erro ao configurar o registro: $_" -ForegroundColor Red
        }
    }
}

# Adiciona os gerentes permitidos
$permittedManagersPath = "HKLM:\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\PermittedManagers"
$managers = @($snmp_manager_1, $snmp_manager_2)
$i = 1
foreach ($Manager in $managers) {
    if ($Manager -like "192.168.120.*") {
        try {
            Write-Host "║" -NoNewline -ForegroundColor Cyan
            Write-Host ("{0,-30} : " -f " Manager") -NoNewline -ForegroundColor Cyan
            Write-Host ("{0,-86} " -f "$Manager") -NoNewline -ForegroundColor Green
            Write-Host "║" -ForegroundColor Cyan

            $Null=New-ItemProperty -Path $permittedManagersPath -Name $i -PropertyType String -Value $Manager -Force
            $i++
        } catch {
            Write-Host "Erro ao adicionar gerentes permitidos ao registro: $_" -ForegroundColor Red
        }
    }
}

# Obter todas as regras do firewall
$regras = Get-NetFirewallRule

# Filtrar regras que contenham a palavra-chave no nome ou no perfil de serviço
$regrasFiltradas = $regras | Where-Object { $_.DisplayName -like "*$snmp_firewall_nome*" -or $_.ServiceDisplayName -like "*$snmp_firewall_nome*" }

# Remover as regras filtradas
foreach ($regra in $regrasFiltradas) {
    $Null=Remove-NetFirewallRule -Name $regra.Name
}

# Perfil de rede: Domain, Private, Public
$perfis = "Domain", "Private", "Public"

# Criar regras de entrada para cada perfil
foreach ($perfil in $perfis) {
    $ruleNameIn = "$snmp_firewall_nome-In-$perfil"
    if (-not (Get-NetFirewallRule -DisplayName $ruleNameIn -ErrorAction SilentlyContinue)) {
        try {
            Write-Host "║" -NoNewline -ForegroundColor Cyan
            Write-Host ("{0,-30} : " -f " Criando Regra") -NoNewline -ForegroundColor Cyan
            Write-Host ("{0,-86} " -f "$ruleNameIn") -NoNewline -ForegroundColor Green
            Write-Host "║" -ForegroundColor Cyan
            New-NetFirewallRule -DisplayName $ruleNameIn -Direction Inbound -Protocol UDP -LocalPort $snmp_firewall_porta -Action Allow -Profile $perfil
        } catch {
            Write-Host "Erro ao criar regra de firewall: $_" -ForegroundColor Red
        }
    }

    $ruleNameOut = "$snmp_firewall_nome-Out-$perfil"
    if (-not (Get-NetFirewallRule -DisplayName $ruleNameOut -ErrorAction SilentlyContinue)) {
        try {
            Write-Host "║" -NoNewline -ForegroundColor Cyan
            Write-Host ("{0,-30} : " -f " Criando Regra") -NoNewline -ForegroundColor Cyan
            Write-Host ("{0,-86} " -f "$ruleNameOut") -NoNewline -ForegroundColor Green
            Write-Host "║" -ForegroundColor Cyan
            New-NetFirewallRule -DisplayName $ruleNameOut -Direction Outbound -Protocol UDP -LocalPort $snmp_firewall_porta -Action Allow -Profile $perfil
        } catch {
            Write-Host "Erro ao criar regra de firewall: $_" -ForegroundColor Red
        }
    }
}

# Obtém informações sobre o serviço SNMP
$snmpService = Get-Service -Name SNMP -ErrorAction SilentlyContinue

# Configura o serviço SNMP para iniciar automaticamente
Write-Host "╠" -NoNewline -ForegroundColor Cyan
Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
Write-Host "╣" -ForegroundColor Cyan

try {
    if ($snmpService) {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f " Definindo serviço SNMP") -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-86} " -f "Início Automático") -NoNewline -ForegroundColor Green
        Write-Host "║" -ForegroundColor Cyan

        Set-Service -Name SNMP -StartupType Automatic
    } else {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f " Serviço SNMP") -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-86} " -f "Não encontrado") -NoNewline -ForegroundColor Green
        Write-Host "║" -ForegroundColor Cyan
    }
} catch {
    Write-Host "Erro ao configurar o serviço SNMP: $_" -ForegroundColor Red
}

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Iniciando serviço SNMP") -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-86} " -f "Aguarde") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan

try {
    Start-Service -Name SNMP
} catch {
    Write-Host "Erro ao iniciar o serviço SNMP: $_" -ForegroundColor Red
}

Write-Host "╠" -NoNewline -ForegroundColor Cyan
Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
Write-Host "╣" -ForegroundColor Cyan
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Processo") -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-86} " -f "Finalizado") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan
Write-Host "╚" -NoNewline -ForegroundColor Cyan
Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
Write-Host "╝" -ForegroundColor Cyan
