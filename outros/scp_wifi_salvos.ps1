<#
    Função: Lista Redes Wifi
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

# Cabeçalho
#----------------------------------------------------------------------------------------------
# Obter o diretório do script atual
$scriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path -Parent

# Obter o nome do script atual
$scriptName = [System.IO.Path]::GetFileName($MyInvocation.MyCommand.Path)

# Construir o caminho completo para o script 'scp_script_cabecalho.ps1'
$cabecalhoScriptPath = Join-Path -Path $scriptDirectory -ChildPath "scp_script_cabecalho.ps1"

# Executar o script de cabeçalho
& $cabecalhoScriptPath -Script $scriptName -Titulo "Lista Redes Wifi"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------

# Função para listar todas as redes Wi-Fi e suas senhas
function Get-AllWifiPasswords {
    # Executa o comando para listar perfis de Wi-Fi salvos
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Status") -NoNewline
    Write-Host ("{0,-86} " -f "Listando todas as redes Wi-Fi salvas no sistema...") -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan

    $wifiProfiles = netsh wlan show profiles

    # Extrai os nomes das redes Wi-Fi (SSIDs)
    $wifiProfiles = $wifiProfiles | Select-String "Todos os Perfis de Usuário" | ForEach-Object { ($_ -split ":")[1].Trim() }

    if ($wifiProfiles.Count -eq 0) {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Status") -NoNewline
        Write-Host ("{0,-86} " -f "Nenhuma rede Wi-Fi salva foi encontrada.") -NoNewline -ForegroundColor White
        Write-Host "║" -ForegroundColor Cyan
        return
    }

    # Itera sobre cada perfil e exibe a senha
    foreach ($profile in $wifiProfiles) {

        # Executa o comando para exibir os detalhes da rede, incluindo a senha
        $wifiDetails = netsh wlan show profile name="$profile" key=clear

        # Procura pela linha que contém a senha
        $wifiPassword = $wifiDetails | Select-String "Conteúdo da Chave"

        if ($wifiPassword) {
            # Extrai a senha e exibe
            $password = ($wifiPassword -split ":")[1].Trim()
            Write-Host "║" -NoNewline -ForegroundColor Cyan
            Write-Host ("{0,-30} : " -f "Rede") -NoNewline
            Write-Host ("{0,-86} " -f "$profile Senha: $password") -NoNewline -ForegroundColor Green
            Write-Host "║" -ForegroundColor Cyan
        } else {
            Write-Host "║" -NoNewline -ForegroundColor Cyan
            Write-Host ("{0,-30} : " -f "Rede") -NoNewline
            Write-Host ("{0,-86} " -f "$profile Senha: Não disponível ou rede aberta") -NoNewline -ForegroundColor Green
            Write-Host "║" -ForegroundColor Cyan
        }
    }
}

# Executa a função
Get-AllWifiPasswords
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