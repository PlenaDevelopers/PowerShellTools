# Formatacao remota via AnyDesk

Objetivo: permitir preparar remotamente uma reinstalacao limpa do Windows sem ir ao local.

O script principal e `tool_format_windows_remote.ps1`.

## Ideia correta

Nao da para depender da ISO montada como "CD virtual" depois do reinicio, porque a montagem feita pelo Windows some quando o sistema reinicia.

Por isso o script usa outro caminho:

1. Voce envia a ISO para o computador remoto.
2. O script reduz a particao `C:`.
3. O script cria uma nova particao NTFS chamada `WINSETUP`.
4. A ISO e montada apenas temporariamente.
5. Os arquivos da ISO sao copiados para `WINSETUP`.
6. O script cria `WINSETUP:\autounattend.xml`.
7. O BCD e configurado para iniciar o `WINSETUP:\sources\boot.wim`.
8. No reboot, o Windows Setup inicia pela particao `WINSETUP`.
9. O `autounattend.xml` manda formatar a particao original `C:` e instalar o Windows.

Na pratica, `WINSETUP` substitui o pendrive/DVD de instalacao.

## Avisos importantes

- Depois do reboot, a sessao AnyDesk cai.
- O acesso remoto so volta se o Windows novo tiver rede, drivers e algum agente remoto instalado/configurado.
- Se a ISO nao tiver drivers de armazenamento/rede compativeis, a instalacao pode falhar ou ficar sem acesso remoto.
- Se BitLocker estiver ativo, suspenda/desative antes.
- Faça backup antes. A particao alvo sera formatada.
- Teste primeiro em uma maquina de bancada ou VM.

## Uso sem reiniciar

Se voce nao informar -IsoPath, o script lista as ISOs da mesma pasta para selecao.

Prepara tudo e deixa pronto para reinicio manual:

```powershell
powershell -ExecutionPolicy Bypass -File .\tool_format_windows_remote.ps1 -IsoPath "C:\ISOS\Windows.iso" -ConfirmarFormatacao FORMATAR
```

## Uso com reinicio automatico

```powershell
powershell -ExecutionPolicy Bypass -File .\tool_format_windows_remote.ps1 -IsoPath "C:\ISOS\Windows.iso" -ConfirmarFormatacao FORMATAR -Reiniciar
```

## Uso com usuario local

Isso reduz parada no OOBE:

```powershell
$senha = Read-Host "Senha do usuario local" -AsSecureString
powershell -ExecutionPolicy Bypass -File .\tool_format_windows_remote.ps1 -IsoPath "C:\ISOS\Windows.iso" -ConfirmarFormatacao FORMATAR -NomeComputador "suporte-01" -UsuarioLocal "suporte" -SenhaUsuarioLocal $senha -Reiniciar
```

## O que o script nao faz ainda

- Nao instala AnyDesk automaticamente no Windows novo.
- Nao injeta drivers na ISO.
- Nao apaga todas as particoes do disco, apenas formata a particao alvo indicada.
- Nao garante retorno remoto apos a instalacao.

