<#
    Função: Alterar o nome do usuário atual
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
param (
    [string]$valor = "Desconhecido"
)
# Cabeçalho
#----------------------------------------------------------------------------------------------
# Obter o diretório do script atual
$scriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path -Parent

# Obter o nome do script atual
$scriptName = [System.IO.Path]::GetFileName($MyInvocation.MyCommand.Path)

# Construir o caminho completo para o script 'scp_script_cabecalho.ps1'
$cabecalhoScriptPath = Join-Path -Path $scriptDirectory -ChildPath "scp_script_cabecalho.ps1"

# Executar o script de cabeçalho
& $cabecalhoScriptPath -Script $scriptName -Titulo "Alterar o nome do usuário atual"
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
    Write-Host ("{0,-30} : " -f "Usuário Atual") -NoNewline
    Write-Host ("{0,-86} " -f $nomeUsuarioAtual) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan

    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Novo Usuário") -NoNewline
    Write-Host ("{0,-86} " -f $valor) -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan

    # Define o novo nome completo para o usuário local
    $usuarioLocal.InvokeSet("FullName", $valor)
    $usuarioLocal.CommitChanges()
} catch {

}
#----------------------------------------------------------------------------------------------

# Aplicando alterações
#----------------------------------------------------------------------------------------------
rundll32.exe user32.dll, UpdatePerUserSystemParameters
#----------------------------------------------------------------------------------------------

# Rodapé
#----------------------------------------------------------------------------------------------
# Obter o diretório do script atual
$CurrentScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path -Parent

# Construir o caminho completo para o script 'scp_script_rodape.ps1'
$rodapeScriptPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "scp_script_rodape.ps1"

# Executar o script de rodapé
& $rodapeScriptPath
#----------------------------------------------------------------------------------------------