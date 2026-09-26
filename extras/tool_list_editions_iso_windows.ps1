<#
    Copyright: (c) Flex IT - 2026
    Function: Listar edicoes disponiveis em uma ISO do Windows
    Description: Monta uma ISO local, localiza sources\install.wim ou sources\install.esd
    e mostra os indices/edicoes existentes usando DISM.

    ATENCAO:
    Este script e somente informativo. Ele nao copia arquivos, nao cria particoes,
    nao altera BCD, nao formata discos e nao modifica a ISO.

    Exemplos:
    powershell -ExecutionPolicy Bypass -File .\listar_edicoes_iso_windows.ps1
    powershell -ExecutionPolicy Bypass -File .\listar_edicoes_iso_windows.ps1 -IsoPath "C:\ISOS\Windows.iso"
#>

[CmdletBinding()]
param(
    [string]$IsoPath = ""
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
$ScriptVersao = "1.0"
$Log = Join-Path $PSScriptRoot "listar_edicoes_iso_windows.log"

function Initialize-PowerToolConsoleLayout {
    try {
        Add-Type @"
using System;
using System.Runtime.InteropServices;
public static class FlexITConsoleLayout {
    [DllImport("kernel32.dll")]
    public static extern IntPtr GetConsoleWindow();
    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
}
"@ -ErrorAction SilentlyContinue
        $handle = [FlexITConsoleLayout]::GetConsoleWindow()
        if ($handle -ne [IntPtr]::Zero) {
            [FlexITConsoleLayout]::ShowWindow($handle, 3) | Out-Null
            Start-Sleep -Milliseconds 250
        }
    } catch { }

    try {
        $raw = $Host.UI.RawUI
        $window = $raw.WindowSize
        $buffer = $raw.BufferSize
        if ($buffer.Width -lt $window.Width) {
            $buffer.Width = $window.Width
            $raw.BufferSize = $buffer
        }
    } catch { }
}

function Get-PowerToolWidth {
    try { return [Math]::Max(($Host.UI.RawUI.WindowSize.Width - 2), 96) } catch { return 120 }
}

function Write-PowerToolBorder {
    param([string]$Left = '+', [string]$Right = '+', [string]$Color = 'Cyan')
    Write-Host ('=' * ((Get-PowerToolWidth) + 2)) -ForegroundColor $Color
}

function Write-PowerToolSeparator {
    param([string]$Color = 'DarkGray')
    Write-Host ('-' * ((Get-PowerToolWidth) + 2)) -ForegroundColor $Color
}

function Write-PowerToolCenter {
    param([string]$Texto, [string]$Color = 'White')
    $width = Get-PowerToolWidth
    if ($null -eq $Texto) { $Texto = '' }
    if ($Texto.Length -gt $width) { $Texto = $Texto.Substring(0, $width - 3) + '...' }
    $left = [Math]::Max([Math]::Floor(($width - $Texto.Length) / 2), 0)
    $right = [Math]::Max($width - $Texto.Length - $left, 0)
    Write-Host (' ' + (' ' * $left) + $Texto + (' ' * $right) + ' ') -ForegroundColor $Color
}

function Write-PowerToolLine {
    param([string]$Campo, [string]$Valor, [string]$CorValor = 'White')
    $width = Get-PowerToolWidth
    $labelWidth = 16
    $valueWidth = [Math]::Max(($width - $labelWidth - 4), 24)
    if ($null -eq $Valor) { $Valor = '' }
    if ($null -eq $Campo) { $Campo = '' }
    $label = [string]$Campo
    if ($label.Length -gt $labelWidth) { $label = $label.Substring(0, $labelWidth - 1) + '.' }
    $texto = [string]$Valor
    if ($texto.Length -gt $valueWidth) { $texto = $texto.Substring(0, $valueWidth - 3) + '...' }
    Write-Host -NoNewline ('  {0,-16}' -f $label) -ForegroundColor DarkGray
    Write-Host -NoNewline ' : ' -ForegroundColor DarkGray
    Write-Host $texto -ForegroundColor $CorValor
}

function Write-Banner {
    Initialize-PowerToolConsoleLayout
    Clear-Host
    Write-Host ""
    Write-PowerToolBorder '+' '+' 'DarkCyan'
    Write-PowerToolCenter 'FLEXIT WINDOWS ISO INSPECTOR' 'Yellow'
    Write-PowerToolCenter 'Listar edicoes dentro da ISO' 'White'
    Write-PowerToolBorder '+' '+' 'DarkCyan'
    Write-PowerToolLine 'Operation' 'Inspecionar ISO Windows' 'Yellow'
    Write-PowerToolLine 'Modo' 'Somente leitura' 'Cyan'
    Write-PowerToolLine 'Automacao' 'Mount-DiskImage + DISM /Get-WimInfo' 'Green'
    Write-PowerToolLine 'Production' (Get-Date).Year 'Yellow'
    Write-PowerToolLine 'Copyright' 'Flex IT' 'Yellow'
    Write-PowerToolLine 'Versao' $ScriptVersao 'White'
    Write-PowerToolBorder '+' '+' 'DarkCyan'
    Write-Host ""
}

function Info($Mensagem) { Write-PowerToolLine 'INFO' $Mensagem 'Cyan' }
function Ok($Mensagem) { Write-PowerToolLine 'OK' $Mensagem 'Green' }
function Aviso($Mensagem) { Write-PowerToolLine 'AVISO' $Mensagem 'Yellow' }
function Erro($Mensagem) { Write-PowerToolLine 'ERRO' $Mensagem 'Red' }

function Write-Log {
    param([string]$Tipo, [string]$Mensagem)
    $linha = "{0} [{1}] {2}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Tipo, $Mensagem
    Add-Content -LiteralPath $Log -Value $linha -Encoding UTF8
}

function Select-IsoPath {
    param([string]$RequestedPath)

    if (-not [string]::IsNullOrWhiteSpace($RequestedPath)) {
        if (-not (Test-Path -LiteralPath $RequestedPath -PathType Leaf)) {
            throw "ISO informada nao existe: $RequestedPath"
        }
        return (Resolve-Path -LiteralPath $RequestedPath).Path
    }

    $isos = Get-ChildItem -LiteralPath $PSScriptRoot -Filter "*.iso" -File -ErrorAction SilentlyContinue |
        Sort-Object Name

    if (-not $isos -or $isos.Count -eq 0) {
        throw "Nenhuma ISO encontrada em $PSScriptRoot. Use -IsoPath para informar o caminho."
    }

    Write-PowerToolBorder '+' '+' 'DarkCyan'
    Write-PowerToolCenter 'ISOS DISPONIVEIS' 'Cyan'
    Write-PowerToolLine 'Folder' $PSScriptRoot 'Cyan'
    Write-PowerToolSeparator 'DarkCyan'

    for ($i = 0; $i -lt $isos.Count; $i++) {
        $gb = [Math]::Round(($isos[$i].Length / 1GB), 2)
        Write-PowerToolLine ("ISO {0}" -f ($i + 1)) ("{0} ({1} GB)" -f $isos[$i].Name, $gb) 'White'
    }
    Write-PowerToolBorder '+' '+' 'DarkCyan'

    do {
        $choice = Read-Host "Escolha a ISO pelo numero"
        $number = 0
        if ([int]::TryParse($choice, [ref]$number) -and $number -ge 1 -and $number -le $isos.Count) {
            return $isos[$number - 1].FullName
        }
        Aviso "Opcao invalida. Informe um numero entre 1 e $($isos.Count)."
    } while ($true)
}

function Get-MountedIsoRoot {
    param([string]$Path)

    Info "Montando ISO: $Path"
    $image = Mount-DiskImage -ImagePath $Path -PassThru -ErrorAction Stop
    Start-Sleep -Seconds 1

    $volume = $image | Get-Volume -ErrorAction Stop | Where-Object { $_.DriveLetter } | Select-Object -First 1
    if (-not $volume) {
        throw "A ISO foi montada, mas nenhuma letra de unidade foi encontrada."
    }

    $root = "$($volume.DriveLetter):\"
    Ok "ISO montada em $root"
    return $root
}

function Get-InstallImagePath {
    param([string]$IsoRoot)

    $wim = Join-Path $IsoRoot "sources\install.wim"
    $esd = Join-Path $IsoRoot "sources\install.esd"

    if (Test-Path -LiteralPath $wim -PathType Leaf) { return $wim }
    if (Test-Path -LiteralPath $esd -PathType Leaf) { return $esd }

    throw "Nao foi encontrado sources\install.wim nem sources\install.esd na ISO."
}

function Get-WindowsImageInfo {
    param([string]$ImagePath)

    Info "Lendo edicoes com DISM: $ImagePath"
    $output = & dism.exe /English /Get-WimInfo "/WimFile:$ImagePath" 2>&1
    $code = $LASTEXITCODE

    if ($code -ne 0) {
        $message = ($output | Select-Object -Last 20) -join "`n"
        throw "DISM retornou codigo $code.`n$message"
    }

    $items = New-Object System.Collections.Generic.List[object]
    $current = [ordered]@{}

    foreach ($line in $output) {
        $text = [string]$line
        if ($text -match '^\s*Index\s*:\s*(\d+)\s*$') {
            if ($current.Contains('Index')) {
                $items.Add([pscustomobject]$current)
            }
            $current = [ordered]@{ Index = [int]$matches[1]; Name = ''; Description = ''; Size = ''; Architecture = '' }
            continue
        }
        if (-not $current.Contains('Index')) { continue }

        if ($text -match '^\s*Name\s*:\s*(.+)$') { $current.Name = $matches[1].Trim(); continue }
        if ($text -match '^\s*Description\s*:\s*(.+)$') { $current.Description = $matches[1].Trim(); continue }
        if ($text -match '^\s*Size\s*:\s*(.+)$') { $current.Size = $matches[1].Trim(); continue }
        if ($text -match '^\s*Architecture\s*:\s*(.+)$') { $current.Architecture = $matches[1].Trim(); continue }
    }

    if ($current.Contains('Index')) {
        $items.Add([pscustomobject]$current)
    }

    return $items
}

function Show-WindowsImageInfo {
    param([object[]]$Images)

    if (-not $Images -or $Images.Count -eq 0) {
        throw "DISM executou, mas nenhuma edicao foi identificada."
    }

    Write-Host ""
    Write-PowerToolBorder '+' '+' 'DarkCyan'
    Write-PowerToolCenter 'EDICOES ENCONTRADAS NA ISO' 'Cyan'
    Write-PowerToolSeparator 'DarkCyan'

    foreach ($image in $Images) {
        Write-PowerToolLine ("Index {0}" -f $image.Index) $image.Name 'Yellow'
        if (-not [string]::IsNullOrWhiteSpace($image.Description)) {
            Write-PowerToolLine 'Descricao' $image.Description 'White'
        }
        if (-not [string]::IsNullOrWhiteSpace($image.Architecture)) {
            Write-PowerToolLine 'Arquitetura' $image.Architecture 'Cyan'
        }
        if (-not [string]::IsNullOrWhiteSpace($image.Size)) {
            Write-PowerToolLine 'Tamanho' $image.Size 'Green'
        }
        Write-PowerToolSeparator 'DarkGray'
    }

    Write-PowerToolBorder '+' '+' 'DarkCyan'
}

$mountedIso = $false
$mountedPath = ""

try {
    Write-Banner
    if (Test-Path -LiteralPath $Log -PathType Leaf) {
        Remove-Item -LiteralPath $Log -Force -ErrorAction SilentlyContinue
    }

    $selectedIso = Select-IsoPath -RequestedPath $IsoPath
    Info "ISO selecionada: $selectedIso"
    Write-Log "INFO" "ISO selecionada: $selectedIso"

    $mountedPath = Get-MountedIsoRoot -Path $selectedIso
    $mountedIso = $true
    Write-Log "OK" "ISO montada em $mountedPath"

    $installImage = Get-InstallImagePath -IsoRoot $mountedPath
    Ok "Imagem de instalacao encontrada: $installImage"
    Write-Log "OK" "Imagem encontrada: $installImage"

    $images = @(Get-WindowsImageInfo -ImagePath $installImage)
    Show-WindowsImageInfo -Images $images

    foreach ($image in $images) {
        Write-Log "IMAGE" ("Index={0}; Name={1}; Description={2}; Architecture={3}; Size={4}" -f $image.Index, $image.Name, $image.Description, $image.Architecture, $image.Size)
    }

    Write-Host ""
    Write-PowerToolBorder '+' '+' 'DarkCyan'
    Write-PowerToolLine 'Resultado' ("{0} edicao(oes) encontrada(s)" -f $images.Count) 'Green'
    Write-PowerToolLine 'Log' $Log 'Cyan'
    Write-PowerToolBorder '+' '+' 'Yellow'
} catch {
    Erro $_.Exception.Message
    Write-Log "ERRO" $_.Exception.Message
    Write-Host ""
    Write-PowerToolBorder '+' '+' 'Red'
    Write-PowerToolLine 'Process' 'Falhou' 'Red'
    Write-PowerToolLine 'Log' $Log 'Cyan'
    Write-PowerToolBorder '+' '+' 'Red'
    exit 1
} finally {
    if ($mountedIso -and -not [string]::IsNullOrWhiteSpace($selectedIso)) {
        try {
            Info "Desmontando ISO..."
            Dismount-DiskImage -ImagePath $selectedIso -ErrorAction SilentlyContinue | Out-Null
            Ok "ISO desmontada."
            Write-Log "OK" "ISO desmontada."
        } catch {
            Aviso "Nao foi possivel desmontar automaticamente: $($_.Exception.Message)"
            Write-Log "AVISO" "Failure ao desmontar: $($_.Exception.Message)"
        }
    }
}
