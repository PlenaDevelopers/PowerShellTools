# Script que altera o nome do usuário atual
param (
    [string]$valor = "Desconhecido"
)

# Cabeçalho
#----------------------------------------------------------------------------------------------
Write-Host "╔" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
write-host "╗" -ForegroundColor Cyan  

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Configurar") -NoNewline
Write-Host ("{0,-86} " -f "Nome do Usuário") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Copyright") -NoNewline
Write-Host ("{0,-86} " -f "2023 - Evandro Campanhã") -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f " Script") -NoNewline
Write-Host ("{0,-86} " -f $MyInvocation.MyCommand.Path) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

Write-Host "╠" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
write-host "╣" -ForegroundColor Cyan
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
try {
    # Obtém o nome do usuário atual no formato de SamAccountName
    $nomeUsuarioAtual = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name.Split('\')[-1]

    # Obtém o objeto de diretório de usuários locais
    $localUsuarios = [System.DirectoryServices.DirectoryEntry]::new("WinNT://$env:COMPUTERNAME")

    # Encontra o objeto de usuário atual
    $usuarioLocal = $localUsuarios.Children | Where-Object { $_.SchemaClassName -eq 'User' -and $_.Name -eq $nomeUsuarioAtual }

    # Verifica se o usuário local foi encontrado
    if ($usuarioLocal -eq $null) {
        Write-Host "Usuário local não encontrado. Verifique se o script está sendo executado com privilégios elevados."
        exit
    }
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Usuário Atual") -NoNewline
    Write-Host ("{0,-86} " -f $nomeUsuarioAtual) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan

    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f " Novo Usuário") -NoNewline
    Write-Host ("{0,-86} " -f $valor) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan

    # Define o novo nome completo para o usuário local
    $usuarioLocal.InvokeSet("FullName", $valor)
    $usuarioLocal.CommitChanges()
} catch {

}
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
