#!/bin/bash

# 检查是否安装了 Docker 和 docker-compose
if ! command -v docker &> /dev/null; then
    echo "Docker 未安装，请先安装 Docker。"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "docker-compose 未安装，请先安装 docker-compose。"
    exit 1
fi

# 默认实例数量
DEFAULT_INSTANCES=3

# 用户输入实例数量
read -p "请输入要启动的 Ocean Node 实例数量（默认为 $DEFAULT_INSTANCES）: " INSTANCE_COUNT
INSTANCE_COUNT=${INSTANCE_COUNT:-$DEFAULT_INSTANCES}

# 验证输入的实例数量是否为有效数字
if ! [[ "$INSTANCE_COUNT" =~ ^[0-9]+$ ]] || [ "$INSTANCE_COUNT" -le 0 ]; then
    echo "无效的实例数量，请输入大于 0 的数字。"
    exit 1
fi

# 基础端口
BASE_HTTP_API_PORT=8111
BASE_P2P_TCP_PORT=8112
BASE_P2P_WS_PORT=8113
BASE_P2P_V6_TCP_PORT=8114
BASE_P2P_V6_WS_PORT=8115
BASE_TYPESENSE_PORT=1001

# 公网 IP 地址或 FQDN
read -p "请输入节点对外访问的公网 IPv4 地址或 FQDN: " PUBLIC_IP

if [[ -z "$PUBLIC_IP" ]]; then
    echo "必须提供公网 IP 地址或 FQDN。"
    exit 1
fi

# 创建实例配置
for i in $(seq 1 $INSTANCE_COUNT); do
    INSTANCE_NAME="ocean-node-$i"
    INSTANCE_HTTP_API_PORT=$((BASE_HTTP_API_PORT + (i - 1) * 10))
    INSTANCE_P2P_TCP_PORT=$((BASE_P2P_TCP_PORT + (i - 1) * 10))
    INSTANCE_P2P_WS_PORT=$((BASE_P2P_WS_PORT + (i - 1) * 10))
    INSTANCE_P2P_V6_TCP_PORT=$((BASE_P2P_V6_TCP_PORT + (i - 1) * 10))
    INSTANCE_P2P_V6_WS_PORT=$((BASE_P2P_V6_WS_PORT + (i - 1) * 10))
    INSTANCE_TYPESENSE_PORT=$((BASE_TYPESENSE_PORT + (i - 1)))

    # 生成 docker-compose 配置
    cat <<EOF > docker-compose-$INSTANCE_NAME.yml
version: "3.8"
services:
  $INSTANCE_NAME:
    image: oceanprotocol/ocean-node:latest
    pull_policy: always
    container_name: $INSTANCE_NAME
    restart: always
    ports:
      - "$INSTANCE_HTTP_API_PORT:$INSTANCE_HTTP_API_PORT"
      - "$INSTANCE_P2P_TCP_PORT:$INSTANCE_P2P_TCP_PORT"
      - "$INSTANCE_P2P_WS_PORT:$INSTANCE_P2P_WS_PORT"
      - "$INSTANCE_P2P_V6_TCP_PORT:$INSTANCE_P2P_V6_TCP_PORT"
      - "$INSTANCE_P2P_V6_WS_PORT:$INSTANCE_P2P_V6_WS_PORT"
    environment:
      PRIVATE_KEY: '0x$(head -c 32 /dev/urandom | xxd -p)'
      RPCS: '{"1":{"rpc":"https://eth.drpc.org","fallbackRPCs":["https://eth-pokt.nodies.app","https://1rpc.io/eth","https://eth.merkle.io"],"chainId":1,"network":"ETH","chunkSize":100}}'
      DB_URL: "http://typesense-$i:$INSTANCE_TYPESENSE_PORT/?apiKey=xyz"
      IPFS_GATEWAY: 'https://ipfs.io/'
      ARWEAVE_GATEWAY: 'https://arweave.net/'
      INTERFACES: '["HTTP","P2P"]'
      ALLOWED_ADMINS: '["0x0a434fa3ebdc7304de53de92af9685cb5d18061a"]'
      DASHBOARD: 'true'
      HTTP_API_PORT: "$INSTANCE_HTTP_API_PORT"
      P2P_ENABLE_IPV4: 'true'
      P2P_ENABLE_IPV6: 'false'
      P2P_ipV4BindAddress: '0.0.0.0'
      P2P_ipV4BindTcpPort: "$INSTANCE_P2P_TCP_PORT"
      P2P_ipV4BindWsPort: "$INSTANCE_P2P_WS_PORT"
      P2P_ipV6BindAddress: '::'
      P2P_ipV6BindTcpPort: "$INSTANCE_P2P_V6_TCP_PORT"
      P2P_ipV6BindWsPort: "$INSTANCE_P2P_V6_WS_PORT"
      P2P_ANNOUNCE_ADDRESSES: '["/ip4/$PUBLIC_IP/tcp/$INSTANCE_P2P_TCP_PORT", "/ip4/$PUBLIC_IP/ws/tcp/$INSTANCE_P2P_WS_PORT"]'
    networks:
      - ocean_network
    depends_on:
      - typesense-$i

  typesense-$i:
    image: typesense/typesense:26.0
    container_name: typesense-$i
    ports:
      - "$INSTANCE_TYPESENSE_PORT:$INSTANCE_TYPESENSE_PORT"
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

    echo "生成的 docker-compose 配置文件: docker-compose-$INSTANCE_NAME.yml"
done

# 启动所有实例
for i in $(seq 1 $INSTANCE_COUNT); do
    docker-compose -f docker-compose-ocean-node-$i.yml up -d
done

echo "所有 $INSTANCE_COUNT 个实例已成功启动！"
