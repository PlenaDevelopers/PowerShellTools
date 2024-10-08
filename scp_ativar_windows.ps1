﻿<#
    Função: Ativar o Microsoft Windows
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
# Parâmetro de entrada
Param (
    [string]$KmsServer = "kms.digiboy.ir" # Servidor KMS. Use kms.core.windows.net (Original da Microsoft)
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
& $cabecalhoScriptPath -Script $scriptName -Titulo "Ativar o Microsoft Windows"
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Versões Suportadas") -NoNewline
Write-Host ("{0,-86} " -f "Serial Utilizado" ) -NoNewline -ForegroundColor Yellow
Write-Host "║" -ForegroundColor Cyan

Write-Host "╠" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor Gray
write-host "╣" -ForegroundColor Cyan

# Windows 10 Professional                                 W269N-WFGWX-YVC9B-4J6C9-T83GX
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Windows 10 Professional") -NoNewline -ForegroundColor Gray
Write-Host ("{0,-86} " -f "W269N-WFGWX-YVC9B-4J6C9-T83GX" ) -NoNewline -ForegroundColor Gray
Write-Host "║" -ForegroundColor Cyan

# Windows 10 Professional N                               MH37W-N47XK-V7XM9-C7227-GCQG9
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Windows 10 Professional N") -NoNewline -ForegroundColor Gray
Write-Host ("{0,-86} " -f "MH37W-N47XK-V7XM9-C7227-GCQG9" ) -NoNewline -ForegroundColor Gray
Write-Host "║" -ForegroundColor Cyan

# Windows 10 Education                                    NW6C2-QMPVW-D7KKK-3GKT6-VCFB2
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Windows 10 Education") -NoNewline -ForegroundColor Gray
Write-Host ("{0,-86} " -f "NW6C2-QMPVW-D7KKK-3GKT6-VCFB2" ) -NoNewline -ForegroundColor Gray
Write-Host "║" -ForegroundColor Cyan

# Windows 10 Education N                                  2WH4N-8QGBV-H22JP-CT43Q-MDWWJ
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Windows 10 Education N") -NoNewline -ForegroundColor Gray
Write-Host ("{0,-86} " -f "2WH4N-8QGBV-H22JP-CT43Q-MDWW" ) -NoNewline -ForegroundColor Gray
Write-Host "║" -ForegroundColor Cyan

# Windows 10 Enterprise                                   NPPR9-FWDCX-D2C8J-H872K-2YT43
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Windows 10 Enterprise n") -NoNewline -ForegroundColor Gray
Write-Host ("{0,-86} " -f "NPPR9-FWDCX-D2C8J-H872K-2YT43" ) -NoNewline -ForegroundColor Gray
Write-Host "║" -ForegroundColor Cyan

# Windows 10 Enterprise N                                 DPH2V-TTNVB-4X9Q3-TJR4H-KHJW4
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Windows 10 Enterprise N") -NoNewline -ForegroundColor Gray
Write-Host ("{0,-86} " -f "DPH2V-TTNVB-4X9Q3-TJR4H-KHJW4" ) -NoNewline -ForegroundColor Gray
Write-Host "║" -ForegroundColor Cyan

# Windows 10 Enterprise N G (Goverment Edition)           44RPN-FTY23-9VTTB-MP9BX-T84FV
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Windows 10 Enterprise N G") -NoNewline -ForegroundColor Gray
Write-Host ("{0,-86} " -f "44RPN-FTY23-9VTTB-MP9BX-T84FV" ) -NoNewline -ForegroundColor Gray
Write-Host "║" -ForegroundColor Cyan

# Windows 10 Enterprise 2015 LTSB                         WNMTR-4C88C-JK8YV-HQ7T2-76DF9
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Windows 10 Ent. 2015 LTSB") -NoNewline -ForegroundColor Gray
Write-Host ("{0,-86} " -f "WNMTR-4C88C-JK8YV-HQ7T2-76DF9" ) -NoNewline -ForegroundColor Gray
Write-Host "║" -ForegroundColor Cyan

# Windows 10 Enterprise 2015 LTSB N                       2F77B-TNFGY-69QQF-B8YKP-D69TJ
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Windows 10 Ent. 2015 LTSB N ") -NoNewline -ForegroundColor Gray
Write-Host ("{0,-86} " -f "2F77B-TNFGY-69QQF-B8YKP-D69TJ" ) -NoNewline -ForegroundColor Gray
Write-Host "║" -ForegroundColor Cyan

# Windows 10 Education                                    NW6C2-QMPVW-D7KKK-3GKT6-VCFB2
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Windows 10 Education") -NoNewline -ForegroundColor Gray
Write-Host ("{0,-86} " -f "NW6C2-QMPVW-D7KKK-3GKT6-VCFB2" ) -NoNewline -ForegroundColor Gray
Write-Host "║" -ForegroundColor Cyan

# Windows 10 Education N                                  2WH4N-8QGBV-H22JP-CT43Q-MDWWJ
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Windows 10 Education N ") -NoNewline -ForegroundColor Gray
Write-Host ("{0,-86} " -f "2WH4N-8QGBV-H22JP-CT43Q-MDWWJ" ) -NoNewline -ForegroundColor Gray
Write-Host "║" -ForegroundColor Cyan

# Windows 10 PPIPRO (Surface Hub Edition)                 XKCNC-J26Q9-KFHD2-FKTHY-KD72Y
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Windows 10 PPIPRO") -NoNewline -ForegroundColor Gray
Write-Host ("{0,-86} " -f "XKCNC-J26Q9-KFHD2-FKTHY-KD72Y" ) -NoNewline -ForegroundColor Gray
Write-Host "║" -ForegroundColor Cyan

# Windows 10 Home                                         TX9XD-98N7V-6WMQ6-BX7FG-H8Q99
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Windows 10 Home") -NoNewline -ForegroundColor Gray
Write-Host ("{0,-86} " -f "TX9XD-98N7V-6WMQ6-BX7FG-H8Q99" ) -NoNewline -ForegroundColor Gray
Write-Host "║" -ForegroundColor Cyan

# Windows 10 Home N                                       3KHY7-WNT83-DGQKR-F7HPR-844BM
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Windows 10 Home N") -NoNewline -ForegroundColor Gray
Write-Host ("{0,-86} " -f "3KHY7-WNT83-DGQKR-F7HPR-844BM" ) -NoNewline -ForegroundColor Gray
Write-Host "║" -ForegroundColor Cyan

# Windows 10 Home Single Language                         7HNRX-D7KGG-3K4RQ-4WPJ4-YTDFH
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Windows 10 Home Sing Lang ") -NoNewline -ForegroundColor Gray
Write-Host ("{0,-86} " -f "7HNRX-D7KGG-3K4RQ-4WPJ4-YTDFH" ) -NoNewline -ForegroundColor Gray
Write-Host "║" -ForegroundColor Cyan

# Windows 10 Home Country Specific                        PVMJN-6DFY6-9CCP6-7BKTT-D3WVR
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Windows 10 Home Coun Specific") -NoNewline -ForegroundColor Gray
Write-Host ("{0,-86} " -f "PVMJN-6DFY6-9CCP6-7BKTT-D3WVR" ) -NoNewline -ForegroundColor Gray
Write-Host "║" -ForegroundColor Cyan

# Windows Server 2016                                     CB7KF-BWN84-R7R2Y-793K2-8XDDG
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Windows Server 2016 Datacent") -NoNewline -ForegroundColor Gray
Write-Host ("{0,-86} " -f "CB7KF-BWN84-R7R2Y-793K2-8XDDG" ) -NoNewline -ForegroundColor Gray
Write-Host "║" -ForegroundColor Cyan

# Windows Server 2016                                     WC2BQ-8NRM3-FDDYY-2BFGV-KHKQY
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Windows Server 2016 Standard") -NoNewline -ForegroundColor Gray
Write-Host ("{0,-86} " -f "WC2BQ-8NRM3-FDDYY-2BFGV-KHKQY" ) -NoNewline -ForegroundColor Gray
Write-Host "║" -ForegroundColor Cyan

# Windows Server 2019                                     WMDGN-G9PQG-XVVXX-R3X43-63DFG
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Windows Server 2019") -NoNewline -ForegroundColor Gray
Write-Host ("{0,-86} " -f "WMDGN-G9PQG-XVVXX-R3X43-63DFG" ) -NoNewline -ForegroundColor Gray
Write-Host "║" -ForegroundColor Cyan

# Windows Server 2022                                     VDYBN-27WPP-V4HQT-9VMD4-VMK7H
Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Windows Server 2022") -NoNewline -ForegroundColor Gray
Write-Host ("{0,-86} " -f "VDYBN-27WPP-V4HQT-9VMD4-VMK7H" ) -NoNewline -ForegroundColor Gray
Write-Host "║" -ForegroundColor Cyan

Write-Host "║" -NoNewline -ForegroundColor Cyan
write-host ("═" * 120) -NoNewline -ForegroundColor Cyan
Write-Host "║" -ForegroundColor Cyan
#----------------------------------------------------------------------------------------------

# Iniciar Ações
#----------------------------------------------------------------------------------------------
$os = (Get-CimInstance Win32_OperatingSystem).Caption

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Sistema Operacional") -NoNewline
Write-Host ("{0,-86} " -f $os ) -NoNewline -ForegroundColor Cyan
Write-Host "║" -ForegroundColor Cyan

if ($os -like '*Windows 10 Enterprise*') {
    $chave = "NPPR9-FWDCX-D2C8J-H872K-2YT43"
}
if ($os -like '*Windows 11*') {
    $chave = "W269N-WFGWX-YVC9B-4J6C9-T83GX"
}
if ($os -like '*Windows 10 Pro*') {
    $chave = "W269N-WFGWX-YVC9B-4J6C9-T83GX"
}
if ($os -like '*Windows 10 N*') {
    $chave = "MH37W-N47XK-V7XM9-C7227-GCQG9"
}
if ($os -like '*Windows 10 Home*') {
    $chave = "TX9XD-98N7V-6WMQ6-BX7FG-H8Q99"
}
if ($os -like '*Server 2016 Standard*') {
    $chave = "WC2BQ-8NRM3-FDDYY-2BFGV-KHKQY"
}
if ($os -like '*Server 2016 Datacenter*') {
    $chave = "CB7KF-BWN84-R7R2Y-793K2-8XDDG"
}
if ($os -like '*Server 2019*') {
    $chave = "WMDGN-G9PQG-XVVXX-R3X43-63DFG"
}
if ($os -like '*Server 2022*') {
    $chave = "VDYBN-27WPP-V4HQT-9VMD4-VMK7H"
}

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Chave") -NoNewline
Write-Host ("{0,-86} " -f $chave ) -NoNewline -ForegroundColor Cyan
Write-Host "║" -ForegroundColor Cyan

$null = & cscript.exe C:\Windows\System32\slmgr.vbs /ipk $chave

Write-Host "║" -NoNewline -ForegroundColor Cyan
Write-Host ("{0,-30} : " -f "Servidor KMS") -NoNewline
Write-Host ("{0,-86} " -f $KmsServer) -NoNewline -ForegroundColor Cyan
Write-Host "║" -ForegroundColor Cyan

$null = & cscript.exe C:\Windows\System32\slmgr.vbs /skms $KmsServer

# Ativar o Windows
$null = & cscript.exe C:\Windows\System32\slmgr.vbs /ato

$activationStatus = (Get-CimInstance -ClassName SoftwareLicensingProduct -Filter "Name like 'Windows%'" | Where-Object { $_.LicenseStatus -ne $null }).LicenseStatus

if ($activationStatus -eq 1) {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Licenciamento") -NoNewline
    Write-Host ("{0,-86} " -f "O Windows está ativado.") -NoNewline -ForegroundColor Green
    Write-Host "║" -ForegroundColor Cyan
}
else {
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host ("{0,-30} : " -f "Licenciamento") -NoNewline
    Write-Host ("{0,-86} " -f "O Windows não está ativado.") -NoNewline -ForegroundColor Red
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