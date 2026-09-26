<#
    Copyright: (c) Flex IT - 2026
    Function: Desabilitar Adobe Creative Cloud
    Description: Script Powershell do pacote PowerTool para execution automated em Windows 10 e Windows 11.
#>

# PowerTool: local presentation without external dependencies
function Initialize-PowerToolConsole {
    Set-Variable -Name ConfirmPreference -Value 'None' -Scope Global
    Set-Variable -Name WhatIfPreference -Value $false -Scope Global
    Set-Variable -Name ProgressPreference -Value 'SilentlyContinue' -Scope Global

    if (-not $global:PowerToolTranscriptActive) {
        try {
            $baseDir = $PSScriptRoot
            if ([string]::IsNullOrWhiteSpace($baseDir)) {
                if ($PSCommandPath) { $baseDir = Split-Path -Parent $PSCommandPath }
                elseif ($MyInvocation.MyCommand.Path) { $baseDir = Split-Path -Parent $MyInvocation.MyCommand.Path }
                else { $baseDir = (Get-Location).Path }
            }
            $logDir = Join-Path -Path $baseDir -ChildPath 'logs'
            if (-not (Test-Path -LiteralPath $logDir)) {
                New-Item -Path $logDir -ItemType Directory -Force -Confirm:$false | Out-Null
            }
            $scriptBase = if ($PSCommandPath) { [System.IO.Path]::GetFileNameWithoutExtension($PSCommandPath) } else { 'PowerTool' }
            $safeScriptBase = $scriptBase -replace '[^A-Za-z0-9_.-]', '_'
            $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
            $logPath = Join-Path -Path $logDir -ChildPath ("PowerTool_{0}_{1}_{2}.log" -f $timestamp, $safeScriptBase, $PID)
            Start-Transcript -Path $logPath -Force -Confirm:$false | Out-Null
            $global:PowerToolTranscriptActive = $true
            $global:PowerToolTranscriptPath = $logPath
            $global:PowerToolTranscriptOwner = $PSCommandPath
        }
        catch {
            $global:PowerToolTranscriptActive = $false
        }
    }
    try {
        $larguraDesejada = 124
        if ($Host.Name -match 'ConsoleHost') {
            $raw = $Host.UI.RawUI
            $buffer = $raw.BufferSize
            if ($buffer.Width -lt $larguraDesejada) {
                $buffer.Width = $larguraDesejada
                $raw.BufferSize = $buffer
            }
            $window = $raw.WindowSize
            $maxWidth = $raw.MaxPhysicalWindowSize.Width
            if ($maxWidth -ge $larguraDesejada -and $window.Width -ne $larguraDesejada) {
                $window.Width = $larguraDesejada
                $raw.WindowSize = $window
            }
            elseif ($window.Width -lt $larguraDesejada -and $maxWidth -gt 0) {
                $window.Width = [Math]::Min($larguraDesejada, $maxWidth)
                $raw.WindowSize = $window
            }
        }
    }
    catch { }
}
function Stop-PowerToolTranscript {
    try {
        if ($global:PowerToolTranscriptActive -and ($global:PowerToolTranscriptOwner -eq $PSCommandPath -or [string]::IsNullOrWhiteSpace($global:PowerToolTranscriptOwner))) {
            Stop-Transcript -Confirm:$false | Out-Null
            $global:PowerToolTranscriptActive = $false
        }
    }
    catch { }
}


function Get-PowerToolWidth {
    try {
        $width = $Host.UI.RawUI.WindowSize.Width - 4
        if ($width -lt 80) { return 120 }
        return [Math]::Min([Math]::Max($width, 96), 160)
    }
    catch { return 120 }
}

function Write-PowerToolBorder {
    param(
        [string]$Left,
        [string]$Right,
        [string]$Color = 'Cyan'
    )
    $width = Get-PowerToolWidth
    Write-Host ($Left + ('-' * $width) + $Right) -ForegroundColor $Color
}

function Write-PowerToolLine {
    param(
        [string]$Campo,
        [string]$Valor,
        [string]$CorValor = 'White',
        [string]$CorBorda = 'Cyan'
    )
    $width = Get-PowerToolWidth
    $labelWidth = 30
    $valueWidth = $width - $labelWidth - 3
    if ($valueWidth -lt 20) { $valueWidth = 20 }
    if ($null -eq $Valor) { $Valor = '' }
    $texto = [string]$Valor
    if ($texto.Length -gt $valueWidth) { $texto = $texto.Substring(0, $valueWidth - 3) + '...' }
    Write-Host ("|{0,-30} : {1}|" -f $Campo, $texto.PadRight($valueWidth)) -ForegroundColor $CorValor
}

function Write-PowerToolHeader {
    param(
        [string]$Script = $MyInvocation.MyCommand.Name,
        [string]$Titulo = 'Process',
        [string]$CopyRight = 'Flex IT'
    )
    Initialize-PowerToolConsole
    $anoAtual = (Get-Date).Year
    Write-PowerToolBorder '+' '+' 'Yellow'
    Write-PowerToolLine 'Operation' $Titulo 'Yellow' 'Yellow'
    Write-PowerToolLine 'Production' $anoAtual 'Yellow' 'Yellow'
    Write-PowerToolLine 'Copyright' $CopyRight 'Yellow' 'Yellow'
    Write-PowerToolLine 'Script' $Script 'White' 'Yellow'
    Write-PowerToolBorder '+' '+' 'Cyan'
}

function Write-PowerToolFooter {
    param(
        [string]$Titulo = 'Process',
        [string]$Status = 'Finished'
    )
    Write-PowerToolBorder '+' '+' 'Cyan'
    Write-PowerToolLine $Titulo $Status 'Green' 'Yellow'
    Write-PowerToolBorder '+' '+' 'Yellow'
    Stop-PowerToolTranscript
}

Initialize-PowerToolConsole

# =============================================
# PARA, DESABILITA e REDUZ AO MXIMO os servios/processos/tarefas do Adobe Creative Cloud
# Inclui: Content Manager, Interprocess Service, Libraries Synchronizer, CCXProcess + tarefas agendadas
# Execute como ADMINISTRADOR
# =============================================

Write-Host "Parando e desabilitando processos/servios/tarefas Adobe Creative Cloud..." -ForegroundColor Yellow

# 1. Para processos em execuo (mais eficaz que s servios)
$processosAdobe = @(
    "Creative Cloud",
    "Creative Cloud Helper",
    "Creative Cloud Content Manager",     # Content Manager
    "Creative Cloud Interprocess Service", # Interprocess Service
    "CoreSync",                            # Libraries Synchronizer / sincronizao
    "CCLibrary",
    "CCXProcess",
    "AdobeIPCBroker",
    "Adobe Desktop Service",
    "AGSService",
    "AGMService",
    "AdobeCollabSync",
    "Adobe CEF Helper",
    "node"                                 # s vezes node.exe roda coisas do CC
)

foreach ($proc in $processosAdobe) {
    Get-Process -Name $proc -ErrorAction SilentlyContinue |
        Stop-Process -Confirm:$false -Force -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
}
Write-Host "Processs Adobe terminados (se existiam)." -ForegroundColor Green

# 2. Servios comuns do Creative Cloud
$servicosAdobe = @(
    "AdobeUpdateService",
    "AGSService",
    "AdobeGenuineSoftwareIntegrityService",
    "AdobeARMservice",                     # Mais antigo, s vezes ainda existe
    "Adobe Acrobat Update Service"         # Pode aparecer em instalaes com Acrobat
)

foreach ($nome in $servicosAdobe) {
    $servico = Get-Service -Name $nome -ErrorAction SilentlyContinue
    if ($servico) {
        if ($servico.Status -eq "Running") {
            Stop-Service -Confirm:$false -Name $servico.Name -Force -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 2
        }
        Set-Service -Name $servico.Name -StartupType Manual -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
        $servico.Refresh()
        Write-Host "Servio ajustado: $($servico.DisplayName) [$($servico.Name)]  $($servico.StartType)" -ForegroundColor Cyan
    }
}

# 3. Tasks Agendadas - desabilitar as principais do Creative Cloud
Write-Host "`nVerificando e desabilitando tarefas agendadas do Adobe Creative Cloud..." -ForegroundColor Yellow

$tarefasAdobe = @(
    "Adobe CCXProcess",                     # Principal para updates de contedo CC
    "Launch Adobe CCXProcess",
    "Adobe Creative Cloud",
    "Adobe Acrobat Update Task",
    "Adobe ARM",                            # Atualizador genrico
    "Adobe Genuine Software Integrity Service Task",
    "CoreSync",                             # Pode aparecer como tarefa
    "CCLibrary"                             # Sincronizao de bibliotecas
)

$encontrouTask = $false

foreach ($nomeTask in $tarefasAdobe) {
    # Busca em todas as pastas (no s raiz)
    $tarefas = Get-ScheduledTask -TaskName $nomeTask -ErrorAction SilentlyContinue
    if (-not $tarefas) {
        # Tenta busca parcial (contains)
        $tarefas = Get-ScheduledTask | Where-Object { $_.TaskName -like "*$nomeTask*" -or $_.TaskName -like "*Adobe*" -or $_.TaskName -like "*CCX*" } -ErrorAction SilentlyContinue
    }

    foreach ($tarefa in $tarefas) {
        $encontrouTask = $true
        Write-Host "Task encontrada: $($tarefa.TaskPath)$($tarefa.TaskName)" -ForegroundColor Green
        
        if ($tarefa.State -ne "Disabled") {
            Write-Host "Desabilitando tarefa..."
            Disable-ScheduledTask -Confirm:$false -TaskName $tarefa.TaskName -TaskPath $tarefa.TaskPath -ErrorAction SilentlyContinue
        } else {
            Write-Host "J estava desabilitada." -ForegroundColor DarkGray
        }
        
        # Atualiza e mostra status
        $tarefa = Get-ScheduledTask -TaskName $tarefa.TaskName -TaskPath $tarefa.TaskPath -ErrorAction SilentlyContinue
        Write-Host "Estado atual: $($tarefa.State)" -ForegroundColor Cyan
    }
}

# Busca extra genrica por tarefas Adobe (se as acima no pegarem tudo)
$extraTasks = Get-ScheduledTask | Where-Object { 
    $_.TaskName -like "*Adobe*" -or 
    $_.TaskName -like "*Creative Cloud*" -or 
    $_.TaskName -like "*CCX*" -or 
    $_.TaskName -like "*CoreSync*" -or 
    $_.TaskName -like "*CCLibrary*" 
} -ErrorAction SilentlyContinue

foreach ($t in $extraTasks) {
    if ($t.State -ne "Disabled") {
        $encontrouTask = $true
        Write-Host "Task extra Adobe detectada  desabilitando: $($t.TaskPath)$($t.TaskName)" -ForegroundColor Green
        Disable-ScheduledTask -Confirm:$false -TaskName $t.TaskName -TaskPath $t.TaskPath -ErrorAction SilentlyContinue
        Write-Host "Estado: $($t.State)  Disabled" -ForegroundColor Cyan
    }
}

if (-not $encontrouTask) {
    Write-Host "Nenhuma tarefa Adobe conhecida encontrada no Agendador." -ForegroundColor Yellow
    Write-Host "Abra o Agendador de Tasks e procure manualmente por 'Adobe' ou 'Creative Cloud'." -ForegroundColor Yellow
}

# Dica extra: desabilitar inicializao automtica via registry (descomente se quiser)
# Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "Adobe Creative Cloud" -ErrorAction SilentlyContinue
# Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "Adobe Creative Cloud" -ErrorAction SilentlyContinue

Write-Host "`nFeito." -ForegroundColor Green
Write-Host "Observaes importantes:" -ForegroundColor Magenta
Write-Host " Muitos processos/tarefas voltam quando voc abre um programa Adobe (Photoshop, Premiere etc.)" -ForegroundColor Magenta
Write-Host " CCXProcess e Content Manager so especialmente persistentes (atualizam contedos/templates)" -ForegroundColor Magenta
Write-Host " Para efeito mais duradouro, evite abrir o app Creative Cloud Desktop" -ForegroundColor Magenta
Write-Host " Se precisar reativar: mude servios para 'Automatic', habilite as tarefas e inicie os servios" -ForegroundColor Magenta
Write-Host " Verifique no Gerenciador de Tasks + Agendador de Tasks aps executar" -ForegroundColor Magenta
