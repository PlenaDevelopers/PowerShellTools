<#
    Copyright: (c) Flex IT - 2026
    Function: Desabilitar Office Click To Run
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
# PARA e DESABILITA o Office Click-to-Run + Tasks Agendadas
# Execute como ADMINISTRADOR
# =============================================

Write-Host "Parando e desabilitando Office Click-to-Run..." -ForegroundColor Yellow

# === Parte 1: Servios ===
$servicosOffice = @(
    "ClickToRunSvc",
    "ClickToRunService",
    "OfficeClickToRunService"
)

$encontrouServico = $false

foreach ($nome in $servicosOffice) {
    $servico = Get-Service -Name $nome -ErrorAction SilentlyContinue
    if ($servico) {
        $encontrouServico = $true
        Write-Host "Servio encontrado: $($servico.DisplayName) [$($servico.Name)]" -ForegroundColor Green
        
        # Para o servio (se estiver rodando)
        if ($servico.Status -eq "Running") {
            Write-Host "Parando servio..."
            Stop-Service -Confirm:$false -Name $servico.Name -Force -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 4
        }
        
        # Desabilita inicializao automtica
        Write-Host "Definindo startup como Disabled..."
        Set-Service -Name $servico.Name -StartupType Disabled -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
        
        # Mostra status atualizado
        $servico.Refresh()
        Write-Host "Status atual: $($servico.Name)  $($servico.Status)" -ForegroundColor Cyan
    }
}

if (-not $encontrouServico) {
    Write-Host "Nenhum servio ClickToRun encontrado com os nomes conhecidos." -ForegroundColor Red
    Write-Host "Verifique em services.msc nomes que contenham 'ClickToRun' ou 'OfficeClick'." -ForegroundColor Yellow
}

# === Parte 2: Tasks Agendadas ===
Write-Host "`nVerificando e desabilitando tarefas agendadas do Office Click-to-Run..." -ForegroundColor Yellow

$tarefasOffice = @(
    "Office ClickToRun Service Monitor",
    "Office Automatic Updates 2.0",
    "Office Serviceability Manager",
    "OfficeBackgroundTaskHandlerRegistration"   # s vezes aparece em verses mais novas
)

$encontrouTask = $false
$namespace = "\Microsoft\Office\"

foreach ($nomeTask in $tarefasOffice) {
    $tarefa = Get-ScheduledTask -TaskName $nomeTask -TaskPath $namespace -ErrorAction SilentlyContinue
    if ($tarefa) {
        $encontrouTask = $true
        Write-Host "Task encontrada: $namespace$($tarefa.TaskName)" -ForegroundColor Green
        
        if ($tarefa.State -ne "Disabled") {
            Write-Host "Desabilitando tarefa..."
            Disable-ScheduledTask -Confirm:$false -TaskName $tarefa.TaskName -TaskPath $tarefa.TaskPath -ErrorAction SilentlyContinue
        } else {
            Write-Host "Task j estava desabilitada." -ForegroundColor DarkGray
        }
        
        # Mostra status atualizado
        $tarefa = Get-ScheduledTask -TaskName $tarefa.TaskName -TaskPath $tarefa.TaskPath -ErrorAction SilentlyContinue
        Write-Host "Estado atual: $($tarefa.State)" -ForegroundColor Cyan
    }
}

# Busca genrica extra (caso tenha variaes)
$extraTasks = Get-ScheduledTask -TaskPath "\Microsoft\Office\" -ErrorAction SilentlyContinue |
    Where-Object { $_.TaskName -like "*ClickToRun*" -or $_.TaskName -like "*Automatic Updates*" -or $_.TaskName -like "*Office Service*" }

foreach ($t in $extraTasks) {
    if ($t.State -ne "Disabled") {
        $encontrouTask = $true
        Write-Host "Task extra detectada  desabilitando: $($t.TaskPath)$($t.TaskName)" -ForegroundColor Green
        Disable-ScheduledTask -Confirm:$false -TaskName $t.TaskName -TaskPath $t.TaskPath -ErrorAction SilentlyContinue
        Write-Host "Estado: $($t.State)  Disabled" -ForegroundColor Cyan
    }
}

if (-not $encontrouTask) {
    Write-Host "Nenhuma tarefa conhecida do Office Click-to-Run encontrada em \Microsoft\Office\" -ForegroundColor Yellow
    Write-Host "Voc pode abrir o Agendador de Tasks e procurar manualmente por 'Office' ou 'ClickToRun'." -ForegroundColor Yellow
}

Write-Host "`nFeito." -ForegroundColor Green
Write-Host "Lembrete importante:" -ForegroundColor Magenta
Write-Host " Atualizaes automticas do Office foram desativadas" -ForegroundColor Magenta
Write-Host " Algumas funes online / ativao / reparo podem no funcionar corretamente" -ForegroundColor Magenta
Write-Host " Para reverter: mude o servio para 'Manual' ou 'Automatic' e habilite as tarefas novamente" -ForegroundColor Magenta
