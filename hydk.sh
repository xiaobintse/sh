#!/bin/bash

# 检查 Docker 是否已安装
if ! command -v docker &> /dev/null; then
    echo "Docker 未安装，请先安装 Docker。"
    exit 1
fi

# 检查 docker-compose 是否已安装
if ! command -v docker-compose &> /dev/null; then
    echo "docker-compose 未安装，请先安装 docker-compose。"
    exit 1
fi

# 默认实例数量
DEFAULT_INSTANCE_COUNT=3

# 用户输入实例数量
read -p "请输入要启动的实例数量（默认: $DEFAULT_INSTANCE_COUNT）: " INSTANCE_COUNT
INSTANCE_COUNT=${INSTANCE_COUNT:-$DEFAULT_INSTANCE_COUNT}

# 验证实例数量
if ! [[ "$INSTANCE_COUNT" =~ ^[0-9]+$ ]] || [ "$INSTANCE_COUNT" -le 0 ]; then
    echo "无效的实例数量，请输入正整数。"
    exit 1
fi

# 公网 IP 地址
read -p "请输入节点对外访问的公网 IP 地址（必填）: " PUBLIC_IP
if [[ -z "$PUBLIC_IP" ]]; then
    echo "必须提供公网 IP 地址。"
    exit 1
fi

# 端口基准
BASE_HTTP_PORT=8111
BASE_P2P_TCP_PORT=8112
BASE_P2P_WS_PORT=8113
BASE_P2P_V6_TCP_PORT=8114
BASE_P2P_V6_WS_PORT=8115
BASE_TYPESENSE_PORT=1001

# 循环创建配置和启动容器
for i in $(seq 1 $INSTANCE_COUNT); do
    CONTAINER_NAME="hy$i"
    TYPESENSE_CONTAINER_NAME="typ$i"
    
    HTTP_PORT=$((BASE_HTTP_PORT + (i - 1) * 10))
    P2P_TCP_PORT=$((BASE_P2P_TCP_PORT + (i - 1) * 10))
    P2P_WS_PORT=$((BASE_P2P_WS_PORT + (i - 1) * 10))
    P2P_V6_TCP_PORT=$((BASE_P2P_V6_TCP_PORT + (i - 1) * 10))
    P2P_V6_WS_PORT=$((BASE_P2P_V6_WS_PORT + (i - 1) * 10))
    TYPESENSE_PORT=$((BASE_TYPESENSE_PORT + (i - 1)))
    
    cat <<EOF > docker-compose-$CONTAINER_NAME.yml
version: "3.8"
services:
  $CONTAINER_NAME:
    image: oceanprotocol/ocean-node:latest
    pull_policy: always
    container_name: $CONTAINER_NAME
    restart: always
    ports:
      - "$HTTP_PORT:8111"
      - "$P2P_TCP_PORT:8112"
      - "$P2P_WS_PORT:8113"
      - "$P2P_V6_TCP_PORT:8114"
      - "$P2P_V6_WS_PORT:8115"
    environment:
      PRIVATE_KEY: '0x$(head -c 32 /dev/urandom | xxd -p)'
      RPCS: '{"1":{"rpc":"https://eth.drpc.org","fallbackRPCs":["https://eth-pokt.nodies.app","https://1rpc.io/eth","https://eth.merkle.io"],"chainId":1,"network":"ETH","chunkSize":100}}'
      DB_URL: "http://$TYPESENSE_CONTAINER_NAME:$TYPESENSE_PORT/?apiKey=xyz"
      IPFS_GATEWAY: 'https://ipfs.io/'
      ARWEAVE_GATEWAY: 'https://arweave.net/'
      INTERFACES: '["HTTP","P2P"]'
      ALLOWED_ADMINS: '["0x0a434fa3ebdc7304de53de92af9685cb5d18061a"]'
      DASHBOARD: 'true'
      HTTP_API_PORT: '8111'
      P2P_ENABLE_IPV4: 'true'
      P2P_ENABLE_IPV6: 'false'
      P2P_ipV4BindAddress: '0.0.0.0'
      P2P_ipV4BindTcpPort: '8112'
      P2P_ipV4BindWsPort: '8113'
      P2P_ipV6BindAddress: '::'
      P2P_ipV6BindTcpPort: '8114'
      P2P_ipV6BindWsPort: '8115'
      P2P_ANNOUNCE_ADDRESSES: '["/ip4/$PUBLIC_IP/tcp/$P2P_TCP_PORT", "/ip4/$PUBLIC_IP/ws/tcp/$P2P_WS_PORT"]'
    networks:
      - ocean_network
    depends_on:
      - $TYPESENSE_CONTAINER_NAME

  $TYPESENSE_CONTAINER_NAME:
    image: typesense/typesense:26.0
    container_name: $TYPESENSE_CONTAINER_NAME
    ports:
      - "$TYPESENSE_PORT:1001"
    networks:
      - ocean_network
    volumes:
      - typesense-data-$i:/data
    command: "--data-dir /data --api-key=xyz"

volumes:
  typesense-data-$i:
    driver: local

networks:
  ocean_network:
    driver: bridge
EOF

    echo "生成的配置文件: docker-compose-$CONTAINER_NAME.yml"
    # 启动容器
    docker-compose -f docker-compose-$CONTAINER_NAME.yml up -d
done

echo "所有 $INSTANCE_COUNT 个实例已成功启动！"
