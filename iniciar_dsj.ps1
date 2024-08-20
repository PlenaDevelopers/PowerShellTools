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
$nome_pc = "dsj-01"
$endereco_pc = "Rua Oriente, 232"
$usuario_nome = 'Mega São José'

$senha_anydesk = 'S@0J0se2024'

$arquivo_wallpaper = "$PSScriptRoot\wallpaper\wallpaper_dsj.jpg"
$arquivo_fundo_logon = "$PSScriptRoot\wallpaper\wallpaper_dsj.jpg"
#----------------------------------------------------------------------------------------------

# Servidores de Terminal
#----------------------------------------------------------------------------------------------
$rdpItems = @(

)
#----------------------------------------------------------------------------------------------

# Obter o diretório do script atual
$CurrentScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path
#----------------------------------------------------------------------------------------------

# Atualizar Scripts
#----------------------------------------------------------------------
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_atualizar_script.ps1"
& $CabecalhoScriptPath
#----------------------------------------------------------------------
Write-Host

# Backup do Sistema
#----------------------------------------------------------------------
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_init_backup.ps1"
& $CabecalhoScriptPath
#----------------------------------------------------------------------
Write-Host

# Reparar Desktop
#----------------------------------------------------------------------
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_rep_desktop.ps1"
& $CabecalhoScriptPath
#----------------------------------------------------------------------
Write-Host

# Limpar Arquivos Temporários
#----------------------------------------------------------------------
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_rem_arquivos_temporarios.ps1"
& $CabecalhoScriptPath
#----------------------------------------------------------------------
Write-Host

# Definir Servidor NTP
#----------------------------------------------------------------------
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_def_servidor_ntp.ps1"
& $CabecalhoScriptPath
#----------------------------------------------------------------------
Write-Host

# Remover blocos dinâmicos
#----------------------------------------------------------------------
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_rem_blocos_dinamicos.ps1"
& $CabecalhoScriptPath
#----------------------------------------------------------------------
Write-Host

# Restaurar cores do Tema
#----------------------------------------------------------------------
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_tema_restaura_cores.ps1"
& $CabecalhoScriptPath
#----------------------------------------------------------------------
Write-Host

# Remover histórico de cores do Tema
#----------------------------------------------------------------------
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_tema_remove_historico.ps1"
& $CabecalhoScriptPath
#----------------------------------------------------------------------
Write-Host

# Restaurar Wallpaper
#----------------------------------------------------------------------
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_tema_restaura_wallpaper.ps1"
& $CabecalhoScriptPath
#----------------------------------------------------------------------
Write-Host

# Definir informações de suporte
#----------------------------------------------------------------------
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_def_suporte.ps1"
& $CabecalhoScriptPath
#----------------------------------------------------------------------
Write-Host

# Renomear primario
#----------------------------------------------------------------------
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_def_nome_disco_c.ps1"
& $CabecalhoScriptPath
#----------------------------------------------------------------------
Write-Host

# Renomear secundário
#----------------------------------------------------------------------
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_def_nome_disco_d.ps1"
& $CabecalhoScriptPath
#----------------------------------------------------------------------
Write-Host

# Definir plano de energia
#----------------------------------------------------------------------
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_def_plano_energia.ps1"
& $CabecalhoScriptPath
#----------------------------------------------------------------------
Write-Host

# Definir Barra de Pesquisa
#----------------------------------------------------------------------
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_def_barra_pesquisa.ps1"
& $CabecalhoScriptPath
#----------------------------------------------------------------------
Write-Host

# Definir Barra de News
#----------------------------------------------------------------------
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_def_barra_news.ps1"
& $CabecalhoScriptPath
#----------------------------------------------------------------------
Write-Host

# Definir Wallpaer
#----------------------------------------------------------------------
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_def_desktop_fundo.ps1"
& $CabecalhoScriptPath -imagem $arquivo_wallpaper
#----------------------------------------------------------------------
Write-Host

# Definir Fundo da tela de logon
#----------------------------------------------------------------------
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_def_fundo_logon.ps1"
& $CabecalhoScriptPath -imagem $arquivo_fundo_logon
#----------------------------------------------------------------------
Write-Host

# Mostrar/Ocultar a versão do Windows no Desktop
#----------------------------------------------------------------------
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_def_desktop_versao.ps1"
& $CabecalhoScriptPath -imagem $arquivo_fundo_logon
#----------------------------------------------------------------------
Write-Host

# Definir cor de fundo do Desktop
#----------------------------------------------------------------------
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_def_desktop_cor.ps1"
& $CabecalhoScriptPath
#----------------------------------------------------------------------
Write-Host

# Definir o nome do computador
#----------------------------------------------------------------------
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_def_computador_nome.ps1"
& $CabecalhoScriptPath -nome_pc $nome_pc
#----------------------------------------------------------------------
Write-Host

# Corrigir Bug de impressora
#----------------------------------------------------------------------
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_rep_bug_impressora_1.ps1"
& $CabecalhoScriptPath -nome_pc $nome_pc
#----------------------------------------------------------------------
Write-Host

# Corrigir erro de Criptografia CredSSP
#----------------------------------------------------------------------
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_rep_criptografia_credssp.ps1"
& $CabecalhoScriptPath -nome_pc $nome_pc
#----------------------------------------------------------------------
Write-Host

# Corrigir erro de logns inseguros
#----------------------------------------------------------------------
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_rep_logons_inseguros.ps1"
& $CabecalhoScriptPath -nome_pc $nome_pc
#----------------------------------------------------------------------
Write-Host

# Habilitar "Visualizador de Imagens Clássico"
#----------------------------------------------------------------------
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_def_visualizador_imagens.ps1"
& $CabecalhoScriptPath -nome_pc $nome_pc
#----------------------------------------------------------------------
Write-Host

# Habilitar "Visualização da extensão dos arquivo"
#----------------------------------------------------------------------
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_def_arquivos_extensoes.ps1"
& $CabecalhoScriptPath -nome_pc $nome_pc
#----------------------------------------------------------------------
Write-Host

# Atualizar o Net. Framework
#----------------------------------------------------------------------
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_atualizar_framework.ps1"
& $CabecalhoScriptPath -nome_pc $nome_pc
#----------------------------------------------------------------------
Write-Host

# Atualizar o Visual C Runtimes
#----------------------------------------------------------------------
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_atualizar_runtime.ps1"
& $CabecalhoScriptPath -nome_pc $nome_pc
#----------------------------------------------------------------------
Write-Host

# Definir Serviço - Spooler
#----------------------------------------------------------------------
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_def_servico_spooler.ps1"
& $CabecalhoScriptPath -nome_pc $nome_pc
#----------------------------------------------------------------------
Write-Host

# Definir Serviço - Registro Remoto
#----------------------------------------------------------------------
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_def_servico_registro_remoto.ps1"
& $CabecalhoScriptPath -nome_pc $nome_pc
#----------------------------------------------------------------------
Write-Host

# Definir Serviço - Temas
#----------------------------------------------------------------------
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_def_servico_temas.ps1"
& $CabecalhoScriptPath -nome_pc $nome_pc
#----------------------------------------------------------------------
Write-Host

# Definir Serviço - Link Distribuido
#----------------------------------------------------------------------
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_def_servico_link_distribuido.ps1"
& $CabecalhoScriptPath -nome_pc $nome_pc
#----------------------------------------------------------------------
Write-Host

# Definir Protocolo DHCP
#----------------------------------------------------------------------
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_def_protocolo_dhcp.ps1"
& $CabecalhoScriptPath -nome_pc $nome_pc
#----------------------------------------------------------------------
Write-Host

# Desabilitar o "Protocolo IPv6"
#----------------------------------------------------------------------
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_def_protocolo_ipv6.ps1"
& $CabecalhoScriptPath -nome_pc $nome_pc
#----------------------------------------------------------------------
Write-Host

# Alterar o Local da Rede - Privada
#----------------------------------------------------------------------
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_def_local_rede.ps1"
& $CabecalhoScriptPath -nome_pc $nome_pc
#----------------------------------------------------------------------
Write-Host

# Compartilhar Pasta
#----------------------------------------------------------------------
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_def_compartilhamento.ps1"
& $CabecalhoScriptPath -nome_pc $nome_pc
#----------------------------------------------------------------------
Write-Host

# Suporte a Compartilhamentos de Arquivos SMBv1
#----------------------------------------------------------------------
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_def_smbv1.ps1"
& $CabecalhoScriptPath -nome_pc $nome_pc
#----------------------------------------------------------------------
Write-Host

# Remover aplicativos pré-instalados
#----------------------------------------------------------------------
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_rem_app.ps1"
& $CabecalhoScriptPath -nome_pc $nome_pc
#----------------------------------------------------------------------
Write-Host

# Definir agrupamentode ícones no deskto
#----------------------------------------------------------------------
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_def_desktop_autoarrage.ps1"
& $CabecalhoScriptPath -nome_pc $nome_pc
#----------------------------------------------------------------------
Write-Host

# Alterar senha do anydesk
#----------------------------------------------------------------------
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_def_anydesk_senha.ps1"
& $CabecalhoScriptPath -Senha $senha_anydesk
#----------------------------------------------------------------------
Write-Host

# Alterar nome do usuário atual
#----------------------------------------------------------------------
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_def_usuario_nome.ps1"
& $CabecalhoScriptPath -valor $usuario_nome
#----------------------------------------------------------------------
Write-Host

# Ativar Windows
#----------------------------------------------------------------------
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_ativar_windows.ps1"
& $CabecalhoScriptPath
#----------------------------------------------------------------------
Write-Host

# Ativar Office
#----------------------------------------------------------------------
$CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_ativar_Office.ps1"
& $CabecalhoScriptPath
#----------------------------------------------------------------------
Write-Host

# Atalhos para servidor RDP
#----------------------------------------------------------------------
# Loop para iterar sobre cada par e chamar o script
foreach ($item in $rdpItems) {
    $nomeArquivoRdp = $item["nome_arquivo_rdp"]
    $rdpServer = $item["rdp_server"]

    # Chamada ao script com as variáveis atuais
    $CabecalhoScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_def_arquivo_rdp.ps1"
    & $CabecalhoScriptPath -nome_arquivo_rdp $nomeArquivoRdp -rdp_server $rdpServer
    }
#----------------------------------------------------------------------

# Aplicando alterações
#----------------------------------------------------------------------------------------------
# Aplicar alterações
rundll32.exe user32.dll, UpdatePerUserSystemParameters

# Verificar se o processo explorer está em execução
$explorerProcess = Get-Process -Name explorer -ErrorAction SilentlyContinue

if ($explorerProcess) {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Reiniciando Processo") -NoNewline
    Write-Host ("{0,-86} " -f "Windows Explorer") -NoNewline -ForegroundColor Cyan
    Write-Host "║" -ForegroundColor Cyan
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
} else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Iniciando Processo") -NoNewline
    Write-Host ("{0,-86} " -f "Windows Explorer") -NoNewline -ForegroundColor Cyan
    Write-Host "║" -ForegroundColor Cyan
    Start-Process explorer -WindowStyle Hidden
}
#----------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------

# Rodape
#----------------------------------------------------------------------------------------------
Write-Host "╠" -NoNewline -ForegroundColor Cyan
Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
Write-Host "╣" -ForegroundColor Cyan  

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Processo") -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-86} " -f "Finalizado") -NoNewline -ForegroundColor Cyan
Write-Host "║" -ForegroundColor Cyan

Write-Host "╚" -NoNewline -ForegroundColor Cyan
Write-Host ("═" * 120) -NoNewline -ForegroundColor Cyan
Write-Host "╝" -ForegroundColor Cyan
#----------------------------------------------------------------------------------------------