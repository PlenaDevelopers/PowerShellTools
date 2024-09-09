<#
    Função: Instalar Fontes
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
    [string]$fontDirectory = "D:\perfil\OneDrive\Documents\Projeto Powershell\script\PowerShellTools\fontes",  # Caminho da pasta onde as fontes estão localizadas
    [string]$scope = "current"  # Escopo de instalação: "current" para usuário atual, "all" para todos os usuários
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
& $cabecalhoScriptPath -Script $scriptName -Titulo "Instalar Fontes"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
# Informa o nome da fonte
function Get-FontName {
    param (
        [string]$fontFilePath  # Caminho completo do arquivo de fonte
    )

    # Verifica se o arquivo de fonte existe
    if (-not (Test-Path $fontFilePath)) {
        Write-Host "Arquivo de fonte não encontrado: $fontFilePath" -ForegroundColor Red
        return
    }

    try {
        # Carrega o tipo de fonte usando .NET
        Add-Type -AssemblyName System.Drawing

        # Cria um objeto Font usando o arquivo de fonte
        $fontCollection = New-Object System.Drawing.Text.PrivateFontCollection
        $fontCollection.AddFontFile($fontFilePath)
        $fontFamily = $fontCollection.Families[0]

        # Obtém o nome da fonte
        return $fontFamily.Name
    } catch {
        Write-Host "Erro ao obter o nome da fonte: $_" -ForegroundColor Red
    }
}

# Verifica se o diretório informado existe
if (-not (Test-Path -Path $fontDirectory)) {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Erro") -NoNewline
    Write-Host ("{0,-86} " -f "A pasta informada não foi encontrada") -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan

    exit
}

# Função para instalar a fonte
function Install-Font {
    param (
        [string]$fontPath,  # Caminho completo da fonte
        [string]$scope      # Escopo de instalação
    )

    $fontFileName = [System.IO.Path]::GetFileNameWithoutExtension($fontPath)

    # Obtém o nome da família da fonte usando a função Get-FontName
    $fontFamilyName = Get-FontName -fontFilePath $fontPath

    try {
        if ($scope -eq "all") {
            # Instala para todos os usuários
            Write-Host "║" -NoNewline -ForegroundColor Cyan
            Write-Host ("{0,-30} : " -f "Instalando (Todos)") -NoNewline
            Write-Host ("{0,-86} " -f "$fontFileName ($fontFamilyName)") -NoNewline -ForegroundColor White
            Write-Host "║" -ForegroundColor Cyan

            $destination = "$env:WINDIR\Fonts\$($fontFileName).ttf"
            $null = Copy-Item $fontPath -Destination $destination -Force -ErrorAction SilentlyContinue
            $regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
            $null = Set-ItemProperty -Path $regPath -Name "$fontFileName (TrueType)" -Value "$fontFileName.ttf" -ErrorAction SilentlyContinue
        } elseif ($scope -eq "current") {
            # Instala apenas para o usuário atual
            Write-Host "║" -NoNewline -ForegroundColor Cyan
            Write-Host ("{0,-30} : " -f "Instalando (Este usuário)") -NoNewline
            Write-Host ("{0,-86} " -f "$fontFileName ($fontFamilyName)") -NoNewline -ForegroundColor White
            Write-Host "║" -ForegroundColor Cyan

            $destination = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts\$($fontFileName).ttf"
            $null = Copy-Item $fontPath -Destination $destination -Force -ErrorAction SilentlyContinue
            $regPath = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts"
            $null = Set-ItemProperty -Path $regPath -Name "$fontFileName (TrueType)" -Value "$fontFileName.ttf" -ErrorAction SilentlyContinue
        } else {
            Write-Host "║" -NoNewline -ForegroundColor Cyan
            Write-Host ("{0,-30} : " -f "Erro") -NoNewline
            Write-Host ("{0,-86} " -f "Escopo inválido") -NoNewline -ForegroundColor DarkMagenta 
            Write-Host "║" -ForegroundColor Cyan
            exit
        }
    } catch {
        Write-Host "║" -NoNewline -ForegroundColor Cyan
        Write-Host ("{0,-30} : " -f "Erro") -NoNewline
        Write-Host ("{0,-86} " -f "Erro ao copiar o arquivo") -NoNewline -ForegroundColor DarkMagenta 
        Write-Host "║" -ForegroundColor Cyan
    }
}

# Obtenha todos os arquivos de fontes (ttf) da pasta fornecida
$fontFiles = Get-ChildItem -Path $fontDirectory -Filter *.ttf -Recurse

if ($fontFiles.Count -eq 0) {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Erro") -NoNewline
    Write-Host ("{0,-86} " -f "Nenhum arquivo de fonte encontrado") -NoNewline -ForegroundColor DarkMagenta 
    Write-Host "║" -ForegroundColor Cyan
    exit
}

# Loop para instalar cada fonte encontrada
foreach ($font in $fontFiles) {
    Install-Font -fontPath $font.FullName -scope $scope
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
