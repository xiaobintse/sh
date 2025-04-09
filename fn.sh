#!/usr/bin/env bash

# 配置默认端口基值
BASE_HTTP_API_PORT=10001
BASE_P2P_TCP_PORT=21108
BASE_P2P_WS_PORT=32218
BASE_TYPESENSE_PORT=5999
BASE_IPV6_TCP_PORT=43328
BASE_IPV6_WS_PORT=54438

# 安装 Docker 的函数
install_docker() {
  # 检查 Docker 是否已安装
  if ! command -v docker &> /dev/null; then
    echo "Docker 没有安装，正在自动安装 Docker..."

    # 添加私钥:
    sudo apt-get update
    sudo apt-get install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # 添加存储库:
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update

    # 安装 Docker
    echo "安装 Docker..."
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # 启动并启用 Docker
    systemctl start docker
    systemctl enable docker

    echo "Docker 安装完成！"
  else
    echo "Docker 已经安装，跳过安装步骤。"
  fi
}

# 验证 IP 或 FQDN 的有效性
validate_ip_or_fqdn() {
  local address=$1
  if [[ "$address" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] || [[ "$address" =~ ^[a-zA-Z0-9.-]+$ ]]; then
    return 0
  else
    return 1
  fi
}

# 获取并验证公网IP或FQDN
get_user_input() {
  read -p "请输入容器实例的起始编号 (如 1): " START_NUM
  read -p "请输入容器实例的结束编号 (如 5): " END_NUM

  # 获取并验证公网IP或FQDN
  read -p "请输入公网IP或FQDN: " P2P_ANNOUNCE_ADDRESS

  if [ -n "$P2P_ANNOUNCE_ADDRESS" ]; then
    # 验证地址有效性
    validate_ip_or_fqdn "$P2P_ANNOUNCE_ADDRESS"
    if [ $? -ne 0 ]; then
      echo "无效的地址。退出脚本！"
      exit 1
    fi

    # 判断是 IPv4 地址还是 FQDN
    if [[ "$P2P_ANNOUNCE_ADDRESS" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      # IPv4 地址
      P2P_ANNOUNCE_ADDRESSES='["/ip4/'$P2P_ANNOUNCE_ADDRESS'/tcp/'$P2P_TCP_PORT'", "/ip4/'$P2P_ANNOUNCE_ADDRESS'/ws/tcp/'$P2P_WS_PORT'"]'
    elif [[ "$P2P_ANNOUNCE_ADDRESS" =~ ^[a-zA-Z0-9.-]+$ ]]; then
      # FQDN 地址，手动加上端口号
      P2P_ANNOUNCE_ADDRESSES='["/dns4/'$P2P_ANNOUNCE_ADDRESS'/tcp/'$P2P_TCP_PORT'", "/dns4/'$P2P_ANNOUNCE_ADDRESS'/ws/tcp/'$P2P_WS_PORT'"]'
    else
      echo "无效的 IP 或 FQDN 格式。退出脚本！"
      exit 1
    fi
  else
    P2P_ANNOUNCE_ADDRESSES=''
    echo "没有提供地址，Ocean Node 可能无法从其他节点访问。"
  fi
}

# 动态生成 ETH 钱包私钥
generate_eth_private_key() {
  echo "0x$(openssl rand -hex 32)"
}

# 保存私钥到文件
save_private_key() {
  local instance_name=$1
  local private_key=$2
  echo "$instance_name: $private_key" >> /root/fn.txt
}

# 生成实例配置
generate_instance() {
  for ((i = START_NUM; i <= END_NUM; i++)); do
    INSTANCE_NAME="hy$i"
    TYPESENSE_NAME="typ$i"

    # 动态计算端口
    HTTP_API_PORT=$((BASE_HTTP_API_PORT + i + 2))
    P2P_TCP_PORT=$((BASE_P2P_TCP_PORT + i + 2))
    P2P_WS_PORT=$((BASE_P2P_WS_PORT + i + 2))
    TYPESENSE_PORT=$((BASE_TYPESENSE_PORT + i + 1))
    IPV6_TCP_PORT=$((BASE_IPV6_TCP_PORT + i + 2))
    IPV6_WS_PORT=$((BASE_IPV6_WS_PORT + i + 2))

    # 动态生成 EVM 私钥
    PRIVATE_KEY=$(generate_eth_private_key)

    # 保存私钥到文件
    save_private_key "$INSTANCE_NAME" "$PRIVATE_KEY"

    # 创建容器实例的根目录
    ROOT_DIR="hy$i"
    mkdir -p "$ROOT_DIR"

    # 生成 docker-compose.yml
    cat <<EOF > "$ROOT_DIR/docker-compose.yml"
services:
  ocean-node:
    image: oceanprotocol/ocean-node:latest
    pull_policy: always
    container_name: $INSTANCE_NAME
    restart: unless-stopped
    ports:
      - "$HTTP_API_PORT:$HTTP_API_PORT"
      - "$P2P_TCP_PORT:$P2P_TCP_PORT"
      - "$P2P_WS_PORT:$P2P_WS_PORT"
      - "$IPV6_TCP_PORT:$IPV6_TCP_PORT"
      - "$IPV6_WS_PORT:$IPV6_WS_PORT"
    environment:
      PRIVATE_KEY: "$PRIVATE_KEY"
      RPCS: 
      DB_URL: "http://$TYPESENSE_NAME:$TYPESENSE_PORT/?apiKey=xyz"
      IPFS_GATEWAY: "https://ipfs.io/"
      ARWEAVE_GATEWAY: "https://arweave.net/"
      INTERFACES: '["HTTP","P2P"]'
      ALLOWED_ADMINS: '["0x0a434fa3ebdc7304de53de92af9685cb5d18061a"]'
      HTTP_API_PORT: "$HTTP_API_PORT"
      P2P_ENABLE_IPV4: "true"
      P2P_ENABLE_IPV6: "false"
      P2P_ipV4BindAddress: "0.0.0.0"
      P2P_ipV4BindTcpPort: "$P2P_TCP_PORT"
      P2P_ipV4BindWsPort: "$P2P_WS_PORT"
      P2P_ipV6BindAddress: "::"
      P2P_ipV6BindTcpPort: "$IPV6_TCP_PORT"
      P2P_ipV6BindWsPort: "$IPV6_WS_PORT"
      P2P_ANNOUNCE_ADDRESSES: "$P2P_ANNOUNCE_ADDRESSES"
      DASHBOARD: "true"
    networks:
      - ocean_network
    depends_on:
      - typesense

  typesense:
    image: typesense/typesense:26.0
    container_name: $TYPESENSE_NAME
    ports:
      - "$TYPESENSE_PORT:$TYPESENSE_PORT"
    networks:
      - ocean_network
    volumes:
      - typesense-data:/data
    command: "--data-dir /data --api-key=xyz"

volumes:
  typesense-data:
    driver: local

networks:
  ocean_network:
    driver: bridge
EOF

    echo "生成实例 $INSTANCE_NAME 的配置文件完成：$ROOT_DIR/docker-compose.yml"
  done
}

# 启动容器实例
start_containers() {
  for ((i = START_NUM; i <= END_NUM; i++)); do
    ROOT_DIR="hy$i"
    echo "正在启动实例 $ROOT_DIR 的容器..."
    (cd "$ROOT_DIR" && docker compose up -d)
  done
}

# 处理私钥文件
process_private_keys() {
  echo "正在处理私钥文件..."
  sed 's/^hy[1-9][0-9]*: //' /root/fn.txt > /root/fn1.txt
  echo "私钥文件处理完成，已保存到 /root/fn1.txt。"
}

# 主脚本逻辑
main() {
  # 自动安装 Docker
  install_docker

  get_user_input
  generate_instance
  start_containers
  process_private_keys
  echo "所有容器实例已启动！"
  echo "生成的私钥已保存到 /root/fn.txt 和 /root/fn1.txt。"
}

# 执行主脚本
main
