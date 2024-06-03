---

# Auto Swap Installer

Este repositório contém um script Bash para criar e gerenciar arquivos de swap no Linux de maneira automatizada. O script verifica se os pacotes necessários estão instalados, cria um arquivo de swap, configura permissões, ativa o swap e garante a persistência do swap após reinicializações.

## Funcionalidades

- **Verificação de Privilégios**: Garante que o script é executado como root.
- **Instalação de Pacotes Necessários**: Instala os pacotes necessários (`util-linux`).
- **Criação e Configuração do Swap**: Cria, configura e ativa um arquivo de swap.
- **Gerenciamento do Swap Existente**: Permite alterar o tamanho do swap existente ou removê-lo e criar um novo.
- **Persistência do Swap**: Adiciona o arquivo de swap ao `/etc/fstab` para garantir que ele seja ativado após reinicializações.

## Requisitos

- Sistema operacional baseado em Linux.
- Privilégios de superusuário (root).

## Como Usar

Execute o script diretamente do GitHub sem precisar baixá-lo manualmente:

```sh
sudo bash -c "$(wget -qO- https://raw.githubusercontent.com/bielsilva713/auto-swap-installer/main/swap-install.sh)"
```

### Passos do Script

1. **Verificação de Privilégios de Root**: Certifica-se de que o script está sendo executado com privilégios de root.
2. **Instalação de Pacotes Necessários**: Atualiza os pacotes e instala `util-linux` se necessário.
3. **Verificação de Swap Existente**: Verifica se um arquivo de swap já existe e se está ativo.
4. **Entrada do Usuário**: Pergunta ao usuário o tamanho desejado para o arquivo de swap.
5. **Criação do Swap**: Cria e configura o novo arquivo de swap.
6. **Persistência**: Adiciona o arquivo de swap ao `/etc/fstab` para ativação após reinicializações.

---

### Contribuição

Contribuições são bem-vindas! Sinta-se à vontade para abrir issues ou enviar pull requests.

### Licença

Este projeto está licenciado sob a licença MIT. Consulte o arquivo `LICENSE` para mais detalhes.

---
