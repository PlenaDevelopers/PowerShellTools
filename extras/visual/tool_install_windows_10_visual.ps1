<#
    Copyright: (c) Flex IT - 2026
    Function: Interface visual isolada para instalar Windows 10 Professional
    Description: Janela WinForms que seleciona a ISO, confirma formatacao e executa o script original funcional em segundo plano.

    Importante:
    - Nao altera instalar_windows_10.ps1.
    - Nao gera autounattend.xml.
    - Nao cria BCD.
    - Nao manipula boot.wim.
    - Apenas chama o script original com parametros.
#>

[CmdletBinding()]
param(
    [string]$InstaladorOriginal = "",
    [switch]$NaoReiniciar
)

$ErrorActionPreference = "Stop"
$script:ProcessInstalador = $null
$script:LogCursor = 0
$script:TempOutCursor = 0
$script:TempErrCursor = 0
$script:EtapasConcluidas = New-Object 'System.Collections.Generic.HashSet[string]'
$script:EventLogPath = ""

function Get-VisualScriptDir {
    if (-not [string]::IsNullOrWhiteSpace($PSScriptRoot)) { return $PSScriptRoot }
    if ($MyInvocation.MyCommand.Path) { return (Split-Path -Parent $MyInvocation.MyCommand.Path) }
    return (Get-Location).Path
}

function Initialize-EventLog {
    $dir = Get-VisualScriptDir
    if ([string]::IsNullOrWhiteSpace($dir)) { $dir = (Get-Location).Path }
    $script:EventLogPath = Join-Path $dir "log.txt"
    try {
        $header = @(
            "",
            "============================================================",
            ("FlexIT Windows 10 Visual iniciado em {0}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss")),
            ("Script visual: {0}" -f $MyInvocation.MyCommand.Path),
            ("Diretorio atual: {0}" -f (Get-Location).Path),
            ("Usuario: {0}" -f [Security.Principal.WindowsIdentity]::GetCurrent().Name),
            "============================================================"
        )
        Add-Content -LiteralPath $script:EventLogPath -Value $header -Encoding UTF8
    } catch { }
}

function Write-EventLog {
    param(
        [string]$Tipo,
        [string]$Mensagem
    )
    if ([string]::IsNullOrWhiteSpace($script:EventLogPath)) {
        try { $script:EventLogPath = Join-Path (Get-Location).Path "log.txt" } catch { return }
    }
    try {
        $line = "[{0}] [{1}] {2}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Tipo, $Mensagem
        Add-Content -LiteralPath $script:EventLogPath -Value $line -Encoding UTF8
    } catch { }
}

function Get-InstallRoot {
    $dir = Get-VisualScriptDir
    $parent = Split-Path -Parent $dir
    if ([string]::IsNullOrWhiteSpace($parent)) { return $dir }
    return $parent
}

function Quote-Arg {
    param([string]$Value)
    if ($null -eq $Value) { return '""' }
    return '"' + ($Value -replace '"', '\"') + '"'
}

function Test-IsAdmin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Restart-AsAdmin {
    if (Test-IsAdmin) { return }

    Add-Type -AssemblyName System.Windows.Forms
    $resposta = [System.Windows.Forms.MessageBox]::Show(
        "A preparacao do Windows precisa ser executada como Administrador. Abrir novamente com permissao elevada?",
        "FlexIT Windows 10",
        [System.Windows.Forms.MessageBoxButtons]::OKCancel,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    )
    if ($resposta -ne [System.Windows.Forms.DialogResult]::OK) { exit 0 }

    $self = $MyInvocation.MyCommand.Path
    if ([string]::IsNullOrWhiteSpace($self)) {
        throw "Nao foi possivel identificar o caminho deste script visual."
    }

    $args = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", (Quote-Arg $self))
    if (-not [string]::IsNullOrWhiteSpace($InstaladorOriginal)) {
        $args += @("-InstaladorOriginal", (Quote-Arg $InstaladorOriginal))
    }
    if ($NaoReiniciar) { $args += "-NaoReiniciar" }
    Start-Process -FilePath "powershell.exe" -ArgumentList ($args -join " ") -Verb RunAs | Out-Null
    exit 0
}

function Resolve-OriginalInstaller {
    param([string]$Requested)

    if (-not [string]::IsNullOrWhiteSpace($Requested)) {
        return (Resolve-Path -LiteralPath $Requested -ErrorAction Stop).Path
    }

    $scriptDir = Get-VisualScriptDir
    $root = Get-InstallRoot
    $current = (Get-Location).Path
    $candidatos = @(
        (Join-Path $scriptDir "instalar_windows_10.ps1"),
        (Join-Path $scriptDir "tool_install_windows_10.ps1"),
        (Join-Path $root "instalar_windows_10.ps1"),
        (Join-Path $root "tool_install_windows_10.ps1"),
        (Join-Path $current "instalar_windows_10.ps1"),
        (Join-Path $current "tool_install_windows_10.ps1")
    ) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique

    Write-EventLog "INFO" ("Procurando instalador original. scriptDir={0}; root={1}; current={2}" -f $scriptDir, $root, $current)
    foreach ($candidato in $candidatos) {
        Write-EventLog "INFO" ("Testando instalador original: {0}" -f $candidato)
        if (-not [string]::IsNullOrWhiteSpace($candidato) -and (Test-Path -LiteralPath $candidato -PathType Leaf)) {
            Write-EventLog "OK" ("Instalador original encontrado: {0}" -f $candidato)
            return $candidato
        }
    }

    Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
    $open = New-Object System.Windows.Forms.OpenFileDialog
    $open.Title = "Selecione o script original instalar_windows_10.ps1"
    $open.Filter = "Script Powershell (*.ps1)|*.ps1|Everyone os arquivos (*.*)|*.*"
    $open.InitialDirectory = $scriptDir
    if ($open.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        Write-EventLog "OK" ("Instalador original selecionado manualmente: {0}" -f $open.FileName)
        return $open.FileName
    }

    throw "Nao encontrei o instalador original. Coloque instalar_windows_10.ps1 na mesma pasta, na pasta acima, ou selecione o arquivo quando solicitado."
}

function Add-LogLine {
    param(
        $List,
        [string]$Tipo,
        [string]$Mensagem
    )

    if ([string]::IsNullOrWhiteSpace($Mensagem)) { return }
    $linha = $Mensagem.Trim()
    if ([string]::IsNullOrWhiteSpace($linha)) { return }
    Write-EventLog $Tipo $linha

    $item = New-Object System.Windows.Forms.ListViewItem((Get-Date -Format "HH:mm:ss"))
    [void]$item.SubItems.Add($Tipo)
    [void]$item.SubItems.Add($linha)

    if ($Tipo -eq "ERRO") {
        $item.ForeColor = [System.Drawing.Color]::DarkRed
    } elseif ($linha -match '\bOK\b|\[ OK \]|concluida|criado|copiado') {
        $item.ForeColor = [System.Drawing.Color]::DarkGreen
    } elseif ($linha -match 'AVISO|Atencao|formatada|BitLocker') {
        $item.ForeColor = [System.Drawing.Color]::DarkOrange
    }

    [void]$List.Items.Add($item)
    $List.EnsureVisible($List.Items.Count - 1)
}

function Read-NewText {
    param(
        [string]$Path,
        [ref]$Cursor
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return @() }
    try {
        $stream = [System.IO.File]::Open($Path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
        try {
            if ($Cursor.Value -gt $stream.Length) { $Cursor.Value = 0 }
            $stream.Seek($Cursor.Value, [System.IO.SeekOrigin]::Begin) | Out-Null
            $reader = New-Object System.IO.StreamReader($stream, [System.Text.Encoding]::Default)
            $text = $reader.ReadToEnd()
            $Cursor.Value = $stream.Position
        } finally {
            $stream.Close()
        }

        if ([string]::IsNullOrWhiteSpace($text)) { return @() }
        return @($text -split "(`r`n|`n|`r)" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    } catch {
        return @()
    }
}

function Update-StepFromLine {
    param(
        [string]$Line,
        $Progress,
        $Status
    )

    $map = @(
        @{ Key = "ISO"; Pattern = "ISO selecionada|Montando ISO"; Percent = 10; Text = "ISO selecionada e validada" },
        @{ Key = "BitLocker"; Pattern = "BitLocker|descriptograf"; Percent = 20; Text = "Verificando BitLocker" },
        @{ Key = "Particao"; Pattern = "WINSETUP|Particao|Reduzindo|Criando particao"; Percent = 35; Text = "Preparando particao WINSETUP" },
        @{ Key = "Copia"; Pattern = "Copiando arquivos|Arquivos de instalacao copiados|ROBOCOPY"; Percent = 55; Text = "Copiando arquivos da ISO" },
        @{ Key = "Resposta"; Pattern = "resposta autonoma|autounattend|PID.txt|EI.cfg"; Percent = 72; Text = "Gerando arquivos de instalacao autonoma" },
        @{ Key = "BCD"; Pattern = "BCD|boot|Entrada"; Percent = 88; Text = "Configurando boot temporario" },
        @{ Key = "Reinicio"; Pattern = "shutdown|Reinicio|reinici"; Percent = 96; Text = "Preparacao concluida; reinicio agendado" }
    )

    foreach ($entry in $map) {
        if ($Line -match $entry.Pattern -and -not $script:EtapasConcluidas.Contains($entry.Key)) {
            [void]$script:EtapasConcluidas.Add($entry.Key)
            if ($Progress.Value -lt $entry.Percent) { $Progress.Value = $entry.Percent }
            $Status.Text = $entry.Text
            return
        }
    }
}

function Get-CurrentFileLength {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return 0 }
    try { return (Get-Item -LiteralPath $Path).Length } catch { return 0 }
}

function Show-FlexInstallWindow {
    param([string]$OriginalInstaller)

    Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
    Add-Type -AssemblyName System.Drawing -ErrorAction Stop
    [System.Windows.Forms.Application]::EnableVisualStyles()

    $root = Split-Path -Parent $OriginalInstaller
    $logOriginal = "C:\flexit-instalacao-windows-10.log"
    $tempPrefix = Join-Path $env:TEMP ("flexit-win10-visual-{0}" -f ([guid]::NewGuid().ToString("N")))
    $tempOut = "$tempPrefix.out.log"
    $tempErr = "$tempPrefix.err.log"
    Write-EventLog "INFO" ("OriginalInstaller={0}" -f $OriginalInstaller)
    Write-EventLog "INFO" ("Root={0}" -f $root)
    Write-EventLog "INFO" ("LogOriginal={0}" -f $logOriginal)
    Write-EventLog "INFO" ("TempOut={0}" -f $tempOut)
    Write-EventLog "INFO" ("TempErr={0}" -f $tempErr)

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "FlexIT - Instalacao Visual Windows 10"
    $form.StartPosition = "CenterScreen"
    $form.Size = New-Object System.Drawing.Size(900, 620)
    $form.MinimumSize = New-Object System.Drawing.Size(900, 620)

    $title = New-Object System.Windows.Forms.Label
    $title.Text = "Instalar Windows 10 Professional"
    $title.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
    $title.Location = New-Object System.Drawing.Point(22, 18)
    $title.Size = New-Object System.Drawing.Size(830, 34)
    $form.Controls.Add($title)

    $status = New-Object System.Windows.Forms.Label
    $status.Text = "Selecione uma ISO para iniciar."
    $status.Location = New-Object System.Drawing.Point(24, 58)
    $status.Size = New-Object System.Drawing.Size(830, 24)
    $form.Controls.Add($status)

    $isoList = New-Object System.Windows.Forms.ListView
    $isoList.Location = New-Object System.Drawing.Point(26, 92)
    $isoList.Size = New-Object System.Drawing.Size(835, 150)
    $isoList.View = [System.Windows.Forms.View]::Details
    $isoList.FullRowSelect = $true
    $isoList.MultiSelect = $false
    [void]$isoList.Columns.Add("ISO", 470)
    [void]$isoList.Columns.Add("Folder", 340)
    $form.Controls.Add($isoList)

    $selectedLabel = New-Object System.Windows.Forms.Label
    $selectedLabel.Text = "ISO selecionada: nenhuma"
    $selectedLabel.Location = New-Object System.Drawing.Point(26, 252)
    $selectedLabel.Size = New-Object System.Drawing.Size(835, 22)
    $form.Controls.Add($selectedLabel)

    $progress = New-Object System.Windows.Forms.ProgressBar
    $progress.Location = New-Object System.Drawing.Point(26, 285)
    $progress.Size = New-Object System.Drawing.Size(835, 24)
    $progress.Minimum = 0
    $progress.Maximum = 100
    $form.Controls.Add($progress)

    $logView = New-Object System.Windows.Forms.ListView
    $logView.Location = New-Object System.Drawing.Point(26, 324)
    $logView.Size = New-Object System.Drawing.Size(835, 190)
    $logView.View = [System.Windows.Forms.View]::Details
    $logView.FullRowSelect = $true
    [void]$logView.Columns.Add("Hora", 75)
    [void]$logView.Columns.Add("Tipo", 75)
    [void]$logView.Columns.Add("Mensagem", 660)
    $form.Controls.Add($logView)

    $noReboot = New-Object System.Windows.Forms.CheckBox
    $noReboot.Text = "Preparar sem reiniciar automaticamente"
    $noReboot.Checked = [bool]$NaoReiniciar
    $noReboot.Location = New-Object System.Drawing.Point(26, 530)
    $noReboot.Size = New-Object System.Drawing.Size(320, 26)
    $form.Controls.Add($noReboot)

    $browseButton = New-Object System.Windows.Forms.Button
    $browseButton.Text = "Selecionar ISO"
    $browseButton.Location = New-Object System.Drawing.Point(490, 528)
    $browseButton.Size = New-Object System.Drawing.Size(120, 30)
    $form.Controls.Add($browseButton)

    $formatButton = New-Object System.Windows.Forms.Button
    $formatButton.Text = "Formatar"
    $formatButton.Location = New-Object System.Drawing.Point(622, 528)
    $formatButton.Size = New-Object System.Drawing.Size(110, 30)
    $form.Controls.Add($formatButton)

    $exitButton = New-Object System.Windows.Forms.Button
    $exitButton.Text = "Exit"
    $exitButton.Location = New-Object System.Drawing.Point(748, 528)
    $exitButton.Size = New-Object System.Drawing.Size(110, 30)
    $form.Controls.Add($exitButton)

    $state = [pscustomobject]@{ Iso = "" }

    function Add-IsoItem([string]$Path) {
        if ([string]::IsNullOrWhiteSpace($Path)) { return }
        if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return }
        $existente = @($isoList.Items | Where-Object { $_.Tag -eq $Path }) | Select-Object -First 1
        if ($existente) {
            $existente.Selected = $true
            $state.Iso = $Path
            $selectedLabel.Text = "ISO selecionada: $Path"
            return
        }

        $item = New-Object System.Windows.Forms.ListViewItem((Split-Path -Leaf $Path))
        [void]$item.SubItems.Add((Split-Path -Parent $Path))
        $item.Tag = $Path
        [void]$isoList.Items.Add($item)
        if ([string]::IsNullOrWhiteSpace($state.Iso)) {
            $state.Iso = $Path
            $item.Selected = $true
            $selectedLabel.Text = "ISO selecionada: $Path"
        }
    }

    Get-ChildItem -LiteralPath $root -Filter "*.iso" -File -ErrorAction SilentlyContinue |
        Sort-Object Name |
        ForEach-Object { Add-IsoItem $_.FullName }

    $isoList.Add_SelectedIndexChanged({
        if ($isoList.SelectedItems.Count -gt 0) {
            $state.Iso = [string]$isoList.SelectedItems[0].Tag
            $selectedLabel.Text = "ISO selecionada: $($state.Iso)"
        }
    })

    $browseButton.Add_Click({
        $open = New-Object System.Windows.Forms.OpenFileDialog
        $open.Title = "Selecionar ISO do Windows 10"
        $open.Filter = "Imagem ISO (*.iso)|*.iso|Everyone os arquivos (*.*)|*.*"
        $open.InitialDirectory = $root
        if ($open.ShowDialog($form) -eq [System.Windows.Forms.DialogResult]::OK) {
            Add-IsoItem $open.FileName
        }
    })

    $timer = New-Object System.Windows.Forms.Timer
    $timer.Interval = 1200
    $timer.Add_Tick({
        foreach ($line in (Read-NewText -Path $tempOut -Cursor ([ref]$script:TempOutCursor))) {
            Add-LogLine -List $logView -Tipo "INFO" -Mensagem $line
            Update-StepFromLine -Line $line -Progress $progress -Status $status
        }
        foreach ($line in (Read-NewText -Path $tempErr -Cursor ([ref]$script:TempErrCursor))) {
            Add-LogLine -List $logView -Tipo "ERRO" -Mensagem $line
            Update-StepFromLine -Line $line -Progress $progress -Status $status
        }
        foreach ($line in (Read-NewText -Path $logOriginal -Cursor ([ref]$script:LogCursor))) {
            Add-LogLine -List $logView -Tipo "LOG" -Mensagem $line
            Update-StepFromLine -Line $line -Progress $progress -Status $status
        }

        if ($script:ProcessInstalador -and $script:ProcessInstalador.HasExited) {
            $timer.Stop()
            $formatButton.Enabled = $true
            $browseButton.Enabled = $true
            $noReboot.Enabled = $true
            try {
                $script:ProcessInstalador.Refresh()
                $script:ProcessInstalador.WaitForExit()
                $exitCode = $script:ProcessInstalador.ExitCode
            } catch {
                $exitCode = $null
                Write-EventLog "ERRO" ("Nao foi possivel obter ExitCode: {0}" -f $_.Exception.Message)
            }

            if ($null -ne $exitCode -and $exitCode -eq 0) {
                $progress.Value = 100
                $status.Text = "Script original finalizado com success."
                Add-LogLine -List $logView -Tipo "OK" -Mensagem "Process concluido. Codigo 0."
            } else {
                $exitText = "indisponivel"
                if ($null -ne $exitCode) { $exitText = [string]$exitCode }
                $status.Text = "Script original finalizou com erro. Codigo $exitText."
                Add-LogLine -List $logView -Tipo "ERRO" -Mensagem "Exit code: $exitText."
                Write-EventLog "ERRO" ("Process finalizado com erro. ExitCode={0}" -f $exitText)
            }
        }
    })

    $formatButton.Add_Click({
        if ($script:ProcessInstalador -and -not $script:ProcessInstalador.HasExited) { return }
        if ([string]::IsNullOrWhiteSpace($state.Iso) -or -not (Test-Path -LiteralPath $state.Iso -PathType Leaf)) {
            [System.Windows.Forms.MessageBox]::Show($form, "Selecione uma ISO valida.", "FlexIT Windows 10", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning) | Out-Null
            return
        }

        $confirm = [System.Windows.Forms.MessageBox]::Show(
            $form,
            "Confirmar preparacao destrutiva da instalacao autonoma usando o script original?",
            "Confirmar formatacao",
            [System.Windows.Forms.MessageBoxButtons]::YesNo,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        )
        if ($confirm -ne [System.Windows.Forms.DialogResult]::Yes) { return }

        $progress.Value = 3
        $status.Text = "Iniciando script original funcional..."
        $formatButton.Enabled = $false
        $browseButton.Enabled = $false
        $noReboot.Enabled = $false
        $script:EtapasConcluidas.Clear()
        $script:LogCursor = Get-CurrentFileLength -Path $logOriginal
        $script:TempOutCursor = 0
        $script:TempErrCursor = 0
        $logView.Items.Clear()

        $args = @(
            "-NoProfile",
            "-ExecutionPolicy", "Bypass",
            "-File", (Quote-Arg $OriginalInstaller),
            "-IsoPath", (Quote-Arg $state.Iso),
            "-ConfirmarFormatacao", "FORMATAR"
        )
        if ($noReboot.Checked) { $args += "-NaoReiniciar" }

        Add-LogLine -List $logView -Tipo "INFO" -Mensagem "Executando: powershell.exe $($args -join ' ')"
        Write-EventLog "INFO" ("ISO={0}" -f $state.Iso)
        Write-EventLog "INFO" ("NaoReiniciar={0}" -f $noReboot.Checked)
        Write-EventLog "INFO" ("Comando=powershell.exe {0}" -f ($args -join " "))
        try {
            $script:ProcessInstalador = Start-Process `
                -FilePath "powershell.exe" `
                -ArgumentList ($args -join " ") `
                -WorkingDirectory $root `
                -WindowStyle Minimized `
                -RedirectStandardOutput $tempOut `
                -RedirectStandardError $tempErr `
                -PassThru
            Write-EventLog "OK" ("Process iniciado. PID={0}" -f $script:ProcessInstalador.Id)
        } catch {
            $formatButton.Enabled = $true
            $browseButton.Enabled = $true
            $noReboot.Enabled = $true
            Add-LogLine -List $logView -Tipo "ERRO" -Mensagem ("Failure ao iniciar powershell.exe: {0}" -f $_.Exception.Message)
            throw
        }

        $timer.Start()
    })

    $exitButton.Add_Click({
        if ($script:ProcessInstalador -and -not $script:ProcessInstalador.HasExited) {
            [System.Windows.Forms.MessageBox]::Show($form, "O instalador original ainda esta em execution. Aguarde finalizar.", "FlexIT Windows 10", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information) | Out-Null
            return
        }
        $form.Close()
    })

    [void]$form.ShowDialog()
}

try {
    Initialize-EventLog
    Restart-AsAdmin
    $original = Resolve-OriginalInstaller -Requested $InstaladorOriginal
    Show-FlexInstallWindow -OriginalInstaller $original
} catch {
    Write-EventLog "ERRO" $_.Exception.ToString()
    try {
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, "Erro - FlexIT Windows 10 Visual", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error) | Out-Null
    } catch {
        Write-Error $_.Exception.Message
    }
    exit 1
}
