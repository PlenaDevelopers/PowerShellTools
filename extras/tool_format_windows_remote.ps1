<#
    Copyright: (c) Flex IT - 2026
    Function: Preparar Formatacao Remota do Windows
    Description: Prepara formatacao remota via AnyDesk a partir de uma ISO local. O script cria uma particao WINSETUP no disco interno, copia os arquivos da ISO para essa particao e agenda o boot no Windows Setup.

    ATENCAO:
    Este script e destrutivo. A instalacao preparada formata a particao alvo, normalmente C:.
    Execute somente em computadores que voce administra e com backup validado.
    Depois do reinicio, o AnyDesk sera desconectado. O retorno remoto depende do Windows instalado,
    drivers de rede e instalacao posterior do agente remoto.

    Como funciona:
    1. Reduz a particao C:.
    2. Cria uma particao NTFS chamada WINSETUP.
    3. Monta a ISO apenas para copiar seus arquivos para WINSETUP.
    4. Gera autounattend.xml na WINSETUP para formatar C: e instalar o Windows.
    5. Cria uma entrada temporaria no BCD para iniciar o boot.wim da WINSETUP.
    6. Agenda reinicio automatico em 60 segundos com shutdown /r para iniciar a instalacao.
    Se BitLocker estiver ativo na particao alvo, a criptografia e desativada automaticamente
    e o script aguarda a unidade ficar totalmente descriptografada antes de alterar o boot.
    Use -NaoSuspenderBitLocker apenas se quiser bloquear esse comportamento.

    Exemplo seguro, apenas preparar sem reiniciar:
    powershell -ExecutionPolicy Bypass -File .\formatacao_windows_remota.ps1 -IsoPath "C:\ISOS\Windows.iso" -ConfirmarFormatacao FORMATAR -NaoReiniciar

    Exemplo preparar e reiniciar automaticamente:
    powershell -ExecutionPolicy Bypass -File .\formatacao_windows_remota.ps1 -IsoPath "C:\ISOS\Windows.iso" -ConfirmarFormatacao FORMATAR
#>

[CmdletBinding()]
param(
    [string]$IsoPath = "",

    [ValidatePattern('^[A-Z]$')]
    [string]$ParticaoAlvo = "C",

    [ValidateRange(8, 64)]
    [int]$TamanhoParticaoSetupGB = 14,

    [ValidateRange(1, 50)]
    [int]$ImageIndex = 1,

    [string]$NomeComputador = "",

    [string]$UsuarioLocal = "suporte",

    [securestring]$SenhaUsuarioLocal,

    [string]$ProductKey = "",

    [ValidateSet("pt_br", "en_us", "es-ES")]
    [string]$Idioma = "pt_br",

    [ValidateSet("E. South America Standard Time", "UTC", "Pacific Standard Time")]
    [string]$FusoHorario = "E. South America Standard Time",

    [Parameter(Mandatory = $true)]
    [ValidateSet("FORMATAR")]
    [string]$ConfirmarFormatacao,

    [switch]$Reiniciar,

    [switch]$NaoReiniciar,

    [switch]$NaoSuspenderBitLocker,

    [switch]$IgnorarBitLocker
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
$ScriptVersao = "1.0"
$RotuloSetup = "WINSETUP"
$NomeEntradaBoot = "FlexIT_Windows_Setup_Autonomo"
$Log = "C:\flexit-formatacao-remota.log"
$TranscriptAtivo = $false

function Write-Banner {
    Clear-Host
    Write-Host "==============================================================" -ForegroundColor Magenta
    Write-Host " FLEXIT FORMATACAO REMOTA" -ForegroundColor White
    Write-Host " Formatacao remota via AnyDesk usando particao WINSETUP" -ForegroundColor Cyan
    Write-Host " Versao $ScriptVersao" -ForegroundColor Blue
    Write-Host "==============================================================" -ForegroundColor Magenta
    Write-Host ""
}

function Info($Mensagem) { Write-Host "[INFO] $Mensagem" -ForegroundColor Cyan }
function Ok($Mensagem) { Write-Host "[ OK ] $Mensagem" -ForegroundColor Green }
function Aviso($Mensagem) { Write-Host "[AVISO] $Mensagem" -ForegroundColor Yellow }

function Assert-Admin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "Execute este script em um Powershell aberto como Administrador."
    }
}

function Select-IsoPath {
    param([string]$RequestedPath)

    if (-not [string]::IsNullOrWhiteSpace($RequestedPath)) {
        if (-not (Test-Path -LiteralPath $RequestedPath -PathType Leaf)) {
            throw "ISO nao encontrada: $RequestedPath"
        }
        return (Resolve-Path -LiteralPath $RequestedPath).Path
    }

    $baseDir = $PSScriptRoot
    if ([string]::IsNullOrWhiteSpace($baseDir)) {
        if ($PSCommandPath) { $baseDir = Split-Path -Parent $PSCommandPath }
        elseif ($MyInvocation.MyCommand.Path) { $baseDir = Split-Path -Parent $MyInvocation.MyCommand.Path }
        else { $baseDir = (Get-Location).Path }
    }

    $isos = @(Get-ChildItem -LiteralPath $baseDir -Filter "*.iso" -File -ErrorAction SilentlyContinue | Sort-Object Name)
    if ($isos.Count -eq 0) {
        throw "Nenhuma ISO encontrada na pasta do script: $baseDir"
    }

    Write-Host ""
    Write-Host "ISOs encontradas em $baseDir" -ForegroundColor Cyan
    for ($i = 0; $i -lt $isos.Count; $i++) {
        $tamanhoGB = [math]::Round($isos[$i].Length / 1GB, 2)
        Write-Host ("  {0}. {1} ({2} GB)" -f ($i + 1), $isos[$i].Name, $tamanhoGB) -ForegroundColor White
    }

    do {
        $opcao = Read-Host "Escolha a ISO pelo numero"
        $indice = 0
        if ([int]::TryParse($opcao, [ref]$indice) -and $indice -ge 1 -and $indice -le $isos.Count) {
            return $isos[$indice - 1].FullName
        }
        Aviso "Opcao invalida."
    } while ($true)
}

function ConvertTo-PlainText {
    param([securestring]$SecureValue)
    if (-not $SecureValue) { return "" }
    $ptr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureValue)
    try {
        return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)
    } finally {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)
    }
}

function Invoke-CheckedProcess {
    param(
        [Parameter(Mandatory = $true)][string]$FilePath,
        [Parameter(Mandatory = $true)][string[]]$ArgumentList
    )

    $processo = Start-Process -FilePath $FilePath -ArgumentList $ArgumentList -Wait -PassThru -NoNewWindow
    if ($processo.ExitCode -ne 0) {
        throw "$FilePath retornou codigo $($processo.ExitCode). Argumentos: $($ArgumentList -join ' ')"
    }
}

function Invoke-RobocopyChecked {
    param([string[]]$ArgumentList)
    $processo = Start-Process -FilePath "robocopy.exe" -ArgumentList $ArgumentList -Wait -PassThru -NoNewWindow
    if ($processo.ExitCode -gt 7) {
        throw "robocopy retornou codigo $($processo.ExitCode). Argumentos: $($ArgumentList -join ' ')"
    }
}

function Clear-BitLockerExternalKeys {
    param([string]$MountPoint)

    if (-not (Get-Command manage-bde.exe -ErrorAction SilentlyContinue)) { return $false }

    $mountPoints = @($MountPoint)
    if (Get-Command Get-BitLockerVolume -ErrorAction SilentlyContinue) {
        $mountPoints += @(Get-BitLockerVolume -ErrorAction SilentlyContinue | Where-Object { $_.MountPoint } | ForEach-Object { $_.MountPoint })
    }
    $mountPoints = @($mountPoints | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique)

    $algumaLimpeza = $false
    foreach ($volumePath in $mountPoints) {
        try {
            Aviso "Limpando chaves externas de auto-unlock armazenadas em $volumePath."
            Invoke-CheckedProcess -FilePath "manage-bde.exe" -ArgumentList @("-autounlock", "-ClearAllKeys", $volumePath)
            Ok "Chaves externas de auto-unlock removidas de $volumePath."
            $algumaLimpeza = $true
        } catch {
            Aviso "Nao foi possivel limpar chaves externas em ${volumePath}: $($_.Exception.Message)"
        }
    }
    return $algumaLimpeza
}

function Disable-BitLockerDataAutoUnlock {
    param([string]$OperatingSystemMountPoint)

    if (-not (Get-Command Get-BitLockerVolume -ErrorAction SilentlyContinue)) { return }

    $volumesDados = @(Get-BitLockerVolume -ErrorAction SilentlyContinue | Where-Object {
        $_.MountPoint -and
        $_.MountPoint -ne $OperatingSystemMountPoint -and
        $_.VolumeType -ne "OperatingSystem"
    })

    foreach ($volumeDados in $volumesDados) {
        if (Get-Command Disable-BitLockerAutoUnlock -ErrorAction SilentlyContinue) {
            try {
                Aviso "Desabilitando auto-unlock no volume de dados $($volumeDados.MountPoint)."
                Disable-BitLockerAutoUnlock -MountPoint $volumeDados.MountPoint -ErrorAction Stop | Out-Null
            } catch {
                Aviso "Nao foi possivel desabilitar auto-unlock via cmdlet em $($volumeDados.MountPoint): $($_.Exception.Message)"
            }
        }

        if (Get-Command manage-bde.exe -ErrorAction SilentlyContinue) {
            try {
                Invoke-CheckedProcess -FilePath "manage-bde.exe" -ArgumentList @("-autounlock", "-disable", $volumeDados.MountPoint)
            } catch {
                Aviso "Nao foi possivel desabilitar auto-unlock via manage-bde em $($volumeDados.MountPoint): $($_.Exception.Message)"
            }
        }
    }
}

function Get-FirmwareBootLoaderPath {
    $firmware = (Get-ComputerInfo -Property BiosFirmwareType).BiosFirmwareType
    if ($firmware -eq "Uefi") { return "\windows\system32\boot\winload.efi" }
    return "\windows\system32\boot\winload.exe"
}

function Disable-BitLockerForSetup {
    param([string]$MountPoint)
    if (-not (Get-Command Get-BitLockerVolume -ErrorAction SilentlyContinue)) { return }
    $volume = Get-BitLockerVolume -MountPoint $MountPoint -ErrorAction SilentlyContinue
    if (-not $volume -or $IgnorarBitLocker) { return }

    if ($volume.VolumeStatus -eq "FullyDecrypted") {
        Ok "BitLocker ja esta descriptografado em $MountPoint."
        return
    }

    if ($volume.ProtectionStatus -eq "On" -or $volume.VolumeStatus -ne "FullyDecrypted") {
        if ($NaoSuspenderBitLocker) {
            throw "BitLocker esta ativo em $MountPoint. Remova -NaoSuspenderBitLocker ou desative/descriptografe manualmente antes de continuar."
        }

        Aviso "BitLocker ativo em $MountPoint. Desativando criptografia antes de alterar o boot."
        $desativacaoIniciada = $false
        Disable-BitLockerDataAutoUnlock -OperatingSystemMountPoint $MountPoint
        Clear-BitLockerExternalKeys -MountPoint $MountPoint

        if (Get-Command Disable-BitLocker -ErrorAction SilentlyContinue) {
            try {
                Disable-BitLocker -MountPoint $MountPoint -ErrorAction Stop | Out-Null
                $desativacaoIniciada = $true
            } catch {
                Aviso "Disable-BitLocker falhou: $($_.Exception.Message)"
                Disable-BitLockerDataAutoUnlock -OperatingSystemMountPoint $MountPoint
                Clear-BitLockerExternalKeys -MountPoint $MountPoint
                try {
                    Disable-BitLocker -MountPoint $MountPoint -ErrorAction Stop | Out-Null
                    $desativacaoIniciada = $true
                } catch {
                    Aviso "Disable-BitLocker apos limpar chaves externas falhou: $($_.Exception.Message)"
                }
            }
        }

        if (-not $desativacaoIniciada -and (Get-Command manage-bde.exe -ErrorAction SilentlyContinue)) {
            try {
                Disable-BitLockerDataAutoUnlock -OperatingSystemMountPoint $MountPoint
                Clear-BitLockerExternalKeys -MountPoint $MountPoint
                Invoke-CheckedProcess -FilePath "manage-bde.exe" -ArgumentList @("-off", $MountPoint)
                $desativacaoIniciada = $true
            } catch {
                Aviso "manage-bde -off falhou: $($_.Exception.Message)"
            }
        }

        if (-not $desativacaoIniciada) {
            throw "Nao foi possivel iniciar a desativacao do BitLocker em $MountPoint. Verifique unidades de dados com auto-unlock desabilitado ou desative manualmente pelo Painel de Controle."
        }

        $ultimaPorcentagem = $null
        $leiturasSemMudanca = 0
        do {
            Start-Sleep -Seconds 15
            $volume = Get-BitLockerVolume -MountPoint $MountPoint -ErrorAction SilentlyContinue
            $percentual = 0
            if ($null -ne $volume.EncryptionPercentage) { $percentual = [int]$volume.EncryptionPercentage }
            Info "BitLocker: status=$($volume.VolumeStatus), criptografado=$percentual%"
            if ($ultimaPorcentagem -ne $null -and $percentual -eq $ultimaPorcentagem -and $volume.VolumeStatus -ne "DecryptionInProgress") {
                $leiturasSemMudanca++
            } else {
                $leiturasSemMudanca = 0
            }
            $ultimaPorcentagem = $percentual
            if ($leiturasSemMudanca -ge 4) {
                throw "A descriptografia do BitLocker nao iniciou ou ficou parada. Status=$($volume.VolumeStatus), criptografado=$percentual%."
            }
        } while ($volume -and $volume.VolumeStatus -ne "FullyDecrypted")

        if (-not $volume -or $volume.VolumeStatus -ne "FullyDecrypted") {
            throw "Nao foi possivel confirmar descriptografia completa de $MountPoint."
        }

        Ok "BitLocker desativado e unidade descriptografada em $MountPoint."
    }
}

function New-UnattendXml {
    param(
        [int]$DiskNumber,
        [int]$PartitionNumber,
        [string]$ComputerName,
        [string]$LocalUser,
        [string]$LocalPassword,
        [string]$Key,
        [string]$Path
    )

    $productKeyXml = ""
    if (-not [string]::IsNullOrWhiteSpace($Key)) {
        $Key = $Key.Trim()
        if ($Key -notmatch '^[A-Za-z0-9]{5}(-[A-Za-z0-9]{5}){4}$') {
            throw "ProductKey invalida. Use o formato XXXXX-XXXXX-XXXXX-XXXXX-XXXXX ou deixe em branco."
        }
        $keyXml = [System.Security.SecurityElement]::Escape($Key)
        $productKeyXml = @"
                <ProductKey>
                    <Key>$keyXml</Key>
                </ProductKey>
"@
    }

    $xml = @"
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="windowsPE">
        <component name="Microsoft-Windows-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <DiskConfiguration>
                <Disk wcm:action="add">
                    <DiskID>$DiskNumber</DiskID>
                    <WillWipeDisk>false</WillWipeDisk>
                    <ModifyPartitions>
                        <ModifyPartition wcm:action="add">
                            <Order>1</Order>
                            <PartitionID>$PartitionNumber</PartitionID>
                            <Format>NTFS</Format>
                            <Label>Windows</Label>
                        </ModifyPartition>
                    </ModifyPartitions>
                </Disk>
                <WillShowUI>OnError</WillShowUI>
            </DiskConfiguration>
            <ImageInstall>
                <OSImage>
                    <InstallFrom>
                        <MetaData wcm:action="add">
                            <Key>/IMAGE/INDEX</Key>
                            <Value>$ImageIndex</Value>
                        </MetaData>
                    </InstallFrom>
                    <InstallTo>
                        <DiskID>$DiskNumber</DiskID>
                        <PartitionID>$PartitionNumber</PartitionID>
                    </InstallTo>
                    <WillShowUI>OnError</WillShowUI>
                </OSImage>
            </ImageInstall>
            <UserData>
                <AcceptEula>true</AcceptEula>
$productKeyXml
            </UserData>
        </component>
    </settings>
</unattend>
"@

    Set-Content -LiteralPath $Path -Value $xml -Encoding UTF8 -Force
}

function New-WindowsSetupBootEntry {
    param([string]$SetupDriveLetter)

    $setupDrive = "$SetupDriveLetter`:"
    $bootSdi = "$setupDrive\boot\boot.sdi"
    $bootWim = "$setupDrive\sources\boot.wim"
    if (-not (Test-Path -LiteralPath $bootSdi)) { throw "Arquivo nao encontrado: $bootSdi" }
    if (-not (Test-Path -LiteralPath $bootWim)) { throw "Arquivo nao encontrado: $bootWim" }

    $loaderPath = Get-FirmwareBootLoaderPath
    $ramdiskCreate = Start-Process -FilePath "bcdedit.exe" -ArgumentList @("/create", "{ramdiskoptions}", "/d", "FlexIT_Ramdisk_Options") -Wait -PassThru -NoNewWindow
    if ($ramdiskCreate.ExitCode -ne 0) {
        Aviso "A entrada {ramdiskoptions} ja pode existir. Tentando reaproveitar."
    }
    Invoke-CheckedProcess -FilePath "bcdedit.exe" -ArgumentList @("/set", "{ramdiskoptions}", "ramdisksdidevice", "partition=$setupDrive")
    Invoke-CheckedProcess -FilePath "bcdedit.exe" -ArgumentList @("/set", "{ramdiskoptions}", "ramdisksdipath", "\boot\boot.sdi")

    $saida = & bcdedit.exe /create /d $NomeEntradaBoot /application osloader
    if ($LASTEXITCODE -ne 0) { throw "Failure ao criar entrada BCD para Windows Setup." }
    $guid = (($saida | Select-String -Pattern '\{[0-9a-fA-F-]+\}' | Select-Object -First 1).Matches.Value)
    if ([string]::IsNullOrWhiteSpace($guid)) { throw "Nao foi possivel identificar o GUID da entrada BCD criada." }

    Invoke-CheckedProcess -FilePath "bcdedit.exe" -ArgumentList @("/set", $guid, "device", "ramdisk=[$setupDrive]\sources\boot.wim,{ramdiskoptions}")
    Invoke-CheckedProcess -FilePath "bcdedit.exe" -ArgumentList @("/set", $guid, "osdevice", "ramdisk=[$setupDrive]\sources\boot.wim,{ramdiskoptions}")
    Invoke-CheckedProcess -FilePath "bcdedit.exe" -ArgumentList @("/set", $guid, "path", $loaderPath)
    Invoke-CheckedProcess -FilePath "bcdedit.exe" -ArgumentList @("/set", $guid, "systemroot", "\windows")
    Invoke-CheckedProcess -FilePath "bcdedit.exe" -ArgumentList @("/set", $guid, "winpe", "yes")
    Invoke-CheckedProcess -FilePath "bcdedit.exe" -ArgumentList @("/set", $guid, "detecthal", "yes")
    Invoke-CheckedProcess -FilePath "bcdedit.exe" -ArgumentList @("/displayorder", $guid, "/addfirst")
    Invoke-CheckedProcess -FilePath "bcdedit.exe" -ArgumentList @("/bootsequence", $guid)
    return $guid
}

try {
    Assert-Admin
    Start-Transcript -Path $Log -Append | Out-Null
    $TranscriptAtivo = $true
    Write-Banner

    $targetLetter = $ParticaoAlvo.ToUpperInvariant()
    $targetMount = "$targetLetter`:"
    $isoCompleta = Select-IsoPath -RequestedPath $IsoPath

    Info "ISO selecionada       : $isoCompleta"
    Info "Particao alvo         : $targetMount"
    Info "Confirmacao recebida  : $ConfirmarFormatacao"
    Aviso "A particao $targetMount sera formatada pelo Windows Setup apos o reboot."
    if (-not $SenhaUsuarioLocal) {
        Aviso "SenhaUsuarioLocal nao informada. A instalacao pode parar na criacao de usuario/OOBE."
    }

    Disable-BitLockerForSetup -MountPoint $targetMount

    $targetPartition = Get-Partition -DriveLetter $targetLetter
    $targetVolume = Get-Volume -DriveLetter $targetLetter
    $disk = Get-Disk -Number $targetPartition.DiskNumber
    if ($disk.IsBoot -eq $false -and $disk.IsSystem -eq $false) {
        Aviso "O disco $($disk.Number) nao foi marcado como boot/system. Confira se esta e a unidade correta."
    }

    $setupBytes = [int64]$TamanhoParticaoSetupGB * 1GB
    $supported = Get-PartitionSupportedSize -DiskNumber $targetPartition.DiskNumber -PartitionNumber $targetPartition.PartitionNumber
    $newTargetSize = $targetPartition.Size - $setupBytes
    if ($newTargetSize -lt $supported.SizeMin) {
        throw "Nao ha espaco suficiente para reduzir $targetMount em $TamanhoParticaoSetupGB GB. Minimo suportado: $([math]::Round($supported.SizeMin / 1GB, 2)) GB."
    }
    if ($targetVolume.SizeRemaining -lt ($setupBytes + 2GB)) {
        Aviso "Espaco livre em $targetMount pode ser insuficiente para staging rapido. O redimensionamento ainda sera tentado."
    }

    Info "Reduzindo $targetMount em $TamanhoParticaoSetupGB GB..."
    Resize-Partition -DiskNumber $targetPartition.DiskNumber -PartitionNumber $targetPartition.PartitionNumber -Size $newTargetSize
    Ok "Particao alvo reduzida."

    Info "Criando particao $RotuloSetup..."
    $setupPartition = New-Partition -DiskNumber $targetPartition.DiskNumber -Size $setupBytes -AssignDriveLetter
    Format-Volume -Partition $setupPartition -FileSystem NTFS -NewFileSystemLabel $RotuloSetup -Confirm:$false | Out-Null
    $setupDriveLetter = (Get-Partition -DiskNumber $setupPartition.DiskNumber -PartitionNumber $setupPartition.PartitionNumber).DriveLetter
    $setupRoot = "$setupDriveLetter`:\"
    Ok "Particao criada em $setupRoot"

    Info "Montando ISO..."
    $image = Mount-DiskImage -ImagePath $isoCompleta -PassThru
    try {
        $isoDriveLetter = ($image | Get-Volume).DriveLetter
        if (-not $isoDriveLetter) { throw "Nao foi possivel identificar a letra da ISO montada." }
        $isoRoot = "$isoDriveLetter`:\"
        if (-not (Test-Path -LiteralPath "$isoRoot\setup.exe")) { throw "A ISO nao contem setup.exe na raiz." }
        if (-not (Test-Path -LiteralPath "$isoRoot\sources\boot.wim")) { throw "A ISO nao contem sources\boot.wim." }

        Info "Copiando arquivos da ISO para $setupRoot..."
        Invoke-RobocopyChecked -ArgumentList @($isoRoot, $setupRoot, "/MIR", "/R:2", "/W:2", "/NFL", "/NDL")
        Ok "Arquivos de instalacao copiados."
    } finally {
        Dismount-DiskImage -ImagePath $isoCompleta -ErrorAction SilentlyContinue
    }

    $senhaTexto = ConvertTo-PlainText -SecureValue $SenhaUsuarioLocal
    $unattendPath = Join-Path $setupRoot "autounattend.xml"
    Info "Gerando resposta autonoma: $unattendPath"
    New-UnattendXml `
        -DiskNumber $targetPartition.DiskNumber `
        -PartitionNumber $targetPartition.PartitionNumber `
        -ComputerName $NomeComputador `
        -LocalUser $UsuarioLocal `
        -LocalPassword $senhaTexto `
        -Key $ProductKey `
        -Path $unattendPath
    Ok "Arquivo autounattend.xml gerado."

    Info "Criando entrada temporaria de boot para Windows Setup..."
    $bootGuid = New-WindowsSetupBootEntry -SetupDriveLetter $setupDriveLetter
    Ok "Entrada BCD criada: $bootGuid"

    Write-Host ""
    Write-Host "==============================================================" -ForegroundColor Green
    Write-Host " PREPARACAO CONCLUIDA" -ForegroundColor Green
    Write-Host "==============================================================" -ForegroundColor Green
    Write-Host ("{0,-24} {1}" -f "Disco alvo:", $targetPartition.DiskNumber)
    Write-Host ("{0,-24} {1}" -f "Particao formatada:", "$targetMount / PartitionID $($targetPartition.PartitionNumber)")
    Write-Host ("{0,-24} {1}" -f "Particao setup:", $setupRoot)
    Write-Host ("{0,-24} {1}" -f "Imagem index:", $ImageIndex)
    Write-Host ("{0,-24} {1}" -f "BCD:", $bootGuid)
    Write-Host ("{0,-24} {1}" -f "Log:", $Log)
    Write-Host "==============================================================" -ForegroundColor Green

    if ($NaoReiniciar) {
        Aviso "Reinicio automatico desativado por -NaoReiniciar. Para iniciar a instalacao, reinicie manualmente este computador."
    } else {
        Aviso "Reiniciando em 60 segundos. A instalacao autonoma ira formatar $targetMount."
        shutdown.exe /r /t 60 /c "FlexIT: iniciando instalacao autonoma do Windows"
    }
} catch {
    Write-Host "[ERRO] $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} finally {
    if ($TranscriptAtivo) {
        Stop-Transcript | Out-Null
    }
}
