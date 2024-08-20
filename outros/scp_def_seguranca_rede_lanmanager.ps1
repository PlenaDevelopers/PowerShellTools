param (
    [int]$Option = 0
)

# Opções disponíveis para o Nível de Autenticação LAN Manager
$OptionsMap = @{
    0 = "Enviar LM e NTLM - Usar NTLMv2 de sessão se negociado"
    1 = "Enviar LM e NTLM - Usar a autenticação de segurança de NTLMv2 se negociado; recusar LM"
    2 = "Enviar NTLMv2 resposta apenas"
    3 = "Enviar NTLMv2 resposta apenas / recusar LM & NTLM"
    4 = "Enviar NTLMv2 resposta somente / recusar LM & NTLM / Refuse NTLM"
    5 = "Enviar NTLMv2 resposta somente / recusar LM & NTLM / Refuse NTLM & LM"
}

# Verifica se a opção fornecida é válida
if (-not $OptionsMap.ContainsKey($Option)) {
    Write-Host "Opção inválida. Por favor, escolha um número entre 0 e 5."
    exit
}

# Define o valor do registro com base na opção escolhida
$RegValue = @{
    0 = 1
    1 = 2
    2 = 3
    3 = 4
    4 = 5
    5 = 6
}[$Option]

# Define o caminho do registro
$RegPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"

# Define o nome do valor do registro
$RegName = "LmCompatibilityLevel"

# Define o valor do registro
Set-ItemProperty -Path $RegPath -Name $RegName -Value $RegValue -Force

# Exibe a opção selecionada
Write-Host "Nível de Autenticação LAN Manager definido para: $($OptionsMap[$Option])"
