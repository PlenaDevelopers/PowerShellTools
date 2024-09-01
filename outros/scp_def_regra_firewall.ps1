<#
    Função: Regra de Firewall
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
# Parâmetro de entrada
param (
    [string]$regra_nome = 'Firebird',
    [string]$regra_porta = "3050",
    [string]$regra_protocolo = "2", # 0 = UDP, 1 = TCP, 2 = TCP and UDP
    [string]$regra_direcao = "2",   # 0 = saída, 1 = entrada, 2 = saída e entrada
    [string]$regra_rede = "5"       # 0 = pública, 1 = privada, 2 = domínio, 3 = privada + pública, 4 = privada + domínio, 5 = privada + pública + domínio
)

# Cabeçalho
#----------------------------------------------------------------------------------------------
# Obter o diretório do script atual
$scriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path -Parent

# Obter o nome do script atual
$scriptName = [System.IO.Path]::GetFileName($MyInvocation.MyCommand.Path)

# Construir o caminho completo para o script 'scp_script_cabecalho.ps1'
$cabecalhoScriptPath = Join-Path -Path $scriptDirectory -ChildPath "scp_script_cabecalho.ps1"

# Executar o script de cabeçalho
& $cabecalhoScriptPath -Script $scriptName -Titulo "Regra de Firewall"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
function RemoverRegrasExistentes {
    param (
        [string]$nomePrefixo
    )
    
    # Obter as regras que correspondem ao prefixo fornecido
    $regras = Get-NetFirewallRule | Where-Object { $_.Name -like "$nomePrefixo*" }
    
    # Verificar se há regras a serem removidas
    if ($regras) {
        foreach ($regra in $regras) {
            # Remover cada regra individualmente
            Remove-NetFirewallRule -Name $regra.Name -Confirm:$false
            
            # Exibir mensagem informando qual regra foi removida
            Write-Host "║" -NoNewline -ForegroundColor Cyan
            Write-Host ("{0,-30} : " -f "Remover") -NoNewline -ForegroundColor White
            Write-Host ("{0,-86} " -f $regra.Name) -NoNewline -ForegroundColor Yellow
            Write-Host "║" -ForegroundColor Cyan
        }
    }
}

# Exibe o nome da regra
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Nome") -NoNewline
Write-Host ("{0,-86} " -f $regra_nome) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

# Perfil de rede: Domain, Private, Public
$perfis = @()
if ($regra_rede -eq "0") { $perfis += "Public" }
if ($regra_rede -eq "1") { $perfis += "Private" }
if ($regra_rede -eq "2") { $perfis += "Domain" }
if ($regra_rede -eq "3") { $perfis += "Public", "Private" }
if ($regra_rede -eq "4") { $perfis += "Private", "Domain" }
if ($regra_rede -eq "5") { $perfis += "Public", "Private", "Domain" }

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Perfil") -NoNewline
Write-Host ("{0,-86} " -f $perfis) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

# Mapeamento dos protocolos
$protocolos = @()
if ($regra_protocolo -eq "0") { $protocolos += "UDP" }
if ($regra_protocolo -eq "1") { $protocolos += "TCP" }
if ($regra_protocolo -eq "2") { $protocolos += "UDP", "TCP" }

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Protocolo") -NoNewline
Write-Host ("{0,-86} " -f $protocolos) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

# Remover regras existentes
$prefixoRegra = "$regra_nome-*"
RemoverRegrasExistentes -nomePrefixo $prefixoRegra

# Criar regras de firewall de acordo com a direção especificada, regra de saída
if ($regra_direcao -eq "0" -or $regra_direcao -eq "2") {
    # Criar regra de saída
    foreach ($protocolo in $protocolos) {
        $nomeRegraOut = "$regra_nome-$protocolo-Outbound"
        $paramsRegraOut = @{
            Name        = $nomeRegraOut
            DisplayName = "$regra_nome ($protocolo) (Saída)"
            Action      = "Allow"
            Direction   = "Outbound"
            Protocol    = $protocolo
            Profile     = $perfis
        }
        if ($protocolo -in "UDP", "TCP") {
            $paramsRegraOut["LocalPort"] = $regra_porta
        }
        $null = New-NetFirewallRule @paramsRegraOut

        # Exibir mensagem com o número da porta
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Criar (Regra de Saída)") -NoNewline
        Write-Host ("{0,-30} {1,-56}" -f $nomeRegraOut, "Porta: $regra_porta") -NoNewline -ForegroundColor White
        Write-Host "║" -ForegroundColor Cyan
    }
}

# Criar regras de firewall de acordo com a direção especificada, regra de entrada
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

        # Exibir mensagem com o número da porta
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Criar (Regra de Entrada)") -NoNewline
        Write-Host ("{0,-30} {1,-56}" -f $nomeRegraIn, "Porta: $regra_porta") -NoNewline -ForegroundColor White
        Write-Host "║" -ForegroundColor Cyan
    }
}
#----------------------------------------------------------------------------------------------

# Aplicando alterações
#----------------------------------------------------------------------------------------------
rundll32.exe user32.dll, UpdatePerUserSystemParameters
#----------------------------------------------------------------------------------------------

# Rodapé
#----------------------------------------------------------------------------------------------
# Obter o diretório do script atual
$CurrentScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path -Parent

# Construir o caminho completo para o script 'scp_script_rodape.ps1'
$rodapeScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_script_rodape.ps1"

# Executar o script de rodapé
& $rodapeScriptPath
#----------------------------------------------------------------------------------------------