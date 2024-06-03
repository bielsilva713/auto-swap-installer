#!/bin/bash

# Define cores para o terminal
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # Sem cor

# Verifica se o script está sendo executado como root
echo -e "${CYAN}Passo 1: Verificando privilégios de root...${NC}"
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Por favor, execute este script como root${NC}"
  exit 1
fi

# Instala pacotes necessários
echo -e "${CYAN}Passo 2: Instalando pacotes necessários...${NC}"
sudo apt-get update
sudo apt-get install -y util-linux

# Função para criar swap
create_swap() {
  local swap_size_mb=$1

  echo -e "${CYAN}Passo 5: Criando arquivo de swap de $swap_size_mb MB...${NC}"

  # Carrega o arquivo de swap
  sudo sync

  # Cria um arquivo vazio para o swap sem buracos
  sudo dd if=/dev/zero of=/swapfile bs=1M count=$swap_size_mb conv=notrunc status=progress || { echo -e "${RED}Falha ao criar o arquivo de swap${NC}"; exit 1; }

  # Define permissões seguras para o arquivo de swap
  sudo chmod 600 /swapfile

  # Formata o arquivo de swap
  sudo mkswap /swapfile > /dev/null

  # Ativa o arquivo de swap
  sudo swapon /swapfile

  # Adiciona o arquivo de swap ao /etc/fstab para persistência após reinicializações
  echo "/swapfile none swap sw 0 0" | sudo tee -a /etc/fstab > /dev/null

  echo -e "${GREEN}Swap de $swap_size_mb MB foi criado e ativado com sucesso!${NC}"
}

# Verifica se o arquivo de swap já existe
echo -e "${CYAN}Passo 3: Verificando existência do arquivo de swap...${NC}"
if [ -f /swapfile ]; then
  echo -e "${YELLOW}Um arquivo de swap já existe.${NC}"

  # Verifica se o swapfile está ativado
  if swapon --show | grep -q '/swapfile'; then
    swap_active=true
  else
    swap_active=false
  fi

  # Pergunta ao usuário se deseja alterar o tamanho ou remover o arquivo existente
  while true; do
    read -p "Deseja alterar o tamanho do swap existente (A) ou remover e criar um novo (R)? " choice
    case $choice in
      [Aa]* )
        echo -e "${CYAN}Passo 4: Insira o novo tamanho desejado para o arquivo de swap (por exemplo, 2G para 2 gigabytes ou 2048M para 2048 megabytes):${NC}"
        read swap_size_input
        # Extrai a parte numérica e a unidade da entrada do usuário
        swap_size_numeric=$(echo "$swap_size_input" | sed 's/[^0-9]*//g')
        swap_size_unit=$(echo "$swap_size_input" | sed 's/[0-9]*//g' | tr '[:lower:]' '[:upper:]')

        # Converte o tamanho para megabytes
        if [ "$swap_size_unit" = "G" ]; then
          swap_size_mb=$((swap_size_numeric * 1024))
        elif [ "$swap_size_unit" = "M" ]; then
          swap_size_mb=$swap_size_numeric
        else
          echo -e "${RED}Por favor, insira um tamanho válido (por exemplo, 2G para 2 gigabytes ou 2048M para 2048 megabytes).${NC}"
          exit 1
        fi

        # Desativa e remove o swap existente se estiver ativo
        if [ "$swap_active" = true ]; then
          echo -e "${CYAN}Desativando swap existente...${NC}"
          sudo swapoff /swapfile || { echo -e "${RED}Falha ao desativar o swap${NC}"; exit 1; }
        fi
        sudo rm /swapfile

        # Cria o novo swap
        create_swap $swap_size_mb
        break
        ;;
      [Rr]* )
        # Remove o swap existente se estiver ativo
        if [ "$swap_active" = true ]; then
          echo -e "${CYAN}Desativando swap existente...${NC}"
          sudo swapoff /swapfile || { echo -e "${RED}Falha ao desativar o swap${NC}"; exit 1; }
        fi
        sudo rm /swapfile

        echo -e "${CYAN}Passo 4: Insira o tamanho desejado para o novo arquivo de swap (por exemplo, 2G para 2 gigabytes ou 2048M para 2048 megabytes):${NC}"
        read swap_size_input
        # Extrai a parte numérica e a unidade da entrada do usuário
        swap_size_numeric=$(echo "$swap_size_input" | sed 's/[^0-9]*//g')
        swap_size_unit=$(echo "$swap_size_input" | sed 's/[0-9]*//g' | tr '[:lower:]' '[:upper:]')

        # Converte o tamanho para megabytes
        if [ "$swap_size_unit" = "G" ]; then
          swap_size_mb=$((swap_size_numeric * 1024))
        elif [ "$swap_size_unit" = "M" ]; then
          swap_size_mb=$swap_size_numeric
        else
          echo -e "${RED}Por favor, insira um tamanho válido (por exemplo, 2G para 2 gigabytes ou 2048M para 2048 megabytes).${NC}"
          exit 1
        fi

        # Cria o novo swap
        create_swap $swap_size_mb
        break
        ;;
      * )
        echo -e "${YELLOW}Por favor, responda com A para alterar ou R para remover e criar um novo.${NC}"
        ;;
    esac
  done
else
  # Pergunta o tamanho do swap se não existir
  echo -e "${CYAN}Passo 4: Insira o tamanho desejado para o arquivo de swap (por exemplo, 2G para 2 gigabytes ou 2048M para 2048 megabytes):${NC}"
  read swap_size_input
  # Extrai a parte numérica e a unidade da entrada do usuário
  swap_size_numeric=$(echo "$swap_size_input" | sed 's/[^0-9]*//g')
  swap_size_unit=$(echo "$swap_size_input" | sed 's/[0-9]*//g' | tr '[:lower:]' '[:upper:]')

  # Converte o tamanho para megabytes
  if [ "$swap_size_unit" = "G" ]; then
    swap_size_mb=$((swap_size_numeric * 1024))
  elif [ "$swap_size_unit" = "M" ]; then
    swap_size_mb=$swap_size_numeric
  else
    echo -e "${RED}Por favor, insira um tamanho válido (por exemplo, 2G para 2 gigabytes ou 2048M para 2048 megabytes).${NC}"
    exit 1
  fi

  # Cria o novo swap
  create_swap $swap_size_mb
fi
