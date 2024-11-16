#!/bin/bash

set -e  # Para o script em caso de erro

# Variáveis
DOCKER_COMPOSE_VERSION="2.20.2"
REPO_URL="https://github.com/Uniswap/unichain-node"
ETH_RPC_URL="https://ethereum-sepolia-rpc.publicnode.com"
BEACON_API_URL="https://ethereum-sepolia-beacon-api.publicnode.com"

# Atualizar sistema
echo "Atualizando o sistema..."
sudo apt update -y && sudo apt upgrade -y

# Instalar Git
echo "Instalando Git..."
sudo apt install -y git curl

# Verificar se o Docker está instalado
if ! command -v docker &> /dev/null; then
  echo "Docker não encontrado, instalando Docker..."
  sudo apt install -y docker.io
else
  echo "Docker já está instalado."
fi

# Verificar e instalar ou atualizar o Docker Compose
if command -v docker-compose &> /dev/null; then
  DOCKER_COMPOSE_CURRENT_VERSION=$(docker-compose --version | awk '{print $3}' | sed 's/,//g')
  
  if [[ "$DOCKER_COMPOSE_CURRENT_VERSION" =~ ^1 ]]; then
    echo "Versão 1 do Docker Compose detectada, atualizando para a versão 2..."
    sudo curl -L "https://github.com/docker/compose/releases/download/v$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
  else
    echo "Docker Compose já está na versão 2 ou superior."
  fi
else
  echo "Docker Compose não encontrado, instalando Docker Compose..."
  sudo curl -L "https://github.com/docker/compose/releases/download/v$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
fi

# Clonar repositório Unichain
echo "Clonando o repositório Unichain..."
git clone $REPO_URL

# Mudar diretório para unichain-node
cd unichain-node || { echo "Falha ao entrar no diretório unichain-node"; exit 1; }

# Editar arquivo .env.sepolia
echo "Editando arquivo .env.sepolia..."
sed -i "s|OP_NODE_L1_ETH_RPC=.*|OP_NODE_L1_ETH_RPC=$ETH_RPC_URL|" .env.sepolia
sed -i "s|OP_NODE_L1_BEACON=.*|OP_NODE_L1_BEACON=$BEACON_API_URL|" .env.sepolia

# Iniciar o nó Unichain
echo "Iniciando o nó Unichain..."
docker-compose up -d

echo "Execução do script concluída."

# Testar o Node 
echo "Testando o Node:"
curl -d '{"id":1,"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["latest",false]}' \
  -H "Content-Type: application/json" http://localhost:8545 || { echo "Falha no teste do Node"; exit 1; }

# Aviso sobre a chave privada
echo "A seguir, será exibida a chave privada. É importante que você a salve em um local seguro."
echo "Para adicionar em uma carteira cripto, lembre-se de incluir '0x' na frente da chave, pois ela está em formato hexadecimal."
read -p "Pressione Enter para continuar e visualizar a chave privada..."

# Mostrar a chave privada
echo "Copie a chave privada e mantenha-a segura..."
cat geth-data/geth/nodekey || { echo "Falha ao acessar a chave privada"; exit 1; }
echo  "安装完成，风男真他妈帅，推特@tsexiao"
