<#
    Função: Criar Usuários no Windows
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

# Lista de usuários a serem criados
$usuarios = @(
    @{ Name = "Teste de Usuario 1"; Username = "teste1"; Password = "SenhaSegura123!"; Group = "Users"; Description = "Usuário de Teste 1" },
    @{ Name = "Teste de Usuario 2"; Username = "teste2"; Password = "SenhaSegura123!"; Group = "Administrators"; Description = "Usuário de Teste 2" },
    @{ Name = "Teste de Usuario 3"; Username = "teste3"; Password = "SenhaSegura123!"; Group = "Users"; Description = "Usuário de Teste de Script" },
    @{ Name = "Teste de Usuario 4"; Username = "teste4"; Password = "SenhaSegura123!"; Group = "Users"; Description = "Usuário de Teste 4" }
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
& $cabecalhoScriptPath -Script $scriptName -Titulo "Criar Usuários no Windows"
#----------------------------------------------------------------------------------------------

# Função para verificar e criar grupos se necessário
function VerificarOuCriarGrupo($grupo) {
    if (-not (Get-LocalGroup -Name $grupo -ErrorAction SilentlyContinue)) {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Criando Grupo") -NoNewline -ForegroundColor White
        Write-Host ("{0,-86} " -f $grupo) -NoNewline -ForegroundColor Green
        Write-Host "║" -ForegroundColor Cyan

        $null = New-LocalGroup -Name $grupo
    }
}

# Iniciar Ações
#----------------------------------------------------------------------------------------------
foreach ($usuario in $usuarios) {
    $nomeUsuario = $usuario.Username
    $senhaUsuario = $usuario.Password
    $grupoUsuario = $usuario.Group
    $descricaoUsuario = $usuario.Description

    # Verifica e cria o grupo se necessário
    VerificarOuCriarGrupo -grupo $grupoUsuario

    # Verifica se o usuário já existe
    if (-not (Get-LocalUser -Name $nomeUsuario -ErrorAction SilentlyContinue)) {
        # Cria o usuário
        $null = New-LocalUser -Name $nomeUsuario -Password (ConvertTo-SecureString $senhaUsuario -AsPlainText -Force) -FullName $usuario.Name -Description $usuario.Description -PasswordNeverExpires

        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Usuário Criado") -NoNewline -ForegroundColor White
        Write-Host ("{0,-86} " -f $($nomeUsuario +" - " +$grupoUsuario)) -NoNewline -ForegroundColor Green
        Write-Host "║" -ForegroundColor Cyan

        # Aguardar um momento para garantir que o sistema reconheça o usuário
        Start-Sleep -Seconds 2

        try {
            # Adiciona o usuário ao grupo especificado
            $null = Add-LocalGroupMember -Group $grupoUsuario -Member $nomeUsuario -ErrorAction Stop

            # Verifica se o usuário foi adicionado ao grupo
            $isMember = Get-LocalGroupMember -Group $grupoUsuario | Where-Object { $_.Name -eq $nomeUsuario }

            if ($isMember) {
                Write-Host "║" -NoNewline -ForegroundColor Cyan
                Write-Host ("{0,-30} : " -f "Adicionado ao Grupo") -NoNewline -ForegroundColor White
                Write-Host ("{0,-86} " -f $grupoUsuario) -NoNewline -ForegroundColor Green
                Write-Host "║" -ForegroundColor Cyan
            } else {
                Write-Host "║" -NoNewline -ForegroundColor Cyan
                Write-Host ("{0,-30} : " -f "Falha ao Adicionar ao Grupo") -NoNewline -ForegroundColor Yellow
                Write-Host ("{0,-86} " -f $grupoUsuario) -NoNewline -ForegroundColor Red
                Write-Host "║" -ForegroundColor Cyan
            }
        } catch {
            Write-Host "║" -NoNewline -ForegroundColor Cyan
            Write-Host ("{0,-30} : " -f "Erro ao Adicionar ao Grupo") -NoNewline -ForegroundColor Yellow
            Write-Host ("{0,-86} " -f $_.Exception.Message) -NoNewline -ForegroundColor Red
            Write-Host "║" -ForegroundColor Cyan
        }
    } else {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Usuário já existe") -NoNewline -ForegroundColor Yellow
        Write-Host ("{0,-86} " -f $nomeUsuario) -NoNewline -ForegroundColor Red
        Write-Host "║" -ForegroundColor Cyan
    }
}
#----------------------------------------------------------------------------------------------

# Rodapé
#----------------------------------------------------------------------------------------------
# Construir o caminho completo para o script 'scp_script_rodape.ps1'
$rodapeScriptPath = Join-Path -Path $scriptDirectory -ChildPath "scp_script_rodape.ps1"

# Executar o script de rodapé
& $rodapeScriptPath
#----------------------------------------------------------------------------------------------
