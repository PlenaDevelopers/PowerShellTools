<#
    Copyright: (c) Flex IT - 2026
    Function: Definir Compartilhamento Windows 11
    Description: Configura nome do computador, descoberta de rede, SMB2/SMB3,
               acesso SMB Guest e compartilhamento C:\transferencias.

    REFATORADO:
    - Nao presume que chaves/valores do Registro existam.
    - Pode ser executado varias vezes (idempotente).
    - Uma configuracao opcional que falhar nao interrompe todo o processo.
    - Valida existencia de servicos, cmdlets, regras de firewall e perfis de rede.
    - Configura tanto o cliente SMB quanto o servidor/compartilhamento local.
#>

[CmdletBinding()]
param(
    [string]$NomeComputador,
    [string]$Dominio = "flexit.local.net",
    [string]$Folder = "C:\transferencias",
    [string]$Compartilhamento = "transferencias",
    [bool]$PermitirCompartilhamentoSemSenha = $true
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
$script:Avisos = New-Object System.Collections.Generic.List[string]
$script:ReinicioNecessario = $false

function Initialize-PowerToolConsole {
    try {
        $baseDir = if ($PSScriptRoot) { $PSScriptRoot } else { $env:TEMP }
        $logDir = Join-Path -Path $baseDir -ChildPath 'logs'
        if (-not (Test-Path -LiteralPath $logDir)) {
            New-Item -Path $logDir -ItemType Directory -Force -ErrorAction Stop | Out-Null
        }
        $scriptName = if ($PSCommandPath) { [IO.Path]::GetFileNameWithoutExtension($PSCommandPath) } else { 'PowerTool' }
        $logPath = Join-Path -Path $logDir -ChildPath ("PowerTool_{0}_{1}_{2}.log" -f (Get-Date -Format 'yyyyMMdd_HHmmss'), $scriptName, $PID)
        Start-Transcript -Path $logPath -Force -ErrorAction Stop | Out-Null
        $global:PowerToolTranscriptActive = $true
    } catch {
        $global:PowerToolTranscriptActive = $false
    }
}

function Stop-PowerToolTranscript {
    try {
        if ($global:PowerToolTranscriptActive) { Stop-Transcript | Out-Null }
    } catch { }
}

function Get-PowerToolWidth {
    try { return [Math]::Min([Math]::Max(($Host.UI.RawUI.WindowSize.Width - 4), 96), 160) }
    catch { return 120 }
}

function Write-PowerToolBorder {
    param([string]$Left = '+', [string]$Right = '+', [string]$Color = 'Cyan')
    Write-Host ($Left + ('-' * (Get-PowerToolWidth)) + $Right) -ForegroundColor $Color
}

function Write-PowerToolLine {
    param([string]$Campo, [string]$Valor, [string]$CorValor = 'White')
    $w = (Get-PowerToolWidth) - 33
    if ($null -eq $Valor) { $Valor = '' }
    $t = [string]$Valor
    if ($t.Length -gt $w) { $t = $t.Substring(0, [Math]::Max(0, $w - 3)) + '...' }
    Write-Host ("|{0,-30} : {1}|" -f $Campo, $t.PadRight($w)) -ForegroundColor $CorValor
}

function Write-PowerToolHeader {
    param([string]$Script, [string]$Titulo)
    Initialize-PowerToolConsole
    Write-PowerToolBorder '+' '+' 'Yellow'
    Write-PowerToolLine 'Operation' $Titulo 'Yellow'
    Write-PowerToolLine 'Production' (Get-Date).Year 'Yellow'
    Write-PowerToolLine 'Copyright' 'Flex IT' 'Yellow'
    Write-PowerToolLine 'Script' $Script 'White'
    Write-PowerToolBorder '+' '+' 'Cyan'
}

function Write-PowerToolFooter {
    param([string]$Status = 'Finished')
    Write-PowerToolBorder '+' '+' 'Cyan'
    Write-PowerToolLine 'Process' $Status $(if ($Status -eq 'Finished') { 'Green' } else { 'Yellow' })
    Write-PowerToolBorder '+' '+' 'Yellow'
    Stop-PowerToolTranscript
}

function Add-WarningSafe {
    param([string]$Etapa, [string]$Mensagem)
    $texto = "$Etapa`: $Mensagem"
    $script:Avisos.Add($texto) | Out-Null
    Write-PowerToolLine $Etapa $Mensagem 'Yellow'
}

function Assert-Admin {
    $principal = [Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent())
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "Execute este script como Administrador."
    }
}

function Test-CommandAvailable {
    param([Parameter(Mandatory)][string]$Name)
    return [bool](Get-Command -Name $Name -ErrorAction SilentlyContinue)
}

function Ensure-RegistryKey {
    param([Parameter(Mandatory)][string]$Path)
    try {
        if (-not (Test-Path -LiteralPath $Path)) {
            New-Item -Path $Path -Force -ErrorAction Stop | Out-Null
        }
        return $true
    } catch {
        Add-WarningSafe "Registro" "Nao foi possivel criar/acessar $Path - $($_.Exception.Message)"
        return $false
    }
}

function Ensure-RegistryDword {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][int]$Value
    )

    if (-not (Ensure-RegistryKey -Path $Path)) { return $false }

    try {
        $atual = Get-ItemProperty -LiteralPath $Path -Name $Name -ErrorAction SilentlyContinue
        if ($null -eq $atual -or $atual.$Name -ne $Value) {
            New-ItemProperty -LiteralPath $Path -Name $Name -Value $Value -PropertyType DWord -Force -ErrorAction Stop | Out-Null
        }
        return $true
    } catch {
        Add-WarningSafe "Registro $Name" $_.Exception.Message
        return $false
    }
}

function Ensure-ServiceState {
    param(
        [Parameter(Mandatory)][string]$Name,
        [ValidateSet('Automatic','Manual')][string]$StartupType = 'Automatic',
        [bool]$Start = $true
    )

    $svc = Get-Service -Name $Name -ErrorAction SilentlyContinue
    if (-not $svc) {
        Add-WarningSafe "Servico $Name" "Servico nao existe nesta instalacao do Windows."
        return $false
    }

    try {
        Set-Service -Name $Name -StartupType $StartupType -ErrorAction Stop
        if ($Start) {
            $svc = Get-Service -Name $Name -ErrorAction Stop
            if ($svc.Status -ne 'Running') { Start-Service -Name $Name -ErrorAction Stop }
        }
        return $true
    } catch {
        Add-WarningSafe "Servico $Name" $_.Exception.Message
        return $false
    }
}

function Read-ValidHostName {
    do {
        $nome = if ($NomeComputador) { $NomeComputador } else { Read-Host "Nome do computador" }
        if ($null -eq $nome) { $nome = '' }
        $nome = $nome.Trim().ToLower()
        if ($nome -match '^[a-z0-9]([a-z0-9-]{0,13}[a-z0-9])?$' -or $nome -match '^[a-z0-9]$') {
            return $nome
        }
        Write-PowerToolLine "Nome invalido" "Use letras, numeros e hifen, ate 15 caracteres." "Red"
        $script:NomeComputador = $null
    } while ($true)
}

function Ensure-NetworkProfilesPrivate {
    if (-not (Test-CommandAvailable 'Get-NetConnectionProfile') -or -not (Test-CommandAvailable 'Set-NetConnectionProfile')) {
        Add-WarningSafe 'Perfil de rede' 'Cmdlets NetConnectionProfile nao estao disponiveis.'
        return
    }

    try {
        $perfis = @(Get-NetConnectionProfile -ErrorAction Stop)
        foreach ($perfil in $perfis) {
            if ($perfil.NetworkCategory -eq 'DomainAuthenticated') {
                Write-PowerToolLine "Perfil $($perfil.InterfaceAlias)" "Dominio autenticado - mantido" 'Green'
                continue
            }
            if ($perfil.NetworkCategory -ne 'Private') {
                try {
                    Set-NetConnectionProfile -InterfaceIndex $perfil.InterfaceIndex -NetworkCategory Private -ErrorAction Stop
                    Write-PowerToolLine "Perfil $($perfil.InterfaceAlias)" "Privado" 'Green'
                } catch {
                    Add-WarningSafe "Perfil $($perfil.InterfaceAlias)" $_.Exception.Message
                }
            }
        }
    } catch {
        Add-WarningSafe 'Perfil de rede' $_.Exception.Message
    }
}

function Enable-FirewallRulesSafe {
    $grupos = @('File and Printer Sharing', 'Network Discovery')
    foreach ($grupo in $grupos) {
        try {
            $regras = @(Get-NetFirewallRule -ErrorAction Stop | Where-Object { $_.DisplayGroup -eq $grupo })
            if ($regras.Count -gt 0) {
                $regras | Enable-NetFirewallRule -ErrorAction Stop
            }
        } catch {
            # Em Windows PT-BR os DisplayGroup podem estar traduzidos. Tenta grupos pelo nome interno.
        }
    }

    # Alternativa independente do idioma: habilita regras conhecidas pelos grupos internos.
    foreach ($prefixo in @('FPS-', 'NETDIS-')) {
        try {
            $regras = @(Get-NetFirewallRule -ErrorAction Stop | Where-Object { $_.Name -like "$prefixo*" })
            if ($regras.Count -gt 0) { $regras | Enable-NetFirewallRule -ErrorAction Stop }
        } catch {
            Add-WarningSafe 'Firewall' $_.Exception.Message
        }
    }
}

function Grant-ShareAccessCompat {
    param([string]$Name, [string]$AccountName)

    foreach ($account in @($AccountName, 'Everyone', 'Everyone')) {
        if ([string]::IsNullOrWhiteSpace($account)) { continue }
        try {
            Grant-SmbShareAccess -Name $Name -AccountName $account -AccessRight Full -Force -ErrorAction Stop | Out-Null
            return $true
        } catch { }
    }

    Add-WarningSafe 'Permission SMB' 'Failure ao conceder Everyone/Everyone automaticamente.'
    return $false
}

function Enable-SmbGuestAccess {
    if (-not $PermitirCompartilhamentoSemSenha) { return 'desativado' }

    Write-PowerToolLine 'SMB guest' 'Configurando cliente e servidor para acesso sem senha' 'Yellow'

    # Politicas de cliente Guest. Criamos explicitamente chave e valor caso nao existam.
    Ensure-RegistryDword 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation' 'AllowInsecureGuestAuth' 1 | Out-Null
    Ensure-RegistryDword 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters' 'AllowInsecureGuestAuth' 1 | Out-Null

    # ForceGuest: usuarios de rede locais sao tratados como Guest quando aplicavel.
    Ensure-RegistryDword 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' 'forceguest' 1 | Out-Null

    # Permite contas locais sem senha somente para o cenario de compartilhamento solicitado.
    Ensure-RegistryDword 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' 'LimitBlankPasswordUse' 0 | Out-Null

    if (Test-CommandAvailable 'Set-SmbClientConfiguration') {
        try {
            Set-SmbClientConfiguration -EnableInsecureGuestLogons $true -Force -ErrorAction Stop | Out-Null
        } catch { Add-WarningSafe 'SMB Guest cliente' $_.Exception.Message }

        # Guest SMB nao funciona com exigencia obrigatoria de assinatura.
        try {
            Set-SmbClientConfiguration -RequireSecuritySignature $false -Force -ErrorAction Stop | Out-Null
        } catch { Add-WarningSafe 'Assinatura SMB cliente' $_.Exception.Message }

        # Nem todas as builds possuem o parametro RequireEncryption.
        try {
            $cmd = Get-Command Set-SmbClientConfiguration -ErrorAction Stop
            if ($cmd.Parameters.ContainsKey('RequireEncryption')) {
                Set-SmbClientConfiguration -RequireEncryption $false -Force -ErrorAction Stop | Out-Null
            }
        } catch { Add-WarningSafe 'Criptografia SMB cliente' $_.Exception.Message }
    } else {
        Add-WarningSafe 'SMB cliente' 'Set-SmbClientConfiguration nao esta disponivel.'
    }

    if (Test-CommandAvailable 'Set-SmbServerConfiguration') {
        try {
            Set-SmbServerConfiguration -EnableSMB2Protocol $true -Force -ErrorAction Stop | Out-Null
        } catch { Add-WarningSafe 'SMB2 servidor' $_.Exception.Message }

        # Algumas versoes do Windows expoem esta opcao, outras nao.
        try {
            $cmd = Get-Command Set-SmbServerConfiguration -ErrorAction Stop
            if ($cmd.Parameters.ContainsKey('EnableAuthenticateUserSharing')) {
                Set-SmbServerConfiguration -EnableAuthenticateUserSharing $false -Force -ErrorAction Stop | Out-Null
            }
        } catch { Add-WarningSafe 'Compartilhamento autenticado' $_.Exception.Message }
    }

    # Reiniciar workstation pode falhar se houver conexoes SMB ativas; nao aborta o script.
    try {
        Restart-Service -Name LanmanWorkstation -Force -ErrorAction Stop
    } catch {
        Add-WarningSafe 'LanmanWorkstation' "Configuracao aplicada; reinicio do servico nao foi possivel. Reinicie o Windows."
        $script:ReinicioNecessario = $true
    }

    return 'guest SMB permitido'
}

function Ensure-TransferFolder {
    param([string]$Path)

    try {
        if (-not (Test-Path -LiteralPath $Path)) {
            New-Item -ItemType Directory -Path $Path -Force -ErrorAction Stop | Out-Null
        }
        if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
            throw "O caminho existe, mas nao e uma pasta: $Path"
        }
    } catch {
        throw "Nao foi possivel preparar a pasta $Path. $($_.Exception.Message)"
    }
}

function Ensure-NtfsEveryoneModify {
    param([string]$Path)

    try {
        $sidEveryone = New-Object Security.Principal.SecurityIdentifier 'S-1-1-0'
        $contaEveryone = $sidEveryone.Translate([Security.Principal.NTAccount]).Value
        $acl = Get-Acl -LiteralPath $Path -ErrorAction Stop
        $rule = New-Object Security.AccessControl.FileSystemAccessRule(
            $contaEveryone,
            'Modify',
            'ContainerInherit,ObjectInherit',
            'None',
            'Allow'
        )
        $acl.SetAccessRule($rule)
        Set-Acl -LiteralPath $Path -AclObject $acl -ErrorAction Stop
        Write-PowerToolLine 'Permissions NTFS' "$contaEveryone = Modify" 'Green'
        return $contaEveryone
    } catch {
        throw "Failure ao configurar permissoes NTFS em $Path. $($_.Exception.Message)"
    }
}

function Ensure-SmbShareSafe {
    param(
        [string]$Name,
        [string]$Path,
        [string]$Description,
        [string]$EveryoneAccount
    )

    if (-not (Test-CommandAvailable 'Get-SmbShare')) {
        throw 'Os cmdlets SMB nao estao disponiveis nesta instalacao do Windows.'
    }

    $share = Get-SmbShare -Name $Name -ErrorAction SilentlyContinue

    if ($share -and ([IO.Path]::GetFullPath($share.Path).TrimEnd('\') -ne [IO.Path]::GetFullPath($Path).TrimEnd('\'))) {
        try {
            Remove-SmbShare -Name $Name -Force -ErrorAction Stop
            $share = $null
        } catch {
            throw "O compartilhamento '$Name' existe apontando para '$($share.Path)' e nao pode ser substituido. $($_.Exception.Message)"
        }
    }

    if (-not $share) {
        try {
            New-SmbShare -Name $Name -Path $Path -Description $Description -FullAccess $EveryoneAccount -ErrorAction Stop | Out-Null
        } catch {
            # Tenta criar sem FullAccess e concede depois para lidar melhor com localizacao da conta.
            try {
                New-SmbShare -Name $Name -Path $Path -Description $Description -ErrorAction Stop | Out-Null
            } catch {
                throw "Failure ao criar compartilhamento '$Name'. $($_.Exception.Message)"
            }
        }
    } else {
        try { Set-SmbShare -Name $Name -Description $Description -Force -ErrorAction Stop | Out-Null }
        catch { Add-WarningSafe 'Descricao SMB' $_.Exception.Message }
    }

    Grant-ShareAccessCompat -Name $Name -AccountName $EveryoneAccount | Out-Null
}

function Get-PreferredIPv4 {
    try {
        $ips = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction Stop |
            Where-Object {
                $_.IPAddress -ne '127.0.0.1' -and
                $_.IPAddress -notlike '169.254.*' -and
                $_.AddressState -eq 'Preferred'
            } |
            Sort-Object -Property InterfaceMetric, SkipAsSource

        return ($ips | Select-Object -First 1 -ExpandProperty IPAddress)
    } catch {
        return $null
    }
}

try {
    Assert-Admin

    $scriptFile = if ($PSCommandPath) { [IO.Path]::GetFileName($PSCommandPath) } else { 'Powershell' }
    Write-PowerToolHeader -Script $scriptFile -Titulo 'Definir Compartilhamento Windows 11'

    $hostCurto = Read-ValidHostName

    if ($null -eq $Dominio) { $Dominio = '' }
    $Dominio = $Dominio.Trim().Trim('.').ToLower()
    if ($Dominio -and $Dominio -notmatch '^([a-z0-9]([a-z0-9-]*[a-z0-9])?\.)+[a-z0-9]([a-z0-9-]*[a-z0-9])?$') {
        throw "Dominio invalido: $Dominio"
    }

    $fqdn = if ($Dominio) { "$hostCurto.$Dominio" } else { $hostCurto }

    Write-PowerToolLine 'Computador' $hostCurto 'Yellow'
    Write-PowerToolLine 'FQDN' $fqdn 'Yellow'
    Write-PowerToolLine 'Folder' $Folder 'Yellow'

    # Renomeia somente se necessario.
    if ($env:COMPUTERNAME.ToLower() -ne $hostCurto) {
        try {
            Rename-Computer -NewName $hostCurto -Force -ErrorAction Stop
            Write-PowerToolLine 'Nome' 'Alteracao pendente de reinicio' 'Yellow'
            $script:ReinicioNecessario = $true
        } catch {
            Add-WarningSafe 'Nome do computador' $_.Exception.Message
        }
    } else {
        Write-PowerToolLine 'Nome' 'Ja esta correto' 'Green'
    }

    Ensure-TransferFolder -Path $Folder
    $contaEveryone = Ensure-NtfsEveryoneModify -Path $Folder

    # Servicos fundamentais.
    if (-not (Ensure-ServiceState -Name 'LanmanServer' -StartupType Automatic -Start $true)) {
        throw 'O servico LanmanServer e necessario para compartilhar arquivos.'
    }

    foreach ($svc in @('FDResPub', 'fdPHost', 'SSDPSRV', 'upnphost')) {
        Ensure-ServiceState -Name $svc -StartupType Automatic -Start $true | Out-Null
    }

    Ensure-NetworkProfilesPrivate
    Enable-FirewallRulesSafe

    # SMB2/3. SMB1 NAO e habilitado.
    if (Test-CommandAvailable 'Set-SmbServerConfiguration') {
        try {
            Set-SmbServerConfiguration -EnableSMB2Protocol $true -Force -ErrorAction Stop | Out-Null
            Write-PowerToolLine 'SMB2/SMB3' 'Habilitado' 'Green'
        } catch {
            Add-WarningSafe 'SMB2/SMB3' $_.Exception.Message
        }
    }

    $smbGuestStatus = Enable-SmbGuestAccess

    Ensure-SmbShareSafe -Name $Compartilhamento -Path $Folder -Description "Transferencias - $hostCurto" -EveryoneAccount $contaEveryone

    $ip = Get-PreferredIPv4

    Write-PowerToolLine 'SMB guest' $smbGuestStatus 'Green'
    if ($ip) { Write-PowerToolLine 'Access por IP' "\\$ip\$Compartilhamento" 'Green' }
    Write-PowerToolLine 'Access por nome' "\\$hostCurto\$Compartilhamento" 'Green'

    if ($script:Avisos.Count -gt 0) {
        Write-PowerToolLine 'Avisos' "$($script:Avisos.Count) etapa(s) nao critica(s) exigem verificacao; consulte o log." 'Yellow'
    } else {
        Write-PowerToolLine 'Validacao' 'Todas as etapas concluidas sem avisos.' 'Green'
    }

    if ($script:ReinicioNecessario) {
        Write-PowerToolLine 'Reinicio' 'Reinicie o Windows para concluir todas as alteracoes.' 'Yellow'
    } else {
        Write-PowerToolLine 'Reinicio' 'Nao obrigatorio; recomendado se o Guest ainda nao responder.' 'Yellow'
    }

    Write-PowerToolFooter -Status 'Finished'
    exit 0
}
catch {
    try {
        Write-PowerToolLine 'Erro fatal' $_.Exception.Message 'Red'
        Write-PowerToolFooter -Status 'Falhou'
    } catch {
        Write-Error $_.Exception.Message
        Stop-PowerToolTranscript
    }
    exit 1
}
