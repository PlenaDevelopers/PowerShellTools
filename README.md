# Português - Brazil
---
# PowerShell Tools

## Descrição

Este repositório contém uma coleção de scripts PowerShell projetados para automatizar várias tarefas administrativas no Windows, incluindo personalização do desktop, gerenciamento de perfis de usuário, instalação de software, e muito mais.

## Funcionalidades

- Alteração e restauração de temas e cores do Windows.
- Gerenciamento da barra de tarefas e desativação de funcionalidades indesejadas.
- Definição de imagens de wallpaper e tela de bloqueio.
- Organização de ícones na área de trabalho.
- Limpeza de arquivos temporários.
- Instalação automática de aplicativos essenciais.
- Gerenciamento de perfis de usuário e estrutura de pastas.

## Requisitos

- Windows 10 ou Windows 11.
- PowerShell 5.1 ou superior.
- Git (opcional, mas recomendado).


## Chaves de ativação

- Lembramos que as chaves de ativação contidas nos scripts são para testes.
- As chaves foram encontradas por pesquisa Google, sendo assim são de domínio público.
- Não nos responsabilizamos pelo uso das mesmas, são apenas exemplos.

## Instalação

1. Clone o repositório em sua máquina local usando o comando abaixo ou faça o download do arquivo ZIP.

    ```bash
    git clone https://github.com/Underrun2016/PowerShellTools.git
    ```

2. Navegue até o diretório do projeto.

    ```bash
    cd PowerShellTools
    ```

3. Certifique-se de que todos os scripts têm permissões de execução:

    ```bash
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
    ```

## Instalação sem GIT

1. Baixe o arquivo atualizador "scp_atualizar_script"
2. Libere a execução de script powershell

    ```	Set-ExecutionPolicy Unrestricted
    ```
2. Execute o script baixado "scp_atualizar_script"


## Uso

Cada script pode ser executado diretamente a partir do PowerShell. Exemplos de uso estão descritos abaixo:

### Powershell

```
.\iniciar.ps1
(Requer autorização para executar scripts - Set-ExecutionPolicy Unrestricted)
````
### CMD
```
.\iniciar.bat
 - Copia todo o conteúdo da pasta para um diretório no disco fixo (D ou C)
 - Libera a execução de script para o Powershell
 - Inicia a execução do iniciar.ps1
(Ideal para Pen-Drive)
````
---
# English - USA
---
# PowerShell Tools

## Description

This repository contains a collection of PowerShell scripts designed to automate various administrative tasks in Windows, including desktop customization, user profile management, software installation, and much more.

## Features

- Modification and restoration of Windows themes and colors.
- Taskbar management and disabling unwanted features.
- Setting wallpaper and lock screen images.
- Organizing desktop icons.
- Cleaning temporary files.
- Automatic installation of essential applications.
- Management of user profiles and folder structure.

## Requirements

- Windows 10 or Windows 11.
- PowerShell 5.1 or higher.
- Git (optional, but recommended).

## Activation Keys

- Please note that the activation keys contained in the scripts are for testing purposes.
- The keys were found through Google search, so they are public domain.
- We are not responsible for their use; they are just examples.

## Installation

1. Clone the repository to your local machine using the command below or download the ZIP file.

    ```bash
    git clone https://github.com/Underrun2016/PowerShellTools.git
    ```

2. Navigate to the project directory.

    ```bash
    cd PowerShellTools
    ```

3. Ensure that all scripts have execution permissions:

    ```bash
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
    ```

## Installation Without Git

1. Download the updater file "scp_atualizar_script".
2. Enable PowerShell script execution:

    ```bash
    Set-ExecutionPolicy Unrestricted
    ```
3. Run the downloaded script "scp_atualizar_script".

## Usage

Each script can be executed directly from PowerShell. Usage examples are described below:

### PowerShell

```powershell
.\iniciar.ps1
(Requires script authorization - Set-ExecutionPolicy Unrestricted)

### CMD

.\iniciar.bat
 - Copies all contents of the folder to a directory on the fixed disk (D or C)
 - Grants script execution permissions for PowerShell
 - Starts the execution of iniciar.ps1
(Ideal for USB drives)