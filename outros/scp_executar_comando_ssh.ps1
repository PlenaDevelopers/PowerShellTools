<#
    Função: Conectar ao Servidor SSH e Executar Comando
    Copyright: © Plena Soluções - 2024
    Date: Setembro/2024
#>

param (
    [string]$Endereco = "192.168.120.1",
    [string]$Usuario = "root",
    [int]$Porta = 2222,  # Porta padrão é 22
    [string]$Senha = "P@ssw0rdCore2024",
    [string]$ComandoInicial = "uptime" # Defina aqui o comando a ser executado automaticamente
)

# Cabeçalho
#----------------------------------------------------------------------------------------------
$scriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
$scriptName = [System.IO.Path]::GetFileName($MyInvocation.MyCommand.Path)
$cabecalhoScriptPath = Join-Path -Path $scriptDirectory -ChildPath "scp_script_cabecalho.ps1"
& $cabecalhoScriptPath -Script $scriptName -Titulo "Conectar ao Servidor SSH e Executar Comando"
#----------------------------------------------------------------------------------------------

# Verificar se todos os parâmetros foram fornecidos
if (-not $Endereco -or -not $Usuario -or -not $Senha) {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Erro") -NoNewline -ForegroundColor White
    Write-Host ("{0,-86} " -f "Endereço, Usuário e Senha são obrigatórios.") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
    exit 1
}

# Instalar e importar módulo Posh-SSH
if (-not (Get-Module -ListAvailable -Name Posh-SSH)) {
    Install-Module -Name Posh-SSH -Force -AllowClobber -Scope CurrentUser -Confirm:$false
}
Import-Module Posh-SSH

# Configurar credenciais
$securePassword = ConvertTo-SecureString $Senha -AsPlainText -Force
$credential = New-Object PSCredential($Usuario, $securePassword)

# Conectar ao servidor SSH
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Conectando") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f "Iniciando conexão SSH para $Endereco na porta $Porta") -NoNewline -ForegroundColor Green
Write-Host "║" -ForegroundColor Cyan

try {
    $session = New-SshSession -ComputerName $Endereco -Port $Porta -Credential $credential -AcceptKey:$true
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Sessão Estabelecida") -NoNewline -ForegroundColor White
    Write-Host ("{0,-86} " -f "Conexão SSH estabelecida com sucesso.") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan

    # Executar Comando Inicial
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Executando Comando") -NoNewline -ForegroundColor White
    Write-Host ("{0,-86} " -f "$ComandoInicial") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan

    $result = Invoke-SSHCommand -SessionId $session.SessionId -Command $ComandoInicial
    Write-Host "╔══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗"
    Write-Host $result.Output -ForegroundColor Yellow
    Write-Host "╚══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝"

    # Manter sessão interativa
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
            }
        }
    }

    # Fechar sessão SSH
    Remove-SshSession -SessionId $session.SessionId
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Sessão Fechada") -NoNewline -ForegroundColor White
    Write-Host ("{0,-86} " -f "Sessão SSH fechada com sucesso.") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan

} catch {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Erro") -NoNewline -ForegroundColor White
    Write-Host ("{0,-86} " -f "Falha ao estabelecer a conexão SSH.") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
}
