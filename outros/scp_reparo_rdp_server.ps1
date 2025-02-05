# =====================================================================
# Script para Diagnóstico e Correção do Erro: 
# "O pool de servidores não corresponde aos agentes de conexão da Área de Trabalho Remota que estão nele."
# =====================================================================

# Função para verificar se o serviço está em execução
function Check-ServiceStatus {
    param (
        [string]$ServiceName
    )

    Write-Host "Verificando o status do serviço: $ServiceName..." -ForegroundColor Cyan
    $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
    if ($service -and $service.Status -eq 'Running') {
        Write-Host "O serviço $ServiceName está em execução." -ForegroundColor Green
    } elseif ($service) {
        Write-Host "O serviço $ServiceName está parado. Iniciando o serviço..." -ForegroundColor Yellow
        Start-Service -Name $ServiceName
        Write-Host "O serviço $ServiceName foi iniciado." -ForegroundColor Green
    } else {
        Write-Host "O serviço $ServiceName não foi encontrado no servidor." -ForegroundColor Red
    }
}

# Verificar e iniciar serviços críticos para RDS
Write-Host "Etapa 1: Verificar serviços do Remote Desktop Services..." -ForegroundColor Cyan
Check-ServiceStatus -ServiceName "TermService"  # Remote Desktop Services
Check-ServiceStatus -ServiceName "Tssdis"      # Remote Desktop Connection Broker
Check-ServiceStatus -ServiceName "SessionEnv"  # Remote Desktop Configuration
Check-ServiceStatus -ServiceName "RDLicensing" # Remote Desktop Licensing (se aplicável)

# Testar comunicação entre os servidores
Write-Host "Etapa 2: Testar comunicação entre servidores do pool..." -ForegroundColor Cyan
$servers = @("l-server-01.lextack.local.net")  # Substitua pelos nomes dos servidores adicionais, se necessário
foreach ($server in $servers) {
    Write-Host "Testando conexão com o servidor $server..." -ForegroundColor Cyan
    if (Test-Connection -ComputerName $server -Count 2 -Quiet) {
        Write-Host "Conexão com $server está OK." -ForegroundColor Green
    } else {
        Write-Host "Não foi possível conectar ao servidor $server. Verifique a rede ou firewall." -ForegroundColor Red
    }
}

# Reiniciar os serviços RDS para aplicar alterações
Write-Host "Etapa 3: Reiniciar serviços relacionados ao RDS..." -ForegroundColor Cyan
$rdServices = @("TermService", "Tssdis", "SessionEnv", "RDLicensing")
foreach ($service in $rdServices) {
    Write-Host "Reiniciando o serviço: $service..." -ForegroundColor Yellow
    Restart-Service -Name $service -Force -ErrorAction SilentlyContinue
    Write-Host "O serviço $service foi reiniciado." -ForegroundColor Green
}

# Verificar a configuração do DNS e resolução de nomes
Write-Host "Etapa 4: Verificar resolução de nomes DNS..." -ForegroundColor Cyan
foreach ($server in $servers) {
    Write-Host "Verificando o nome DNS do servidor $server..." -ForegroundColor Cyan
    try {
        $dnsResult = [System.Net.Dns]::GetHostAddresses($server)
        if ($dnsResult) {
            Write-Host "Resolução de nomes para $server está funcionando." -ForegroundColor Green
        }
    } catch {
        Write-Host "Erro ao resolver o nome DNS para $server. Verifique as configurações de DNS." -ForegroundColor Red
    }
}

# Concluir o script
Write-Host "Etapa 5: Verificações e ajustes concluídos. Verifique se o problema foi resolvido." -ForegroundColor Cyan
