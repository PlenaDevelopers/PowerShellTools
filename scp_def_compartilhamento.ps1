<#
    Função: Cria uma pasta compartilhada
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

# Cabeçalho
#----------------------------------------------------------------------------------------------
# Obter o diretório do script atual
$scriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path -Parent

# Obter o nome do script atual
$scriptName = [System.IO.Path]::GetFileName($MyInvocation.MyCommand.Path)

# Construir o caminho completo para o script 'scp_script_cabecalho.ps1'
$cabecalhoScriptPath = Join-Path -Path $scriptDirectory -ChildPath "scp_script_cabecalho.ps1"

# Executar o script de cabeçalho
& $cabecalhoScriptPath -Script $scriptName -Titulo "Criar uma pasta compartilhada"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
# Definir a pasta e o nome da pasta
$pasta = "c:\transferencias"
$nomePasta = Split-Path -Path $pasta -Leaf
$compartilhamentoNome = $nomePasta
$caminhoCompleto = "\\$($env:COMPUTERNAME)\$nomePasta"

# Alterar o registro para permitir que 'Everyone' inclua 'Anonymous' (everyoneincludesanonymous)
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name 'everyoneincludesanonymous' -Value 1

# Alterar o registro para restringir o acesso a sessões nulas (restrictnullsessaccess)
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters' -Name 'restrictnullsessaccess' -Value 0

# Criar a pasta se não existir
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Local") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f $pasta) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Pasta") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f $nomePasta) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Compartilhamento") -NoNewline -ForegroundColor White
Write-Host ("{0,-86} " -f $caminhoCompleto) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor gray
Write-Host "║" -ForegroundColor Cyan
if (-not (Test-Path $pasta -PathType Container)) {
    $null = New-Item -Path $pasta -ItemType Directory -ErrorAction SilentlyContinue
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Pasta") -NoNewline
    Write-Host ("{0,-86} " -f "Uma nova pasta foi criada em $($pasta)") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan
}
else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Pasta") -NoNewline
    Write-Host ("{0,-86} " -f "A pasta $($pasta) já existia") -NoNewline -ForegroundColor Yellow
    Write-Host "║" -ForegroundColor Cyan
}

# Criar ou atualizar permissões
try {
    $acl = Get-Acl -Path $pasta
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule("Todos", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
    
    if ($acl.Access | Where-Object { $_.IdentityReference -eq "Todos" }) {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Acesso") -NoNewline -ForegroundColor White
        Write-Host ("{0,-86} " -f "Todos") -NoNewline -ForegroundColor cyan
        Write-Host "║" -ForegroundColor Cyan
        $acl.ModifyAccessRule("Set", $rule, 0)
    }
    else {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Tarefa") -NoNewline -ForegroundColor White
        Write-Host ("{0,-86} " -f "Aplicando Permissões") -NoNewline -ForegroundColor cyan
        Write-Host "║" -ForegroundColor Cyan
        $acl.AddAccessRule($rule)
    }
    Set-Acl -Path $pasta -AclObject $acl
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Permissões") -NoNewline
    Write-Host ("{0,-86} " -f "Permissões aplicadas com sucesso") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan
}
catch {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Permissões") -NoNewline
    Write-Host ("{0,-86} " -f "Erro ao aplicar permissões") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
}

$FilesAndFolders = gci $pasta -recurse | % { $_.FullName }
foreach ($FileAndFolder in $FilesAndFolders) {
    #using get-item instead because some of the folders have '[' or ']' character and Powershell throws exception trying to do a get-acl or set-acl on them.
    $item = gi -literalpath $FileAndFolder 
    $acl = $item.GetAccessControl() 
    $permission = "Everyone", "FullControl", "Allow"
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission
    $acl.SetAccessRule($rule)
    $item.SetAccessControl($acl)
}

$compartilhamentoExistente = Get-SmbShare | Where-Object { $_.Name -eq $compartilhamentoNome }
if ($compartilhamentoExistente) {
    Remove-SmbShare -Name $compartilhamentoNome -Force
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Compartilhamento") -NoNewline
    Write-Host ("{0,-86} " -f "O compartilhamento $($caminhoCompleto) foi removido") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan
}
else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Compartilhamento") -NoNewline
    Write-Host ("{0,-86} " -f "O compartilhamento $($caminhoCompleto) não existia") -NoNewline -ForegroundColor Yellow
    Write-Host "║" -ForegroundColor Cyan
}

$compartilhamentoACL = New-Object System.Security.AccessControl.FileSystemAccessRule("Todos", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
$compartilhamento = New-SmbShare -Name $compartilhamentoNome -Path $pasta -FullAccess "Todos"

$compartilhamentoExistente = Get-SmbShare | Where-Object { $_.Name -eq $compartilhamentoNome }
if ($compartilhamentoExistente) {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Compartilhamento") -NoNewline
    Write-Host ("{0,-86} " -f "O compartilhamento $($caminhoCompleto) foi criado") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan
}
else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Compartilhamento") -NoNewline
    Write-Host ("{0,-86} " -f "O compartilhamento $($caminhoCompleto) não foi criado") -NoNewline -ForegroundColor Red
    Write-Host "║" -ForegroundColor Cyan
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