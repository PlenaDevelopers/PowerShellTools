<#
    Função: Conectar ao Servidor SSH
    Copyright: © Plena Soluções - 2024
    Date: Setembro/2024

    Licenciamento:
    Este script é fornecido "como está", sem qualquer garantia de qualquer tipo,
    expressa ou implícita, incluindo, mas não se limitando às garantias de 
    comercialização, adequação a um determinado fim e não violação. O uso deste 
    script é totalmente gratuito, mas você deve manter os créditos ao autor original.
    
    Bugs & Correções
    Em caso de Bugs encontrado pedimos a gentileza de informar por email para que possamos 
    analisar e gerar atualizações corretivas.

    Autor: Evandro Campanhã
    Contato: aurora.erp@gmail.com
    ------------------------------------------------------------------------------
#>

param (
    [string]$Endereco = "192.168.100.1",
    [string]$Usuario = "root",
    [int]$Porta = 2222,  # Porta padrão é 22
    [string]$Senha = "M@rzza!!02022"
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
& $cabecalhoScriptPath -Script $scriptName -Titulo "Limpar Logs de Eventos do Windows"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
# Verificar se todos os parâmetros foram fornecidos
if (-not $Endereco -or -not $Usuario -or -not $Senha) {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Erro") -NoNewline -ForegroundColor White
    Write-Host ("{0,-86} " -f "Endereço, Usuário e Senha são obrigatórios.") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
    exit 1
}

# Instalar o módulo Posh-SSH silenciosamente, se ainda não estiver instalado
if (-not (Get-Module -ListAvailable -Name Posh-SSH)) {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Instalando") -NoNewline -ForegroundColor White
    Write-Host ("{0,-86} " -f "Posh-SSH") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan

    Install-Module -Name Posh-SSH -Force -AllowClobber -Scope CurrentUser -Confirm:$false
}

# Importar o módulo Posh-SSH
Import-Module Posh-SSH

# Configurar credenciais
$securePassword = ConvertTo-SecureString $Senha -AsPlainText -Force
$credential = New-Object PSCredential($Usuario, $securePassword)

# Criar sessão SSH
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Conectando") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "Iniciando conexão SSH para $Endereco na porta $Porta") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan

try {
    # Tentar criar a sessão SSH
    $session = New-SshSession -ComputerName $Endereco -Port $Porta -Credential $credential -AcceptKey:$true
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Sessão Estabelecida") -NoNewline -ForegroundColor White
    Write-Host ("{0,-86} " -f "Conexão SSH estabelecida com sucesso.") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan

    Write-Host "╚" -NoNewline -ForegroundColor Cyan
    Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
    Write-Host "╝" -ForegroundColor Cyan

    # Manter a sessão aberta para interação
    while ($true) {
        $command = Read-Host "Digite o comando SSH para executar (ou 'exit' para sair)"
        if ($command -eq 'exit') {
            break
        } else {
            try {
                $result = Invoke-SSHCommand -SessionId $session.SessionId -Command $command
                Write-Host $result.Output
            } catch {
                Write-Host "║" -NoNewline -ForegroundColor Cyan
                Write-Host ("{0,-30} : " -f "Erro") -NoNewline -ForegroundColor White
                Write-Host ("{0,-86} " -f "Erro ao executar o comando.") -NoNewline -ForegroundColor Red
                Write-Host "║" -ForegroundColor Cyan
                
                Write-Host "╚" -NoNewline -ForegroundColor Yellow
                Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
                Write-Host "╝" -ForegroundColor Yellow
            }
        }
    }

    # Fechar a sessão SSH
    Remove-SshSession -SessionId $session.SessionId
    Write-Host "╔" -NoNewline -ForegroundColor Cyan
    Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
    Write-Host "╗" -ForegroundColor Cyan 

    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Sessão Fechada") -NoNewline -ForegroundColor White
    Write-Host ("{0,-86} " -f "Sessão SSH fechada com sucesso.") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan

    Write-Host "╚" -NoNewline -ForegroundColor Cyan
    Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
    Write-Host "╝" -ForegroundColor Cyan
} catch {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Erro") -NoNewline -ForegroundColor White
    Write-Host ("{0,-86} " -f "Falha ao estabelecer a conexão SSH.") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
}