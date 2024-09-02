<#
    Função: Conectar ao Banco de Dados SQL Server e Criar DSN
	Copyright: © Plena Soluções - 2024
	Date: Setembro/2024

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

param(
    [string]$Servidor = "192.168.100.158",
    [string]$BancoDeDados = "SIGLA",
    [string]$Usuario = "sa",
    [string]$Senha = "M@rzz@llo0101",
    [string]$NomeDaConexao = "SIGLA",
    [string]$TipoDSN = "1"  # 1 para DSN do usuário, 2 para DSN do sistema
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
& $cabecalhoScriptPath -Script $scriptName -Titulo "Conectar ao Banco de Dados SQL Server e Criar DSN"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
function Testar-Conexao {
    param (
        [string]$ConnectionString
    )
    try {
        $connection = New-Object System.Data.SqlClient.SqlConnection($ConnectionString)
        $connection.Open()
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Status") -NoNewline -ForegroundColor White
        Write-Host ("{0,-86} " -f "Conectado") -NoNewline -ForegroundColor Cyan
        Write-Host "║" -ForegroundColor Cyan
        $connection.Close()
    } catch {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Status") -NoNewline -ForegroundColor White
        Write-Host ("{0,-86} " -f "Falha na conexão: $_") -NoNewline -ForegroundColor Cyan
        Write-Host "║" -ForegroundColor Cyan
    }
}

function Criar-DSN {
    param (
        [string]$NomeDSN,
        [string]$Driver,
        [string]$Servidor,
        [string]$BancoDeDados,
        [string]$Usuario,
        [string]$Senha,
        [string]$TipoDSN
    )

    $dsnPath = if ($TipoDSN -eq "1") {
        "HKCU:\Software\ODBC\ODBC.INI\$NomeDSN"  # DSN do usuário
    } elseif ($TipoDSN -eq "2") {
        "HKLM:\Software\ODBC\ODBC.INI\$NomeDSN"  # DSN do sistema
    } else {
        Write-Host "Tipo DSN inválido. Use 1 para DSN do usuário ou 2 para DSN do sistema." -ForegroundColor Red
        return
    }

    # Adicionar DSN ao registro
    if (-not (Test-Path $dsnPath)) {
        $null = New-Item -Path $dsnPath -Force | Out-Null
        }
        Set-ItemProperty -Path $dsnPath -Name "Driver" -Value $Driver
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Driver") -NoNewline -ForegroundColor White
        Write-Host ("{0,-86} " -f $Driver) -NoNewline -ForegroundColor White
        Write-Host "║" -ForegroundColor Cyan

        Set-ItemProperty -Path $dsnPath -Name "Server" -Value $Servidor
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Servidor") -NoNewline -ForegroundColor White
        Write-Host ("{0,-86} " -f $Servidor) -NoNewline -ForegroundColor White
        Write-Host "║" -ForegroundColor Cyan

        Set-ItemProperty -Path $dsnPath -Name "Database" -Value $BancoDeDados
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Banco de Dados") -NoNewline -ForegroundColor White
        Write-Host ("{0,-86} " -f $BancoDeDados) -NoNewline -ForegroundColor White
        Write-Host "║" -ForegroundColor Cyan

        Set-ItemProperty -Path $dsnPath -Name "Uid" -Value $Usuario
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Usuário") -NoNewline -ForegroundColor White
        Write-Host ("{0,-86} " -f $Usuario) -NoNewline -ForegroundColor White
        Write-Host "║" -ForegroundColor Cyan

        Set-ItemProperty -Path $dsnPath -Name "Pwd" -Value $Senha
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Senha") -NoNewline -ForegroundColor White
        Write-Host ("{0,-86} " -f $Senha) -NoNewline -ForegroundColor White
        Write-Host "║" -ForegroundColor Cyan

        Set-ItemProperty -Path $dsnPath -Name "Description" -Value $Descricao
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Descrição") -NoNewline -ForegroundColor White
        Write-Host ("{0,-86} " -f $Descricao) -NoNewline -ForegroundColor White
        Write-Host "║" -ForegroundColor Cyan

        Set-ItemProperty -Path $dsnPath -Name "Encrypt" -Value $Encrypt
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Encriptação") -NoNewline -ForegroundColor White
        Write-Host ("{0,-86} " -f $Encrypt) -NoNewline -ForegroundColor White
        Write-Host "║" -ForegroundColor Cyan

        Set-ItemProperty -Path $dsnPath -Name "TrustServerCertificate" -Value $TrustServerCertificate
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Certificado") -NoNewline -ForegroundColor White
        Write-Host ("{0,-86} " -f $TrustServerCertificate) -NoNewline -ForegroundColor White
        Write-Host "║" -ForegroundColor Cyan

        Set-ItemProperty -Path $dsnPath -Name "ClientCertificate" -Value $ClientCertificate
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Certificado do Cliente") -NoNewline -ForegroundColor White
        Write-Host ("{0,-86} " -f $ClientCertificate) -NoNewline -ForegroundColor White
        Write-Host "║" -ForegroundColor Cyan

        Set-ItemProperty -Path $dsnPath -Name "KeystoreAuthentication" -Value $KeystoreAuthentication
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Autenticação") -NoNewline -ForegroundColor White
        Write-Host ("{0,-86} " -f $KeystoreAuthentication) -NoNewline -ForegroundColor White
        Write-Host "║" -ForegroundColor Cyan

        Set-ItemProperty -Path $dsnPath -Name "KeystorePrincipalId" -Value $KeystorePrincipalId
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "ID") -NoNewline -ForegroundColor White
        Write-Host ("{0,-86} " -f $KeystorePrincipalId) -NoNewline -ForegroundColor White
        Write-Host "║" -ForegroundColor Cyan

        Set-ItemProperty -Path $dsnPath -Name "KeystoreSecret" -Value $KeystoreSecret
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Secret") -NoNewline -ForegroundColor White
        Write-Host ("{0,-86} " -f $KeystoreSecret) -NoNewline -ForegroundColor White
        Write-Host "║" -ForegroundColor Cyan

        Set-ItemProperty -Path $dsnPath -Name "KeystoreLocation" -Value $KeystoreLocation
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Location") -NoNewline -ForegroundColor White
        Write-Host ("{0,-86} " -f $KeystoreLocation) -NoNewline -ForegroundColor White
        Write-Host "║" -ForegroundColor Cyan

        Set-ItemProperty -Path $dsnPath -Name "LastUser" -Value $LastUser
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Último Usuário") -NoNewline -ForegroundColor White
        Write-Host ("{0,-86} " -f $LastUser) -NoNewline -ForegroundColor White
        Write-Host "║" -ForegroundColor Cyan

        Set-ItemProperty -Path $dsnPath -Name "Trusted_Connection" -Value $Trusted_Connection
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Conexão Confiável") -NoNewline -ForegroundColor White
        Write-Host ("{0,-86} " -f $Trusted_Connection) -NoNewline -ForegroundColor White
        Write-Host "║" -ForegroundColor Cyan
        
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "DSN") -NoNewline -ForegroundColor White
        Write-Host ("{0,-86} " -f "DSN '$NomeDSN' criado com sucesso.") -NoNewline -ForegroundColor Cyan
        Write-Host "║" -ForegroundColor Cyan
}

# Define a string de conexão
$connectionString = "Server=$Servidor;Database=$BancoDeDados;User Id=$Usuario;Password=$Senha;"

# Testa a conexão
Testar-Conexao -ConnectionString $connectionString

# Cria o DSN
$dsnDriver = "{SQL Server}"
Criar-DSN -NomeDSN $NomeDaConexao -Driver $dsnDriver -Servidor $Servidor -BancoDeDados $BancoDeDados -Usuario $Usuario -Senha $Senha -TipoDSN $TipoDSN
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