#Script que limpa as configurações do Mozilla Firefox e cria um novo perfil vazio

# Verificar se o Mozilla Firefox está instalado
$firefoxInstalled = Test-Path "C:\Program Files\Mozilla Firefox\firefox.exe"

if ($firefoxInstalled) {
    # Encerrar processos do Mozilla Firefox
    $null=Stop-Process -Name "firefox" -Force -ErrorAction SilentlyContinue

    # Obter o caminho do diretório de perfis do Firefox
    $firefoxProfilesDir = [System.IO.Path]::Combine($env:APPDATA, 'Mozilla\Firefox\Profiles')
    
    # Obter a lista de perfis do Firefox
    $firefoxProfiles = Get-ChildItem $firefoxProfilesDir -Directory
    
    # Limpar o conteúdo de cada perfil
    foreach ($profile in $firefoxProfiles) {
        $null = Remove-Item -Path "$($profile.FullName)\*" -Recurse -Force -ErrorAction SilentlyContinue
    }

    # Criar um novo perfil vazio
    $newProfileDir = New-Item -Path $firefoxProfilesDir -Name ([Guid]::NewGuid().ToString()) -ItemType "directory" -Force
    
    # Criar um arquivo de perfil vazio
    $null = New-Item -Path (Join-Path -Path $newProfileDir.FullName -ChildPath "user.js") -ItemType "file"
    
    # Remover ou renomear o arquivo profiles.ini
    $profilesIniPath = Join-Path -Path $env:APPDATA -ChildPath "Mozilla\Firefox"
    $profilesIniFile = Join-Path -Path $profilesIniPath -ChildPath "profiles.ini"
    if (Test-Path $profilesIniFile) {
        Remove-Item $profilesIniFile -Force -ErrorAction SilentlyContinue
    }
} else {
}
