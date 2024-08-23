<#
	Copyright: © Plena Soluções - 2024
	Date: Agosto/2024

	Licenciamento:
	Este script é fornecido "como está", sem qualquer garantia de qualquer tipo,
	expressa ou implícita, incluindo, mas não se limitando às garantias de 
	comercialização, adequação a um determinado fim e não violação. O uso deste 
	script é totalmente gratuito, mas você deve manter os créditos ao autor original.
	
	Seriais/Keys:
	Os Seriais/Keys para licenciamento de software contidos neste ou em outros
	arquivos são meramente ilustrativos para a utilização do script, sendo assim cabe
	ao utilizador do script alterar estas chaves para uma válida que represente o 
	licenciamento vigente.

	Bugs & Correções
	Em caso de Bugs encontrado pedimos a gentileza de informar por email para que possamos 
	analizar e gerar atualizações corretivas.

	Autor: Evandro Campanhã
	Contato: aurora.erp@gmail.com
	------------------------------------------------------------------------------
#>

# Verifica se o script está sendo executado como administrador
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    # Se não estiver sendo executado como administrador, reinicia como administrador
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`"" -Verb RunAs
    exit
}
clear

# Definir a largura e altura desejadas da janela do console
$largura = 124
$altura = 40

# Ajustar o tamanho da janela do console
[System.Console]::SetWindowSize($largura, $altura)

# Importa a função da API do Windows para mover a janela
Add-Type @"
using System;
using System.Runtime.InteropServices;

public class ConsoleUtils
{
    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern IntPtr GetConsoleWindow();

    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);

    public static readonly IntPtr HWND_TOP = IntPtr.Zero;
    public const uint SWP_NOSIZE = 0x0001;
    public const uint SWP_NOZORDER = 0x0004;
}
"@

# Obtém a janela do console
$hWnd = [ConsoleUtils]::GetConsoleWindow()

# Define a posição desejada (topo e esquerda da tela)
$x = 0
$y = 0
$largura = [System.Console]::WindowWidth
$altura = [System.Console]::WindowHeight

# Move a janela do console
[ConsoleUtils]::SetWindowPos($hWnd, [ConsoleUtils]::HWND_TOP, $x, $y, 0, 0, [ConsoleUtils]::SWP_NOSIZE -bor [ConsoleUtils]::SWP_NOZORDER)

# Altera o diretório para o local onde o script está localizado
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir

# Listar todos os arquivos .ps1 no diretório atual que começam com "iniciar_"
$files = Get-ChildItem -Path . -Filter "iniciar_*.ps1"

# Verificar se há arquivos correspondentes
if ($files.Count -eq 0) {
    Write-Host "Nenhum arquivo encontrado com o padrão 'iniciar_*.ps1'."
    exit
}

# Criar um array para armazenar as opções
$options = @()

# Loop para extrair o nome dos arquivos e adicionar ao array de opções
foreach ($file in $files) {
    # Remover "iniciar_" e ".ps1" do nome do arquivo
    $name = $file.BaseName.Replace("iniciar_", "").Replace("_", " ").ToUpper()
    $options += $name
}
clear
# Cabeçalho
#----------------------------------------------------------------------------------------------
Write-Host "╔" -NoNewline -ForegroundColor Yellow -BackgroundColor Black
write-host ("═" * 120) -NoNewline -ForegroundColor Yellow
write-host "╗" -ForegroundColor Yellow  

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-119} " -f "Scripts") -NoNewline -ForegroundColor Cyan
Write-Host "║" -ForegroundColor Cyan

Write-Host "╚" -NoNewline -ForegroundColor Cyan
Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
Write-Host "╝" -ForegroundColor Cyan
#----------------------------------------------------------------------------------------------

# Exibir as opções para o usuário
#----------------------------------------------------------------------------------------------
for ($i = 0; $i -lt $options.Length; $i++) {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-2} : " -f $($i+1)) -NoNewline
    Write-Host ("{0,-114} " -f $($options[$i])) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
}
#----------------------------------------------------------------------------------------------

# Solicitar ao usuário que selecione uma opção
#$selection = Read-Host "Selecione uma opção digitando o número correspondente"


        Write-Host "╔" -NoNewline -ForegroundColor Yellow -BackgroundColor Black
        write-host ("═" * 120) -NoNewline -ForegroundColor Yellow
        write-host "╗" -ForegroundColor Yellow  

        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-114} : " -f ($selection = Read-Host "Selecione uma opção digitando o número correspondente")) -NoNewline -ForegroundColor white
        Write-Host ("{0,-2} " -f "Arquivo não encontrado") -NoNewline -ForegroundColor red
        Write-Host "║" -ForegroundColor Cyan

        Write-Host "╚" -NoNewline -ForegroundColor Cyan
        Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
        Write-Host "╝" -ForegroundColor Cyan

# Validar a entrada do usuário
if ($selection -match '^\d+$' -and $selection -gt 0 -and $selection -le $options.Length) {
    $selectedOption = $options[$selection - 1]
    # Encontrar o arquivo correspondente e executar o script
    $scriptToRun = $files | Where-Object { $_.BaseName.Replace("iniciar_", "").Replace("_", " ").ToUpper() -eq $selectedOption }
    if ($scriptToRun) {
        Write-Host "Executando $($scriptToRun.Name)..."
        & .\$($scriptToRun.Name)
    } else {
        Write-Host "╔" -NoNewline -ForegroundColor Yellow -BackgroundColor Black
        write-host ("═" * 120) -NoNewline -ForegroundColor Yellow
        write-host "╗" -ForegroundColor Yellow  

        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Status") -NoNewline -ForegroundColor white
        Write-Host ("{0,-86} " -f "Arquivo não encontrado") -NoNewline -ForegroundColor red
        Write-Host "║" -ForegroundColor Cyan

        Write-Host "╚" -NoNewline -ForegroundColor Cyan
        Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
        Write-Host "╝" -ForegroundColor Cyan
    }
} else {
        Write-Host "╔" -NoNewline -ForegroundColor Yellow -BackgroundColor Black
        write-host ("═" * 120) -NoNewline -ForegroundColor Yellow
        write-host "╗" -ForegroundColor Yellow  

        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Status") -NoNewline -ForegroundColor white
        Write-Host ("{0,-86} " -f "Seleção inválida") -NoNewline -ForegroundColor red
        Write-Host "║" -ForegroundColor Cyan

        Write-Host "╚" -NoNewline -ForegroundColor Cyan
        Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
        Write-Host "╝" -ForegroundColor Cyan
}
