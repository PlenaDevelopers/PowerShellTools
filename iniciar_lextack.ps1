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

# Cabeçalho
#----------------------------------------------------------------------------------------------
Write-Host "╔" -NoNewline -ForegroundColor Yellow -BackgroundColor Black
write-host ("═" * 120) -NoNewline -ForegroundColor Yellow
write-host "╗" -ForegroundColor Yellow  

Write-Host "║" -NoNewline -ForegroundColor Yellow
Write-Host ("{0,-30} : " -f " Iniciar") -NoNewline
Write-Host ("{0,-86} " -f "Script de configuração") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Yellow

Write-Host "║" -NoNewline -ForegroundColor Yellow
Write-Host ("{0,-30} : " -f " Cliente Mega São José") -NoNewline
Write-Host ("{0,-86} " -f "Script de configuração") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Yellow

Write-Host "║" -NoNewline -ForegroundColor Yellow
Write-Host ("{0,-30} : " -f " Copyright") -NoNewline
Write-Host ("{0,-86} " -f "2023 - Evandro Campanhã") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Yellow

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Script") -NoNewline
Write-Host ("{0,-86} " -f $MyInvocation.MyCommand.Path) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

$computerName = (Get-ComputerInfo).CsName
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Computador") -NoNewline
Write-Host ("{0,-86} " -f $computerName) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

Write-Host "╚" -NoNewline -ForegroundColor Yellow
write-host ("═" * 120) -NoNewline -ForegroundColor Yellow
write-host "╝" -ForegroundColor Yellow
#----------------------------------------------------------------------------------------------

# Parametros
#----------------------------------------------------------------------------------------------
$nome_pc = "apex-filial-01"
$endereco_pc = "Rua 25 de Marco, 267"
$nome_arquivo_rdp = "Servidor Lextack.rdp"
$rdp_server = "l-server-01.lextack.local.net"
$perfil_usuario = $env:USERPROFILE
$usuario_nome = 'Lextack Presentes'
$chave_windows = "W269N-WFGWX-YVC9B-4J6C9-T83GX"
$senha_anydesk = 'Lext@ck2024'
$arquivo_wallpaper = "$PSScriptRoot\wallpaper\wallpaper_lextack.jpg"
$arquivo_fundo = "$PSScriptRoot\wallpaper\wallpaper_lextack.jpg"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
& .\scp_atualizar_script.ps1
Write-Host
& .\scp_rep_desktop.ps1
Write-Host

$nome_arquivo_rdp = "Lextack.rdp"
$rdp_server = "192.168.130.202"
& .\scp_def_arquivo_rdp.ps1 -nome_arquivo_rdp $nome_arquivo_rdp -rdp_server $rdp_server

& .\scp_rem_arquivos_temporarios.ps1
Write-Host 
& .\scp_def_servidor_ntp.ps1
Write-Host
& .\scp_init_backup.ps1
Write-Host
& .\scp_rem_blocos_dinamicos.ps1
Write-Host
& .\scp_tema_restaura_cores.ps1
Write-Host
& .\scp_tema_remove_historico
Write-Host
& .\scp_tema_restaura_wallpaper
Write-Host
& .\scp_def_suporte.ps1
Write-Host
& .\scp_def_nome_disco_c.ps1
Write-Host
& .\scp_def_nome_disco_d.ps1
Write-Host
& .\scp_def_plano_energia.ps1
Write-Host
& .\scp_def_barra_pesquisa.ps1
Write-Host
& .\scp_def_barra_news.ps1
Write-Host
& .\scp_def_desktop_fundo.ps1 -wallpaper $wallpaper
Write-Host
& .\scp_def_fundo_logon.ps1 -imagemCaminho $imagemCaminho
Write-Host
& .\scp_def_desktop_versao.ps1
Write-Host
& .\scp_def_desktop_cor.ps1
Write-Host
& .\scp_def_computador_nome.ps1 -nome_pc $nome_pc
Write-Host
& .\scp_rep_bug_impressora_1.ps1
Write-Host
& .\scp_rep_criptografia_credssp.ps1
Write-Host
& .\scp_rep_logons_inseguros.ps1
Write-Host
& .\scp_def_visualizador_imagens.ps1
Write-Host
& .\scp_atualizar_framework.ps1
Write-Host
& .\scp_atualizar_runtime.ps1
Write-Host
& .\scp_def_arquivos_extensoes.ps1
Write-Host
& .\scp_def_servico_spooler.ps1
Write-Host
& .\scp_def_servico_registro_remoto.ps1
Write-Host
& .\scp_def_servico_temas.ps1
Write-Host
& .\scp_def_servico_link_distribuido.ps1
Write-Host
& .\scp_def_protocolo_dhcp.ps1
Write-Host
& .\scp_def_protocolo_ipv6.ps1
Write-Host
& .\scp_def_local_rede.ps1
Write-Host
& .\scp_def_compartilhamento.ps1
Write-Host
& .\scp_rem_app.ps1
Write-Host
& .\scp_def_smbv1.ps1
Write-Host
& .\scp_def_anydesk_senha -UnattendedPassword $senha_anydesk
Write-Host
& .\scp_def_usuario_nome -valor $usuario_nome
Write-Host
& .\scp_ativar_windows.ps1
Write-Host
& .\scp_ativar_Office.ps1
#----------------------------------------------------------------------------------------------

# Rodape
#----------------------------------------------------------------------------------------------
Write-Host "╠" -NoNewline -ForegroundColor Cyan
Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
Write-Host "╣" -ForegroundColor Cyan  

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Processo") -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-86} " -f "Finalizado") -NoNewline -ForegroundColor Cyan
Write-Host "║" -ForegroundColor Cyan

Write-Host "╚" -NoNewline -ForegroundColor Cyan
Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
Write-Host "╝" -ForegroundColor Cyan