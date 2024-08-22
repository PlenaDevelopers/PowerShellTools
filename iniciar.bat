@echo off

REM Verifica se a unidade D: existe
if exist D:\ (
    set "targetDir=D:\PowerTool"
) else (
    REM Caso a unidade D: não exista, cria a pasta PowerTool na unidade onde o Windows está instalado
    set "targetDrive=%SystemDrive%"
    set "targetDir=%targetDrive%\PowerTool"
)

REM Cria a pasta de destino, caso ainda não exista
if not exist "%targetDir%" (
    mkdir "%targetDir%"
)

REM Copia todos os arquivos, pastas e subpastas para a pasta de destino
xcopy * "%targetDir%\" /E /I /H /Y

REM Define a política de execução do PowerShell para unrestricted
powershell -Command "Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force"

REM Abre o PowerShell no diretório criado e executa o script iniciar.ps1
cd /d "%targetDir%"
start powershell.exe -NoExit -ExecutionPolicy Bypass -Command "& '%targetDir%\iniciar.ps1'"

exit
