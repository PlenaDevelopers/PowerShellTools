#requires -version 5.1
<#
    Copyright: (c) Flex IT - 2026
    Function: Limpar Boot Menu FlexIT
    Description: Remove entradas antigas FlexIT criadas no Windows Boot Manager e restaura timeout padrao.
#>

$ErrorActionPreference = "Stop"

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

function Invoke-BcdEdit {
    param([string[]]$ArgumentList)
    $processo = Start-Process -FilePath "bcdedit.exe" -ArgumentList $ArgumentList -Wait -PassThru -NoNewWindow
    if ($processo.ExitCode -ne 0) {
        throw "bcdedit retornou codigo $($processo.ExitCode). Argumentos: $($ArgumentList -join ' ')"
    }
}

function Get-FlexITBootEntryIds {
    $saida = & bcdedit.exe /enum all
    if ($LASTEXITCODE -ne 0) {
        throw "Nao foi possivel listar o BCD."
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

    $ids = @()
    foreach ($bloco in $blocos) {
        $texto = ($bloco -join "`n")
        if ($texto -notmatch 'FlexIT') { continue }
        $match = [regex]::Match($texto, $guidPattern)
        if ($match.Success) { $ids += $match.Value }
    }

    return @($ids | Where-Object { $_ -notin @("{bootmgr}", "{current}", "{default}") } | Select-Object -Unique)
}

try {
    Assert-Admin
    Write-Host "==============================================================" -ForegroundColor Magenta
    Write-Host " FLEXIT - LIMPEZA DO BOOT MENU" -ForegroundColor White
    Write-Host "==============================================================" -ForegroundColor Magenta

    $ids = @(Get-FlexITBootEntryIds)
    if ($ids.Count -eq 0) {
        Ok "Nenhuma entrada FlexIT encontrada no boot menu."
    } else {
        foreach ($id in $ids) {
            Aviso "Removendo entrada FlexIT: $id"
            Invoke-BcdEdit -ArgumentList @("/delete", $id, "/f")
        }
        Ok "$($ids.Count) entrada(s) FlexIT removida(s)."
    }

    try { Invoke-BcdEdit -ArgumentList @("/displayorder", "{current}", "/addfirst") } catch { Aviso $_.Exception.Message }
    try { Invoke-BcdEdit -ArgumentList @("/timeout", "3") } catch { Aviso $_.Exception.Message }
    Ok "Boot menu ajustado."
} catch {
    Write-Host "[ERRO] $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
