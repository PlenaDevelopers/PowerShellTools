<#
    Copyright: (c) Flex IT - 2026
    Function: Configurar Modo IE no Microsoft Edge
    Description: Script Powershell do pacote PowerTool para execution automated em Windows 10 e Windows 11.
#>

param (
    [string[]]$SitesIE = @(
        "192.0.2.10",
        "192.0.2.10",
        "dvr.local",
        "intelbrascloud.com.br"
    ),
    [string]$DiretorioLista = "C:\IE-Mode",
    [switch]$AbrirDiagnostico,
    [switch]$NaoReiniciarEdge
)


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
    $statusColor = if ($Status -match 'erro|falha') { 'Red' } else { 'Green' }
    Write-PowerToolBorder '+' '+' 'Cyan'
    Write-PowerToolLine $Titulo $Status $statusColor 'Yellow'
    Write-PowerToolBorder '+' '+' 'Yellow'
    Stop-PowerToolTranscript
}

function Test-PowerToolAdmin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-EdgeIeModeSiteEntries {
    param([string[]]$Sites)

    $entries = New-Object System.Collections.Generic.List[string]

    foreach ($site in $Sites) {
        $siteValue = ([string]$site).Trim()
        if ([string]::IsNullOrWhiteSpace($siteValue)) { continue }

        $siteValue = $siteValue.TrimEnd('/')
        $entries.Add($siteValue)

        if ($siteValue -notmatch '^[a-zA-Z][a-zA-Z0-9+.-]*://') {
            $entries.Add("http://$siteValue")
            $entries.Add("https://$siteValue")
        }

        try {
            $uriCandidate = if ($siteValue -match '^[a-zA-Z][a-zA-Z0-9+.-]*://') { $siteValue } else { "http://$siteValue" }
            $uri = [System.Uri]$uriCandidate
            if (-not [string]::IsNullOrWhiteSpace($uri.Host)) {
                $entries.Add($uri.Host)
                if (-not $uri.IsDefaultPort) {
                    $entries.Add(("{0}:{1}" -f $uri.Host, $uri.Port))
                }
            }
        }
        catch { }
    }

    return $entries |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
        ForEach-Object { $_.Trim().TrimEnd('/') } |
        Select-Object -Unique
}

Initialize-PowerToolConsole

if (-not (Test-PowerToolAdmin)) {
    if ($env:POWERTOOL_DASHBOARD -eq '1') {
        Write-PowerToolLine "Erro" "Execute o dashboard como administrador" "Red"
        Stop-PowerToolTranscript
        exit 1
    }
    Start-Process -FilePath 'powershell.exe' -ArgumentList ('-NoProfile -ExecutionPolicy Bypass -File "{0}"' -f $MyInvocation.MyCommand.Path) -Verb RunAs
    exit
}

$scriptName = [System.IO.Path]::GetFileName($MyInvocation.MyCommand.Path)
Write-PowerToolHeader -Script $scriptName -Titulo "Configurar Modo IE no Microsoft Edge"

try {
    $xmlPath = Join-Path -Path $DiretorioLista -ChildPath "sites.xml"
    $edgePolicy = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"

    Write-PowerToolLine "Diretorio" $DiretorioLista "White"
    Write-PowerToolLine "Arquivo XML" $xmlPath "White"

    if (-not (Test-Path -LiteralPath $DiretorioLista)) {
        New-Item -ItemType Directory -Path $DiretorioLista -Force -ErrorAction Stop | Out-Null
        Write-PowerToolLine "Diretorio" "Criado" "Green"
    }
    else {
        Write-PowerToolLine "Diretorio" "Ja existia" "Yellow"
    }

    $siteEntries = @(Get-EdgeIeModeSiteEntries -Sites $SitesIE)

    $sitesXml = foreach ($siteValue in $siteEntries) {
        $escapedSite = [System.Security.SecurityElement]::Escape($siteValue)
        "  <site url=""$escapedSite"">`r`n    <compat-mode>IE11</compat-mode>`r`n    <open-in allow-redirect=""true"">IE11</open-in>`r`n  </site>"
    }

    if (-not $sitesXml -or $sitesXml.Count -eq 0) {
        throw "Nenhum site valido informado para o Modo IE."
    }

    $xmlVersion = Get-Date -Format "yyMMddHHmm"
    $xmlContent = "<site-list version=""$xmlVersion"">`r`n$($sitesXml -join "`r`n")`r`n</site-list>`r`n"
    Set-Content -LiteralPath $xmlPath -Value $xmlContent -Encoding UTF8 -Force -ErrorAction Stop

    foreach ($site in $siteEntries) {
        Write-PowerToolLine "Site IE" $site "White"
    }

    if (-not (Test-Path -LiteralPath $edgePolicy)) {
        New-Item -Path $edgePolicy -Force -ErrorAction Stop | Out-Null
        Write-PowerToolLine "Chave Edge" "Criada" "Green"
    }
    else {
        Write-PowerToolLine "Chave Edge" "Ja existia" "Yellow"
    }

    New-ItemProperty -Path $edgePolicy -Name "InternetExplorerIntegrationLevel" -Value 1 -PropertyType DWord -Force -ErrorAction Stop | Out-Null
    Write-PowerToolLine "Policy" "InternetExplorerIntegrationLevel=1" "Green"

    $xmlUri = ([System.Uri]$xmlPath).AbsoluteUri
    New-ItemProperty -Path $edgePolicy -Name "InternetExplorerIntegrationSiteList" -Value $xmlUri -PropertyType String -Force -ErrorAction Stop | Out-Null
    Write-PowerToolLine "Policy" "InternetExplorerIntegrationSiteList=$xmlUri" "Green"

    New-ItemProperty -Path $edgePolicy -Name "InternetExplorerIntegrationReloadInIEModeAllowed" -Value 1 -PropertyType DWord -Force -ErrorAction Stop | Out-Null
    Write-PowerToolLine "Policy" "ReloadInIEModeAllowed=1" "Green"

    New-ItemProperty -Path $edgePolicy -Name "InternetExplorerIntegrationSiteListRefreshInterval" -Value 1 -PropertyType DWord -Force -ErrorAction Stop | Out-Null
    Write-PowerToolLine "Policy" "SiteListRefreshInterval=1" "Green"

    try {
        Start-Process -FilePath "gpupdate.exe" -ArgumentList "/target:computer /force" -Wait -WindowStyle Hidden -ErrorAction SilentlyContinue
        Write-PowerToolLine "Politicas" "Atualizadas com gpupdate" "Green"
    }
    catch {
        Write-PowerToolLine "Politicas" "gpupdate nao executado" "Yellow"
    }

    if (-not $NaoReiniciarEdge) {
        $edgeProcesses = Get-Process -Name "msedge" -ErrorAction SilentlyContinue
        if ($edgeProcesses) {
            $edgeProcesses | Stop-Process -Force -ErrorAction SilentlyContinue
            Write-PowerToolLine "Microsoft Edge" "Processs finalizados" "Yellow"
        }
        else {
            Write-PowerToolLine "Microsoft Edge" "Nao estava em execution" "White"
        }
    }
    else {
        Write-PowerToolLine "Microsoft Edge" "Reinicio ignorado por parametro" "Yellow"
    }

    Write-PowerToolLine "Status" "Modo IE ativado no Microsoft Edge" "Green"
    Write-PowerToolLine "Diagnostico" "edge://policy" "Cyan"
    Write-PowerToolLine "Diagnostico" "edge://compat/enterprise" "Cyan"

    if ($AbrirDiagnostico) {
        Start-Process -FilePath "msedge.exe" -ArgumentList "edge://policy" -ErrorAction SilentlyContinue
        Start-Process -FilePath "msedge.exe" -ArgumentList "edge://compat/enterprise" -ErrorAction SilentlyContinue
    }

    Write-PowerToolFooter
}
catch {
    Write-PowerToolLine "Erro" $_.Exception.Message "Red"
    Write-PowerToolFooter "Process" "Finished com erro"
    exit 1
}
