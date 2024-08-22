#Script que restaura os temas do Windows
param (
    [string]$NewFilesDirectory
)

$NewFilesDirectory = "D:\ptool\finalizado\restores\temas"

# Verifica se o parâmetro $NewFilesDirectory foi fornecido
if (-not $NewFilesDirectory) {
    Write-Warning "Por favor, forneça o diretório onde os novos arquivos estão localizados usando o parâmetro -NewFilesDirectory."
    Exit
}

# Verifica se o diretório fornecido existe
if (-not (Test-Path $NewFilesDirectory -PathType Container)) {
    Write-Warning "O diretório especificado não existe."
    Exit
}

# Caminho para a pasta onde o Windows está instalado
$windowsDir = [System.Environment]::GetFolderPath("Windows")

# Caminho completo para a pasta "resources"
$resourcesDir = Join-Path $windowsDir "resources"

# Define a função para ajustar as permissões da pasta
function Set-FolderPermissions {
    param(
        [string]$Folder
    )
    $acl = Get-Acl $Folder
    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("todos", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
    $acl.AddAccessRule($accessRule)
    Set-Acl $Folder $acl
}

# Define a função para desbloquear um arquivo
function Unlock-File {
    param (
        [string]$FilePath
    )
    $processId = (Get-Process | Where-Object { $_.Modules.FileName -contains $FilePath }).Id
    if ($processId) {
        Stop-Process -Id $processId -Force
        Write-Host "O processo com ID $processId foi encerrado para desbloquear o arquivo $FilePath."
    } else {
        Write-Host "Nenhum processo está usando o arquivo $FilePath."
    }
}

# Ajusta as permissões da pasta "resources"
Set-FolderPermissions -Folder $resourcesDir

# Desbloqueia todos os arquivos dentro da pasta "resources"
Get-ChildItem $resourcesDir -Recurse | ForEach-Object {
    if (-not $_.PSIsContainer) {
        Unlock-File -FilePath $_.FullName
    }
}

# Remove todos os itens dentro da pasta "resources"
if (Test-Path $resourcesDir -PathType Container) {
    Remove-Item $resourcesDir -Recurse -Force
}

# Cria a pasta "resources" se ela não existir
if (-not (Test-Path $resourcesDir -PathType Container)) {
    New-Item -Path $resourcesDir -ItemType Directory | Out-Null
}

# Copia as pastas "Themes" e "Ease of Access Themes" para dentro de "resources"
$themesDir = Join-Path $NewFilesDirectory "Themes"
if (Test-Path $themesDir -PathType Container) {
    Copy-Item -Path $themesDir -Destination $resourcesDir -Recurse -Force
} else {
    Write-Warning "A pasta 'Themes' não foi encontrada em $NewFilesDirectory."
}

$easeOfAccessThemesDir = Join-Path $NewFilesDirectory "Ease of Access Themes"
if (Test-Path $easeOfAccessThemesDir -PathType Container) {
    Copy-Item -Path $easeOfAccessThemesDir -Destination $resourcesDir -Recurse -Force
} else {
    Write-Warning "A pasta 'Ease of Access Themes' não foi encontrada em $NewFilesDirectory."
}

# Aplica o arquivo de tema "theme1"
# Se necessário, substitua "theme1.theme" pelo nome do seu arquivo de tema
$themeFilePath = Join-Path $resourcesDir "Themes\theme1.theme"
if (Test-Path $themeFilePath -PathType Leaf) {
    $arg = "/Action:OpenTheme /file:`"$themeFilePath`""
    Start-Process rundll32.exe -ArgumentList "shell32.dll,Control_RunDLL desk.cpl desk $arg" -NoNewWindow -Wait
} else {
    Write-Host "Arquivo de tema não encontrado."
}
