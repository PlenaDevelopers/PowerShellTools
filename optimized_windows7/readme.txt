Scripts Windows 7 otimizados
============================

Folder criada para scripts compativeis com Windows 7 e Powershell 2.0.
Os scripts originais do projeto nao foram alterados.

Como executar:

1. Abra o Powershell como Administrador.
2. Entre nesta pasta.
3. Execute:

   powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\start_optimized_windows7.ps1

Opcoes principais:

- Otimizacao completa basica:
  Limpeza, servicos seguros, plano de energia, rede TCP e visual de desempenho.

- Otimizacao completa maxima:
  Igual a basica, mas tambem desativa Temas/Aero, Superfetch e recursos de Grupo Domestico.
  Use em maquinas fracas ou dedicadas a desempenho.

- Reverter padrao conservador:
  Restaura servicos e rede para valores conservadores.

- Instalar Google Chrome:
  Baixa o instalador do Google quando houver internet.
  Para Windows 7 sem internet ou quando o instalador atual nao aceitar Windows 7,
  coloque um instalador offline compativel com Windows 7 nesta pasta ou em
  updates\chrome com um destes nomes:
  ChromeStandaloneSetup64.exe
  ChromeStandaloneSetup.exe
  chrome_installer.exe
  Em Windows 7 32 bits, prefira ChromeStandaloneSetup.exe.

Observacoes:

- A otimizacao de rede cria backup em C:\Backup_Win7_Otimizacao.
- Reinicie o Windows apos aplicar a otimizacao completa.
- Windows 7 nao usa DISM /RestoreHealth; o reparo usa SFC e agenda CHKDSK.
