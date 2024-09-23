# Define as variáveis do alvo iSCSI
$TargetPortal = "192.168.1.100"   # Endereço IP do servidor iSCSI
$TargetIQN = "iqn.2023-09.local:storage.target01"   # IQN do alvo iSCSI
$Username = "admin"   # Se houver autenticação CHAP, insira o nome de usuário
$Password = "password" # Senha para autenticação CHAP

# Conectar-se ao Portal iSCSI
Write-Host "Conectando ao Portal iSCSI em $TargetPortal..." -ForegroundColor Cyan
New-IscsiTargetPortal -TargetPortalAddress $TargetPortal -InitiatorPortalAddress 0.0.0.0

# Recupera a lista de alvos iSCSI
Write-Host "Buscando alvos iSCSI disponíveis..." -ForegroundColor Cyan
$Targets = Get-IscsiTarget

# Exibe os alvos disponíveis
if ($Targets) {
    Write-Host "Alvos iSCSI encontrados:" -ForegroundColor Green
    $Targets | ForEach-Object { Write-Host " - $($_.TargetPortalAddress) : $($_.TargetIQN)" }
} else {
    Write-Host "Nenhum alvo iSCSI encontrado." -ForegroundColor Red
    exit
}

# Conectar-se ao alvo iSCSI específico
Write-Host "Conectando ao alvo iSCSI: $TargetIQN..." -ForegroundColor Cyan
Connect-IscsiTarget -NodeAddress $TargetIQN -IsPersistent $true

# Autenticação CHAP (opcional)
if ($Username -and $Password) {
    Write-Host "Autenticando com CHAP..." -ForegroundColor Cyan
    $ChapSecret = ConvertTo-SecureString -String $Password -AsPlainText -Force
    $ChapCredentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username, $ChapSecret
    Set-IscsiChapSecret -NodeAddress $TargetIQN -ChapCredentials $ChapCredentials
}

# Verifica a conexão
$ConnectedTargets = Get-IscsiSession | Where-Object { $_.TargetNodeAddress -eq $TargetIQN }
if ($ConnectedTargets) {
    Write-Host "Conexão estabelecida com sucesso ao alvo iSCSI: $TargetIQN" -ForegroundColor Green
} else {
    Write-Host "Falha ao conectar ao alvo iSCSI." -ForegroundColor Red
}
