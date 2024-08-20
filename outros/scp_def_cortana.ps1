#Script para Habilitar/Desabilitar o Cortana
param (
    [string]$acao = "0" # "0" - Desabilitar, "1" - Habilitar
)

if ($acao -eq "0") {
    Write-Host "Disabling Cortana"
    $AcceptedPrivacyPolicyValue = 0
    $RestrictImplicitValueCollection = 1
    $RestrictImplicitInkCollectionValue = 1
    $HarvestContactsValue = 0
    Get-AppxPackage *Microsoft.549981C3F5F10* | Remove-AppxPackage
} elseif ($acao -eq "1") {
    Write-Host "Re-enabling Cortana"
    $AcceptedPrivacyPolicyValue = 1
    $RestrictImplicitValueCollection = 0
    $RestrictImplicitInkCollectionValue = 0
    $HarvestContactsValue = 1
    Get-AppXPackage *Microsoft.549981C3F5F10* -AllUsers | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}

} else {
    Write-Host "Ação não reconhecida. Use '0' para desabilitar ou '1' para habilitar."
    Exit
}

$Cortana1 = "HKCU:\SOFTWARE\Microsoft\Personalization\Settings"
$Cortana2 = "HKCU:\SOFTWARE\Microsoft\InputPersonalization"
$Cortana3 = "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore"

If (!(Test-Path $Cortana1)) {
    New-Item $Cortana1
}
Set-ItemProperty $Cortana1 AcceptedPrivacyPolicy -Value $AcceptedPrivacyPolicyValue 

If (!(Test-Path $Cortana2)) {
    New-Item $Cortana2
}
Set-ItemProperty $Cortana2 RestrictImplicitTextCollection -Value $RestrictImplicitValueCollection 
Set-ItemProperty $Cortana2 RestrictImplicitInkCollection -Value $RestrictImplicitInkCollectionValue 

If (!(Test-Path $Cortana3)) {
    New-Item $Cortana3
}
Set-ItemProperty $Cortana3 HarvestContacts -Value $HarvestContactsValue 

# Se o processo não estiver em execução, inicie-o
if (-not $explorerProcess) {
    Start-Process explorer
}

# Atualiza as configurações para refletir as mudanças
rundll32.exe user32.dll, UpdatePerUserSystemParameters

# Encerra o processo do Windows Explorer para aplicar as alterações imediatamente
Stop-Process -Name explorer -Force

# Aguarda alguns segundos antes de reiniciar o Windows Explorer
Start-Sleep -Seconds 2
