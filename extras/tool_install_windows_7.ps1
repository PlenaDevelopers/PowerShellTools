<#
    Copyright: (c) Flex IT - 2026
    Function: Instalar Windows 7 Professional
    Description: Prepara formatacao remota via AnyDesk a partir de uma ISO local do Windows 7. Usa chave generica de instalacao do Windows 7 Professional.

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
    powershell -ExecutionPolicy Bypass -File .\instalar_windows_7.ps1 -IsoPath "C:\ISOS\Windows.iso" -NaoReiniciar

    Exemplo preparar e reiniciar automaticamente:
    powershell -ExecutionPolicy Bypass -File .\instalar_windows_7.ps1 -IsoPath "C:\ISOS\Windows.iso"
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

    [string]$ProductKey = "KGKK4-2JW7F-QR6V7-CT2YW-RMPGK",

    [string]$EdicaoWindows = "Professional",

    [ValidateSet("pt_br", "en_us", "es-ES")]
    [string]$Idioma = "pt_br",

    [ValidateSet("E. South America Standard Time", "UTC", "Pacific Standard Time")]
    [string]$FusoHorario = "E. South America Standard Time",

    [ValidateSet("FORMATAR", "SAIR")]
    [string]$ConfirmarFormatacao = "",

    [switch]$Reiniciar,

    [switch]$NaoReiniciar,

    [switch]$PermitirUEFIWindows7,

    [switch]$NaoSuspenderBitLocker,

    [switch]$IgnorarBitLocker
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
$ScriptVersao = "1.0"
$RotuloSetup = "WINSETUP"
$NomeEntradaBoot = "FlexIT_Windows_7_Setup_Autonomo"
$Log = "C:\flexit-instalacao-windows-7.log"
$TranscriptAtivo = $false

function Write-Banner {
    Clear-Host
    Write-PowerToolBorder '+' '+' 'Yellow'
    Write-PowerToolLine 'Operation' 'Instalar Windows 7 Professional' 'Yellow'
    Write-PowerToolLine 'Modo' 'Formatacao remota via WINSETUP' 'Cyan'
    Write-PowerToolLine 'Production' (Get-Date).Year 'Yellow'
    Write-PowerToolLine 'Copyright' 'Flex IT' 'Yellow'
    Write-PowerToolLine 'Versao' $ScriptVersao 'White'
    Write-PowerToolBorder '+' '+' 'Cyan'
}

function Get-PowerToolWidth {
    try { return [Math]::Min([Math]::Max(($Host.UI.RawUI.WindowSize.Width - 4), 96), 160) } catch { return 120 }
}

function Write-PowerToolBorder {
    param([string]$Left = '+', [string]$Right = '+', [string]$Color = 'Cyan')
    Write-Host ($Left + ('-' * (Get-PowerToolWidth)) + $Right) -ForegroundColor $Color
}

function Write-PowerToolLine {
    param([string]$Campo, [string]$Valor, [string]$CorValor = 'White')
    $width = Get-PowerToolWidth
    $valueWidth = $width - 33
    if ($null -eq $Valor) { $Valor = '' }
    $texto = [string]$Valor
    if ($texto.Length -gt $valueWidth) { $texto = $texto.Substring(0, $valueWidth - 3) + '...' }
    Write-Host ("|{0,-30} : {1}|" -f $Campo, $texto.PadRight($valueWidth)) -ForegroundColor $CorValor
}

function Write-PowerToolFooter {
    param([string]$Status = 'Finished')
    Write-PowerToolBorder '+' '+' 'Cyan'
    Write-PowerToolLine 'Process' $Status 'Green'
    Write-PowerToolBorder '+' '+' 'Yellow'
}

function Info($Mensagem) { Write-PowerToolLine "Info" $Mensagem "Cyan" }
function Ok($Mensagem) { Write-PowerToolLine "OK" $Mensagem "Green" }
function Aviso($Mensagem) { Write-PowerToolLine "Aviso" $Mensagem "Yellow" }

function Assert-Admin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "Execute este script em um Powershell aberto como Administrador."
    }
}

function Confirm-FormatAction {
    param([string]$RequestedAction)

    if ($RequestedAction -eq "SAIR") {
        Write-PowerToolFooter -Status "Cancelado pelo operador"
        exit 0
    }
    if ($RequestedAction -eq "FORMATAR") {
        return "FORMATAR"
    }

    Write-PowerToolBorder '+' '+' 'Yellow'
    Write-PowerToolLine 'Atencao' 'Esta operacao formata a particao alvo.' 'Yellow'
    Write-PowerToolLine 'Opcao 1' 'Formatar e iniciar instalacao autonoma' 'Red'
    Write-PowerToolLine 'Opcao 2' 'Exit sem alterar o computador' 'Green'
    Write-PowerToolBorder '+' '+' 'Yellow'

    do {
        $opcao = Read-Host "Choose an option [1=Formatar, 2=Exit]"
        switch ($opcao.Trim()) {
            "1" { return "FORMATAR" }
            "2" {
                Write-PowerToolFooter -Status "Cancelado pelo operador"
                exit 0
            }
            default { Aviso "Opcao invalida. Use 1 para formatar ou 2 para sair." }
        }
    } while ($true)
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

function Get-FirmwareBootType {
    try {
        return (Get-ComputerInfo -Property BiosFirmwareType).BiosFirmwareType
    } catch {
        return "Unknown"
    }
}

function Test-SecureBootEnabledCompat {
    if (-not (Get-Command Confirm-SecureBootUEFI -ErrorAction SilentlyContinue)) { return $false }
    try {
        return [bool](Confirm-SecureBootUEFI)
    } catch {
        return $false
    }
}

function Assert-Windows7BootCompatibility {
    $firmware = Get-FirmwareBootType
    $secureBoot = Test-SecureBootEnabledCompat

    Write-PowerToolLine 'Firmware' $firmware 'White'
    $secureBootTexto = "Inativo ou indisponivel"
    $secureBootCor = "Green"
    if ($secureBoot) {
        $secureBootTexto = "Ativo"
        $secureBootCor = "Red"
    }
    Write-PowerToolLine 'Secure Boot' $secureBootTexto $secureBootCor

    if ($firmware -eq "Uefi" -and $secureBoot) {
        throw "Windows 7 nao inicia o boot.wim com Secure Boot ativo em UEFI. Desative Secure Boot no firmware/BIOS ou use Windows 10/11. O script foi interrompido antes de alterar boot/particoes."
    }

    if ($firmware -eq "Uefi" -and -not $PermitirUEFIWindows7) {
        throw "Windows 7 em UEFI pode iniciar com tela preta ou erro 0xc0000428. Altere o firmware para Legacy/CSM ou use -PermitirUEFIWindows7 assumindo o risco. O script foi interrompido antes de alterar boot/particoes."
    }

    if ($firmware -eq "Uefi" -and $PermitirUEFIWindows7) {
        Aviso "Windows 7 em UEFI foi liberado por -PermitirUEFIWindows7. Se aparecer tela preta/0xc0000428, volte para o Windows normal e limpe o boot menu FlexIT."
    }
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

function New-WindowsPeSettingsXml {
    param(
        [int]$DiskNumber,
        [int]$PartitionNumber,
        [string]$Key
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
                    <WillShowUI>Never</WillShowUI>
                </ProductKey>
"@
    }

    return @"
    <settings pass="windowsPE">
        <component name="Microsoft-Windows-International-Core-WinPE" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <SetupUILanguage>
                <UILanguage>pt_br</UILanguage>
            </SetupUILanguage>
            <InputLocale>007f:00010416</InputLocale>
            <SystemLocale>pt_br</SystemLocale>
            <UILanguage>pt_br</UILanguage>
            <UserLocale>pt_br</UserLocale>
        </component>
        <component name="Microsoft-Windows-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <DynamicUpdate>
                <WillShowUI>OnError</WillShowUI>
            </DynamicUpdate>
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
"@
}

function Get-Windows7BaseUnattendXml {
    return @"
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
	<settings pass="oobeSystem">
		<component name="Microsoft-Windows-International-Core" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
			<InputLocale>007f:00010416</InputLocale>
			<SystemLocale>pt_br</SystemLocale>
			<UILanguage>pt_br</UILanguage>
			<UILanguageFallback>pt_br</UILanguageFallback>
			<UserLocale>pt_br</UserLocale>
		</component>
		<component name="Microsoft-Windows-shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
			<TimeZone>E. South America Standard Time</TimeZone>
			<AutoLogon>
				<Enabled>true</Enabled>
				<LogonCount>9999999</LogonCount>
				<Username>Administrador</Username>
				<Password>
					<PlainText>true</PlainText>
					<Value></Value>
				</Password>
			</AutoLogon>
			<OOBE>
				<HideEULAPage>true</HideEULAPage>
				<NetworkLocation>Home</NetworkLocation>
				<ProtectYourPC>3</ProtectYourPC>
				<SkipMachineOOBE>true</SkipMachineOOBE>
				<SkipUserOOBE>true</SkipUserOOBE>
			</OOBE>
			<UserAccounts>
				<AdministratorPassword>
					<PlainText>true</PlainText>
					<Value></Value>
				</AdministratorPassword>
			</UserAccounts>
		</component>
	</settings>
	<settings pass="specialize">
		<component name="Microsoft-Windows-Deployment" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
			<RunSynchronous>
				<RunSynchronousCommand wcm:action="add">
					<Order>2</Order>
					<Path>net user Administrador /comment:"Alterar descrição"</Path>
					<WillReboot>Never</WillReboot>
				</RunSynchronousCommand>
				<RunSynchronousCommand wcm:action="add">
					<Order>1</Order>
					<Path>net user Administrador /active:Yes</Path>
					<WillReboot>Never</WillReboot>
				</RunSynchronousCommand>
				<RunSynchronousCommand wcm:action="add">
					<Order>3</Order>
					<Path>net user Administrador /fullname:"Alterar Nome"</Path>
					<WillReboot>Never</WillReboot>
				</RunSynchronousCommand>
			</RunSynchronous>
		</component>
		<component name="Microsoft-Windows-Security-SPP-UX" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
			<SkipAutoActivation>true</SkipAutoActivation>
		</component>
		<component name="Microsoft-Windows-shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
			<ComputerName>temp</ComputerName>
		</component>
	</settings>
	<settings pass="windowsPE">
		<component name="Microsoft-Windows-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
			<DynamicUpdate>
				<WillShowUI>OnError</WillShowUI>
			</DynamicUpdate>
			<ImageInstall>
				<OSImage>
					<WillShowUI>OnError</WillShowUI>
					<InstallFrom>
						<MetaData wcm:action="add">
							<Key>/IMAGE/INDEX</Key>
							<Value>1</Value>
						</MetaData>
					</InstallFrom>
				</OSImage>
			</ImageInstall>
			<UserData>
				<ProductKey>
					<Key></Key>
				</ProductKey>
			</UserData>
		</component>
	</settings>
</unattend>

"@
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

    $windowsPeXml = New-WindowsPeSettingsXml -DiskNumber $DiskNumber -PartitionNumber $PartitionNumber -Key $Key

    $baseUnattendXml = Get-Windows7BaseUnattendXml
    if (-not [string]::IsNullOrWhiteSpace($baseUnattendXml)) {
        [xml]$baseXml = $baseUnattendXml
        $ns = New-Object System.Xml.XmlNamespaceManager($baseXml.NameTable)
        $ns.AddNamespace("u", "urn:schemas-microsoft-com:unattend")
        $windowsPeNode = $baseXml.SelectSingleNode("/u:unattend/u:settings[@pass='windowsPE']", $ns)
        if ($windowsPeNode) {
            [void]$baseXml.DocumentElement.RemoveChild($windowsPeNode)
        }

        $fragmentDoc = New-Object System.Xml.XmlDocument
        $fragmentDoc.LoadXml("<root xmlns='urn:schemas-microsoft-com:unattend'>$windowsPeXml</root>")
        $newWindowsPeNode = $baseXml.ImportNode($fragmentDoc.DocumentElement.FirstChild, $true)
        [void]$baseXml.DocumentElement.AppendChild($newWindowsPeNode)

        $settingsNodes = @($baseXml.DocumentElement.ChildNodes | Where-Object { $_.Name -eq 'settings' })
        foreach ($settings in $settingsNodes) {
            if ($settings.GetAttribute('pass') -eq 'specialize') {
                $shellNodes = @($settings.ChildNodes | Where-Object { $_.Name -eq 'component' -and $_.GetAttribute('name') -eq 'Microsoft-Windows-shell-Setup' })
                foreach ($shell in $shellNodes) {
                    $computerNode = @($shell.ChildNodes | Where-Object { $_.Name -eq 'ComputerName' }) | Select-Object -First 1
                    if ($computerNode -and -not [string]::IsNullOrWhiteSpace($ComputerName)) {
                        $computerNode.InnerText = $ComputerName
                    }
                }
            }
        }

        $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
        $writerSettings = New-Object System.Xml.XmlWriterSettings
        $writerSettings.Encoding = $utf8NoBom
        $writerSettings.Indent = $true
        $writer = [System.Xml.XmlWriter]::Create($Path, $writerSettings)
        try { $baseXml.Save($writer) } finally { $writer.Close() }
        Ok "autounattend.xml gerado com base personalizada preservando specialize/oobeSystem."
        return
    }

    $xml = @"
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
$windowsPeXml
</unattend>
"@
    Set-Content -LiteralPath $Path -Value $xml -Encoding UTF8 -Force
}

function Set-Windows7EditionFiles {
    param(
        [string]$SetupRoot,
        [string]$EditionId,
        [string]$Key
    )

    $sourcesPath = Join-Path $SetupRoot "sources"
    if (-not (Test-Path -LiteralPath $sourcesPath -PathType Container)) {
        throw "Folder sources nao encontrada em $SetupRoot"
    }

    if (-not [string]::IsNullOrWhiteSpace($Key)) {
        $pidPath = Join-Path $sourcesPath "PID.txt"
        $pidText = @"
[PID]
Value=$Key
"@
        Set-Content -LiteralPath $pidPath -Value $pidText -Encoding ASCII -Force
        Ok "PID.txt criado para Windows 7 Professional."
    }

    if (-not [string]::IsNullOrWhiteSpace($EditionId)) {
        $eiPath = Join-Path $sourcesPath "EI.cfg"
        $eiText = @"
[EditionID]
$EditionId
[Channel]
Retail
[VL]
0
"@
        Set-Content -LiteralPath $eiPath -Value $eiText -Encoding ASCII -Force
        Ok "EI.cfg criado para edicao $EditionId."
    }
}


function New-AnyDeskPostInstallFiles {
    param(
        [string]$SetupRoot,
        [string]$Password = "ChangeMe!123"
    )

    $scriptsPath = Join-Path $SetupRoot 'sources\$OEM$\$$\Setup\Scripts'
    New-Item -ItemType Directory -Path $scriptsPath -Force | Out-Null

    $localAnyDesk = Join-Path $PSScriptRoot "AnyDesk.exe"
    if (Test-Path -LiteralPath $localAnyDesk -PathType Leaf) {
        Copy-Item -LiteralPath $localAnyDesk -Destination (Join-Path $scriptsPath "AnyDesk.exe") -Force
        Ok "AnyDesk.exe local copiado para pos-instalacao."
    } else {
        Aviso "AnyDesk.exe local nao encontrado. O Windows novo tentara baixar pela internet."
    }

    $escapedPassword = $Password.Replace("'", "''")
    $installScript = @'
$ErrorActionPreference = "Continue"
$ProgressPreference = "SilentlyContinue"
$Password = '__ANYDESK_PASSWORD__'
$Log = Join-Path $env:WINDIR "Setup\Scripts\FlexIT-AnyDesk.log"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Installer = Join-Path $ScriptDir "AnyDesk.exe"
$ProgramFilesX86 = [Environment]::GetEnvironmentVariable("ProgramFiles(x86)")
$InstallBase = $ProgramFilesX86
if ([string]::IsNullOrWhiteSpace($InstallBase)) {
    $InstallBase = $env:ProgramFiles
}
$InstallDir = Join-Path $InstallBase "AnyDesk"
$AnyDeskExe = Join-Path $InstallDir "AnyDesk.exe"

function Log($Message) {
    "[{0}] {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Message | Out-File -FilePath $Log -Append -Encoding ASCII
}

function Download-AnyDesk {
    param([string]$OutFile)
    $urls = @(
        "https://download.anydesk.com/AnyDesk.exe",
        "https://anydesk.com/en/downloads/thank-you?dv=win_exe"
    )

    foreach ($url in $urls) {
        try {
            Log "Baixando AnyDesk: $url"
            try { [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072 } catch { }
            $client = New-Object Net.WebClient
            $client.Headers.Add("User-Agent", "FlexIT-Windows-Setup")
            $client.DownloadFile($url, $OutFile)
            if ((Test-Path -LiteralPath $OutFile) -and ((Get-Item -LiteralPath $OutFile).Length -gt 1048576)) { return $true }
        } catch {
            Log "Failure WebClient: $($_.Exception.Message)"
        }
    }

    try {
        Log "Tentando baixar AnyDesk via certutil."
        $p = Start-Process -FilePath "certutil.exe" -ArgumentList @("-urlcache", "-f", "https://download.anydesk.com/AnyDesk.exe", $OutFile) -Wait -PassThru -WindowStyle Hidden
        if ($p.ExitCode -eq 0 -and (Test-Path -LiteralPath $OutFile) -and ((Get-Item -LiteralPath $OutFile).Length -gt 1048576)) { return $true }
    } catch {
        Log "Failure certutil: $($_.Exception.Message)"
    }

    return $false
}

try {
    Log "Iniciando pos-instalacao AnyDesk."
    if (-not (Test-Path -LiteralPath $Installer -PathType Leaf)) {
        $Installer = Join-Path $env:TEMP "AnyDesk.exe"
        if (-not (Download-AnyDesk -OutFile $Installer)) {
            Log "Nao foi possivel obter AnyDesk.exe."
            exit 0
        }
    }

    Log "Instalando AnyDesk em $InstallDir."
    $installArgs = @("--install", $InstallDir, "--start-with-win", "--silent", "--create-shortcuts", "--create-desktop-icon")
    $proc = Start-Process -FilePath $Installer -ArgumentList $installArgs -Wait -PassThru -WindowStyle Hidden
    Log "Instalador AnyDesk retornou codigo $($proc.ExitCode)."

    Start-Sleep -Seconds 8
    if (-not (Test-Path -LiteralPath $AnyDeskExe -PathType Leaf)) {
        $searchRoots = @($ProgramFilesX86, $env:ProgramFiles) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) -and (Test-Path -LiteralPath $_) }
        $found = Get-ChildItem -Path $searchRoots -Filter "AnyDesk.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($found) { $AnyDeskExe = $found.FullName }
    }

    if (Test-Path -LiteralPath $AnyDeskExe -PathType Leaf) {
        Log "Configurando senha de acesso nao assistido."
        $cmd = 'echo {0} | "{1}" --set-password' -f $Password, $AnyDeskExe
        cmd.exe /c $cmd | Out-File -FilePath $Log -Append -Encoding ASCII
        $cmdProfile = 'echo {0} | "{1}" --set-password _unattended_access' -f $Password, $AnyDeskExe
        cmd.exe /c $cmdProfile | Out-File -FilePath $Log -Append -Encoding ASCII
        try { Start-Process -FilePath $AnyDeskExe -ArgumentList @("--start") -Wait -WindowStyle Hidden } catch { }
        try { Start-Process -FilePath $AnyDeskExe -ArgumentList @("--get-id") -Wait -WindowStyle Hidden } catch { }
        Log "AnyDesk instalado/configurado. Executavel: $AnyDeskExe"
    } else {
        Log "AnyDesk.exe instalado nao encontrado."
    }
} catch {
    Log "Erro geral: $($_.Exception.Message)"
}
exit 0
'@
    $installScript = $installScript.Replace('__ANYDESK_PASSWORD__', $escapedPassword)
    Set-Content -LiteralPath (Join-Path $scriptsPath "InstallAnyDesk.ps1") -Value $installScript -Encoding ASCII -Force

    $setupComplete = @'
@echo off
set LOG=%WINDIR%\Setup\Scripts\FlexIT-AnyDesk.log
echo [%DATE% %TIME%] FlexIT SetupComplete iniciando AnyDesk >> "%LOG%"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%WINDIR%\Setup\Scripts\InstallAnyDesk.ps1" >> "%LOG%" 2>&1
exit /b 0
'@
    Set-Content -LiteralPath (Join-Path $scriptsPath "SetupComplete.cmd") -Value $setupComplete -Encoding ASCII -Force
    Ok "Pos-instalacao AnyDesk preparada em $scriptsPath."
}

function Grant-SetupRootAccess {
    param([string]$SetupRoot)

    try {
        $sidEveryone = New-Object Security.Principal.SecurityIdentifier "S-1-1-0"
        $contaEveryone = $sidEveryone.Translate([Security.Principal.NTAccount]).Value
        $acl = Get-Acl -LiteralPath $SetupRoot -ErrorAction Stop
        $rule = New-Object Security.AccessControl.FileSystemAccessRule($contaEveryone, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
        $acl.SetAccessRule($rule)
        Set-Acl -LiteralPath $SetupRoot -AclObject $acl -ErrorAction Stop
        Ok "Permissions de escrita aplicadas em $SetupRoot."
    } catch {
        Aviso "Nao foi possivel ajustar ACL em ${SetupRoot}: $($_.Exception.Message)"
    }
}

function Write-UnattendToSetupRoot {
    param(
        [string]$SetupRoot,
        [int]$DiskNumber,
        [int]$PartitionNumber,
        [string]$ComputerName,
        [string]$LocalUser,
        [string]$LocalPassword,
        [string]$Key
    )

    Grant-SetupRootAccess -SetupRoot $SetupRoot

    $finalPath = Join-Path $SetupRoot "autounattend.xml"
    $tempPath = Join-Path ([IO.Path]::GetTempPath()) ("autounattend-{0}.xml" -f ([guid]::NewGuid().ToString("N")))

    New-UnattendXml `
        -DiskNumber $DiskNumber `
        -PartitionNumber $PartitionNumber `
        -ComputerName $ComputerName `
        -LocalUser $LocalUser `
        -LocalPassword $LocalPassword `
        -Key $Key `
        -Path $tempPath

    try {
        Copy-Item -LiteralPath $tempPath -Destination $finalPath -Force -ErrorAction Stop
    } catch {
        try {
            $cmdCopy = 'copy /Y "{0}" "{1}"' -f $tempPath, $finalPath
            Invoke-CheckedProcess -FilePath "cmd.exe" -ArgumentList @("/c", $cmdCopy)
        } catch {
            throw "Nao foi possivel copiar autounattend.xml para $finalPath. $($_.Exception.Message)"
        }
    } finally {
        Remove-Item -LiteralPath $tempPath -Force -ErrorAction SilentlyContinue
    }

    Ok "Arquivo autounattend.xml criado em $finalPath."
    return $finalPath
}

function Get-OrCreateSetupPartition {
    param(
        [Microsoft.Management.Infrastructure.CimInstance]$TargetPartition,
        [string]$TargetMount,
        [int64]$SetupBytes,
        [int]$SetupSizeGB,
        [string]$Label
    )

    $existingVolume = Get-Volume -FileSystemLabel $Label -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($existingVolume) {
        $existingPartition = Get-Partition -DriveLetter $existingVolume.DriveLetter -ErrorAction Stop
        if ($existingPartition.DiskNumber -ne $TargetPartition.DiskNumber) {
            throw "Ja existe volume $Label em outro disco. Remova ou renomeie antes de continuar."
        }

        Info "Particao $Label ja existe em $($existingVolume.DriveLetter):. Formatando e reutilizando."
        Format-Volume -DriveLetter $existingVolume.DriveLetter -FileSystem NTFS -NewFileSystemLabel $Label -Confirm:$false -Force | Out-Null
        return @{
            Partition = (Get-Partition -DriveLetter $existingVolume.DriveLetter)
            DriveLetter = $existingVolume.DriveLetter
            Root = "$($existingVolume.DriveLetter):\"
            Reused = $true
        }
    }

    $targetVolume = Get-Volume -DriveLetter ($TargetMount.TrimEnd(':'))
    $supported = Get-PartitionSupportedSize -DiskNumber $TargetPartition.DiskNumber -PartitionNumber $TargetPartition.PartitionNumber
    $newTargetSize = $TargetPartition.Size - $SetupBytes
    if ($newTargetSize -lt $supported.SizeMin) {
        throw "Nao ha espaco suficiente para reduzir $TargetMount em $SetupSizeGB GB. Minimo suportado: $([math]::Round($supported.SizeMin / 1GB, 2)) GB."
    }
    if ($targetVolume.SizeRemaining -lt ($SetupBytes + 2GB)) {
        Aviso "Espaco livre em $TargetMount pode ser insuficiente para staging rapido. O redimensionamento ainda sera tentado."
    }

    Info "Reduzindo $TargetMount em $SetupSizeGB GB..."
    Resize-Partition -DiskNumber $TargetPartition.DiskNumber -PartitionNumber $TargetPartition.PartitionNumber -Size $newTargetSize
    Ok "Particao alvo reduzida."

    Info "Criando particao $Label..."
    $setupPartition = New-Partition -DiskNumber $TargetPartition.DiskNumber -Size $SetupBytes -AssignDriveLetter
    Format-Volume -Partition $setupPartition -FileSystem NTFS -NewFileSystemLabel $Label -Confirm:$false | Out-Null
    $setupPartition = Get-Partition -DiskNumber $setupPartition.DiskNumber -PartitionNumber $setupPartition.PartitionNumber

    return @{
        Partition = $setupPartition
        DriveLetter = $setupPartition.DriveLetter
        Root = "$($setupPartition.DriveLetter):\"
        Reused = $false
    }
}

function Remove-FlexITBootEntries {
    $saida = & bcdedit.exe /enum all
    if ($LASTEXITCODE -ne 0) {
        Aviso "Nao foi possivel listar entradas BCD antigas."
        return
    }

    $guidPattern = '\{[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\}'
    $blocos = @()
    $blocoAtual = New-Object System.Collections.Generic.List[string]

    foreach ($linha in $saida) {
        if ([string]::IsNullOrWhiteSpace($linha)) {
            if ($blocoAtual.Count -gt 0) { $blocos += ,@($blocoAtual.ToArray()) }
            $blocoAtual.Clear()
            continue
        }
        $blocoAtual.Add($linha)
    }
    if ($blocoAtual.Count -gt 0) { $blocos += ,@($blocoAtual.ToArray()) }

    $entradas = @()
    foreach ($bloco in $blocos) {
        $texto = ($bloco -join "`n")
        if ($texto -notmatch 'FlexIT') { continue }
        $match = [regex]::Match($texto, $guidPattern)
        if ($match.Success) {
            $entradas += $match.Value
        }
    }

    foreach ($guid in @($entradas | Select-Object -Unique)) {
        if ($guid -and $guid -notin @("{bootmgr}", "{current}", "{default}")) {
            try {
                Aviso "Removendo entrada BCD antiga FlexIT: $guid"
                Invoke-CheckedProcess -FilePath "bcdedit.exe" -ArgumentList @("/delete", $guid, "/f")
            } catch {
                Aviso "Nao foi possivel remover entrada BCD ${guid}: $($_.Exception.Message)"
            }
        }
    }

    try {
        Invoke-CheckedProcess -FilePath "bcdedit.exe" -ArgumentList @("/displayorder", "{current}", "/addfirst")
    } catch {
        Aviso "Nao foi possivel priorizar {current} no boot menu: $($_.Exception.Message)"
    }
}

function New-WindowsSetupBootEntry {
    param([string]$SetupDriveLetter)

    $setupDrive = "$SetupDriveLetter`:"
    $bootSdi = "$setupDrive\boot\boot.sdi"
    $bootWim = "$setupDrive\sources\boot.wim"
    if (-not (Test-Path -LiteralPath $bootSdi)) { throw "Arquivo nao encontrado: $bootSdi" }
    if (-not (Test-Path -LiteralPath $bootWim)) { throw "Arquivo nao encontrado: $bootWim" }

    Remove-FlexITBootEntries

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
    Invoke-CheckedProcess -FilePath "bcdedit.exe" -ArgumentList @("/timeout", "0")
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
    $ConfirmarFormatacao = Confirm-FormatAction -RequestedAction $ConfirmarFormatacao

    Info "ISO selecionada       : $isoCompleta"
    Info "Particao alvo         : $targetMount"
    Info "Confirmacao recebida  : $ConfirmarFormatacao"
    Aviso "A particao $targetMount sera formatada pelo Windows Setup apos o reboot."
    if (-not $SenhaUsuarioLocal) {
        Aviso "SenhaUsuarioLocal nao informada. A instalacao pode parar na criacao de usuario/OOBE."
    }

    Assert-Windows7BootCompatibility

    Disable-BitLockerForSetup -MountPoint $targetMount

    $targetPartition = Get-Partition -DriveLetter $targetLetter
    $disk = Get-Disk -Number $targetPartition.DiskNumber
    if ($disk.IsBoot -eq $false -and $disk.IsSystem -eq $false) {
        Aviso "O disco $($disk.Number) nao foi marcado como boot/system. Confira se esta e a unidade correta."
    }

    $setupBytes = [int64]$TamanhoParticaoSetupGB * 1GB
    $setupInfo = Get-OrCreateSetupPartition `
        -TargetPartition $targetPartition `
        -TargetMount $targetMount `
        -SetupBytes $setupBytes `
        -SetupSizeGB $TamanhoParticaoSetupGB `
        -Label $RotuloSetup

    $setupPartition = $setupInfo.Partition
    $setupDriveLetter = $setupInfo.DriveLetter
    $setupRoot = $setupInfo.Root
    if ($setupInfo.Reused) {
        Ok "Particao $RotuloSetup reutilizada em $setupRoot"
    } else {
        Ok "Particao criada em $setupRoot"
    }

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
        Set-Windows7EditionFiles -SetupRoot $setupRoot -EditionId $EdicaoWindows -Key $ProductKey
        New-AnyDeskPostInstallFiles -SetupRoot $setupRoot -Password "ChangeMe!123"
    } finally {
        Dismount-DiskImage -ImagePath $isoCompleta -ErrorAction SilentlyContinue
    }

    $senhaTexto = ConvertTo-PlainText -SecureValue $SenhaUsuarioLocal
    Info "Gerando resposta autonoma em $setupRoot"
    $unattendPath = Write-UnattendToSetupRoot `
        -SetupRoot $setupRoot `
        -DiskNumber $targetPartition.DiskNumber `
        -PartitionNumber $targetPartition.PartitionNumber `
        -ComputerName $NomeComputador `
        -LocalUser $UsuarioLocal `
        -LocalPassword $senhaTexto `
        -Key $ProductKey

    Info "Criando entrada temporaria de boot para Windows Setup..."
    $bootGuid = New-WindowsSetupBootEntry -SetupDriveLetter $setupDriveLetter
    Ok "Entrada BCD criada: $bootGuid"

    Write-PowerToolBorder '+' '+' 'Green'
    Write-PowerToolLine 'Resultado' 'Preparacao concluida' 'Green'
    Write-PowerToolLine 'Disco alvo' $targetPartition.DiskNumber 'White'
    Write-PowerToolLine 'Particao formatada' "$targetMount / PartitionID $($targetPartition.PartitionNumber)" 'Yellow'
    Write-PowerToolLine 'Particao setup' $setupRoot 'White'
    Write-PowerToolLine 'Edicao' 'Windows 7 Professional' 'White'
    Write-PowerToolLine 'Chave instalacao' $ProductKey 'White'
    Write-PowerToolLine 'Imagem index' $ImageIndex 'White'
    Write-PowerToolLine 'BCD' $bootGuid 'White'
    Write-PowerToolLine 'Log' $Log 'White'
    Write-PowerToolBorder '+' '+' 'Green'

    if ($NaoReiniciar) {
        Aviso "Reinicio automatico desativado por -NaoReiniciar. Para iniciar a instalacao, reinicie manualmente este computador."
    } else {
        Aviso "Reiniciando em 60 segundos. A instalacao autonoma ira formatar $targetMount."
        shutdown.exe /r /t 60 /c "FlexIT: iniciando instalacao autonoma do Windows"
    }
    Write-PowerToolFooter
} catch {
    Write-PowerToolLine "Erro" $_.Exception.Message "Red"
    Write-PowerToolFooter -Status "Falhou"
    exit 1
} finally {
    if ($TranscriptAtivo) {
        Stop-Transcript | Out-Null
    }
}
