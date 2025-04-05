#!/usr/bin/env bash

# 检查是否以 root 用户运行脚本
if [ "$(id -u)" != "0" ]; then
    echo "此脚本需要以 root 用户权限运行。"
    echo "请尝试使用 'sudo -i' 命令切换到 root 用户，然后再次运行此脚本。"
    exit 1
fi

# 脚本保存路径
SCRIPT_PATH="$HOME/rit.sh"

# 日志文件路径
LOG_FILE="/root/ritual_install.log"
DOCKER_LOG_FILE="/root/infernet_node.log"

# 初始化日志文件
echo "Ritual 脚本日志 - $(date)" > "$LOG_FILE"
echo "Docker 容器日志 - $(date)" > "$DOCKER_LOG_FILE"

# 主菜单函数
function main_menu() {
    while true; do
        clear
        echo "风男提示你脚本免费开源，请勿相信收费" | tee -a "$LOG_FILE"
        echo "推特 @tsexiao" | tee -a "$LOG_FILE"
        echo "================================================================" | tee -a "$LOG_FILE"
        echo "退出脚本，请按键盘 ctrl + C 退出即可" | tee -a "$LOG_FILE"
        echo "请选择要执行的操作:" | tee -a "$LOG_FILE"
        echo "1) 安装 Ritual 节点" | tee -a "$LOG_FILE"
        echo "2. 查看 Ritual 节点日志" | tee -a "$LOG_FILE"
        echo "3. 删除 Ritual 节点" | tee -a "$LOG_FILE"
        echo "4. 退出脚本" | tee -a "$LOG_FILE"
        
        read -p "请输入您的选择: " choice
        echo "用户选择: $choice" >> "$LOG_FILE"

        case $choice in
            1) 
                install_ritual_node
                ;;
            2)
                view_logs
                ;;
            3)
                remove_ritual_node
                ;;
            4)
                echo "退出脚本！" | tee -a "$LOG_FILE"
                exit 0
                ;;
            *)
                echo "无效选项，请重新选择。" | tee -a "$LOG_FILE"
                ;;
        esac

        echo "按任意键继续..." | tee -a "$LOG_FILE"
        read -n 1 -s
    done
}

# 安装 Ritual 节点函数
function install_ritual_node() {
    echo "开始安装 Ritual 节点 - $(date)" | tee -a "$LOG_FILE"
    
    # 系统更新及必要的软件包安装 (包含 Python 和 pip)
    echo "系统更新及安装必要的包..." | tee -a "$LOG_FILE"
    sudo apt update && sudo apt upgrade -y >> "$LOG_FILE" 2>&1
    sudo apt -qy install curl git jq lz4 build-essential screen python3 python3-pip >> "$LOG_FILE" 2>&1

    # 安装或升级 Python 包
    echo "[提示] 升级 pip3 并安装 infernet-cli / infernet-client" | tee -a "$LOG_FILE"
    pip3 install --upgrade pip >> "$LOG_FILE" 2>&1
    pip3 install infernet-cli infernet-client >> "$LOG_FILE" 2>&1

    # 检查 Docker 是否已安装
    echo "检查 Docker 是否已安装..." | tee -a "$LOG_FILE"
    if command -v docker &> /dev/null; then
        echo " - Docker 已安装，跳过此步骤。" | tee -a "$LOG_FILE"
    else
        echo " - Docker 未安装，正在进行安装..." | tee -a "$LOG_FILE"
        sudo apt update >> "$LOG_FILE" 2>&1
        sudo apt install -y apt-transport-https ca-certificates curl software-properties-common >> "$LOG_FILE" 2>&1
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - >> "$LOG_FILE" 2>&1
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" >> "$LOG_FILE" 2>&1
        sudo apt update >> "$LOG_FILE" 2>&1
        sudo apt install -y docker-ce docker-ce-cli containerd.io >> "$LOG_FILE" 2>&1
        sudo systemctl enable docker >> "$LOG_FILE" 2>&1
        sudo systemctl start docker >> "$LOG_FILE" 2>&1
        echo "Docker 安装完成，当前版本：" | tee -a "$LOG_FILE"
        docker --version >> "$LOG_FILE" 2>&1
    fi

    # 检查 Docker Compose 安装情况
    echo "检查 Docker Compose 是否已安装..." | tee -a "$LOG_FILE"
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        echo " - Docker Compose 未安装，正在进行安装..." | tee -a "$LOG_FILE"
        sudo curl -L "https://github.com/docker/compose/releases/download/v2.29.2/docker-compose-$(uname -s)-$(uname -m)" \
            -o /usr/local/bin/docker-compose >> "$LOG_FILE" 2>&1
        sudo chmod +x /usr/local/bin/docker-compose >> "$LOG_FILE" 2>&1
    else
        echo " - Docker Compose 已安装，跳过此步骤。" | tee -a "$LOG_FILE"
    fi

    echo "[确认] Docker Compose 版本:" | tee -a "$LOG_FILE"
    docker compose version >> "$LOG_FILE" 2>&1 || docker-compose version >> "$LOG_FILE" 2>&1

    # 安装 Foundry 并设置环境变量
    echo "安装 Foundry " | tee -a "$LOG_FILE"
    if pgrep anvil &>/dev/null; then
        echo "[警告] anvil 正在运行，正在关闭以更新 Foundry。" | tee -a "$LOG_FILE"
        pkill anvil
        sleep 2
    fi

    cd ~ || exit 1
    mkdir -p foundry
    cd foundry
    curl -L https://foundry.paradigm.xyz | bash >> "$LOG_FILE" 2>&1
    $HOME/.foundry/bin/foundryup >> "$LOG_FILE" 2>&1
    if [[ ":$PATH:" != *":$HOME/.foundry/bin:"* ]]; then
        export PATH="$HOME/.foundry/bin:$PATH"
    fi

    echo "[确认] forge 版本:" | tee -a "$LOG_FILE"
    forge --version >> "$LOG_FILE" 2>&1 || {
        echo "[错误] 无法找到 forge 命令，可能是 ~/.foundry/bin 未添加到 PATH 或安装失败。" | tee -a "$LOG_FILE"
        exit 1
    }

    if [ -f /usr/bin/forge ]; then
        echo "[提示] 删除 /usr/bin/forge..." | tee -a "$LOG_FILE"
        sudo rm /usr/bin/forge
    fi

    echo "[提示] Foundry 安装及环境变量配置完成。" | tee -a "$LOG_FILE"
    cd ~ || exit 1

    # 克隆 infernet-container-starter
    if [ -d "infernet-container-starter" ]; then
        echo "目录 infernet-container-starter 已存在，正在删除..." | tee -a "$LOG_FILE"
        rm -rf "infernet-container-starter"
    fi

    echo "克隆 infernet-container-starter..." | tee -a "$LOG_FILE"
    git clone https://github.com/ritual-net/infernet-container-starter >> "$LOG_FILE" 2>&1
    cd infernet-container-starter || { echo "[错误] 进入目录失败" | tee -a "$LOG_FILE"; exit 1; }

    # 修改 deploy/docker-compose.yaml 中的端口映射
    echo "修改 docker-compose.yaml 中的端口映射..." | tee -a "$LOG_FILE"
    DOCKER_COMPOSE_FILE="deploy/docker-compose.yaml"
    if [ -f "$DOCKER_COMPOSE_FILE" ]; then
        sed -i 's/0.0.0.0:1112:1112/0.0.0.0:6666:6666/' "$DOCKER_COMPOSE_FILE" >> "$LOG_FILE" 2>&1
        sed -i 's/1006:1006/1000:1000/' "$DOCKER_COMPOSE_FILE" >> "$LOG_FILE" 2>&1
    else
        echo "[错误] 未找到 $DOCKER_COMPOSE_FILE 文件，端口修改失败" | tee -a "$LOG_FILE"
    fi

    # 拉取 Docker 镜像
    echo "拉取 Docker 镜像..." | tee -a "$LOG_FILE"
    docker pull ritualnetwork/hello-world-infernet:latest >> "$LOG_FILE" 2>&1

    # 在 screen 会话中进行初始部署，并启用日志
    echo "检查 screen 会话 ritual 是否存在..." | tee -a "$LOG_FILE"
    if screen -list | grep -q "ritual"; then
        echo "[提示] 发现 ritual 会话正在运行，正在终止..." | tee -a "$LOG_FILE"
        screen -S ritual -X quit
        sleep 1
    fi

    echo "在 screen -S ritual 会话中开始容器部署，并记录日志到 /root/ritual_screen.log..." | tee -a "$LOG_FILE"
    screen -S ritual -L -Logfile /root/ritual_screen.log -dm bash -c 'project=hello-world make deploy-container; exec bash'
    echo "[提示] 部署工作正在后台的 screen 会话 (ritual) 中进行，日志保存至 /root/ritual_screen.log" | tee -a "$LOG_FILE"

    # 用户输入 (Private Key)
    echo "配置 Ritual Node 文件..." | tee -a "$LOG_FILE"
    read -p "请输入您的 Private Key (0x...): " PRIVATE_KEY
    echo "用户输入 Private Key: [隐藏]" >> "$LOG_FILE"

    # 默认设置
    RPC_URL="https://mainnet.base.org/"
    RPC_URL_SUB="https://mainnet.base.org/"
    REGISTRY="0x3B1554f346DFe5c482Bb4BA31b880c1C18412170"
    SLEEP=3
    START_SUB_ID=160000
    BATCH_SIZE=50
    TRAIL_HEAD_BLOCKS=3
    INFERNET_VERSION="1.4.0"

    # 修改配置文件
    sed -i "s|\"registry_address\": \".*\"|\"registry_address\": \"$REGISTRY\"|" deploy/config.json >> "$LOG_FILE" 2>&1
    sed -i "s|\"private_key\": \".*\"|\"private_key\": \"$PRIVATE_KEY\"|" deploy/config.json >> "$LOG_FILE" 2>&1
    sed -i "s|\"sleep\": [0-9]*|\"sleep\": $SLEEP|" deploy/config.json >> "$LOG_FILE" 2>&1
    sed -i "s|\"starting_sub_id\": [0-9]*|\"starting_sub_id\": $START_SUB_ID|" deploy/config.json >> "$LOG_FILE" 2>&1
    sed -i "s|\"batch_size\": [0-9]*|\"batch_size\": $BATCH_SIZE|" deploy/config.json >> "$LOG_FILE" 2>&1
    sed -i "s|\"trail_head_blocks\": [0-9]*|\"trail_head_blocks\": $TRAIL_HEAD_BLOCKS|" deploy/config.json >> "$LOG_FILE" 2>&1
    sed -i 's|"rpc_url": ".*"|"rpc_url": "https://mainnet.base.org"|' deploy/config.json >> "$LOG_FILE" 2>&1
    sed -i 's|"rpc_url": ".*"|"rpc_url": "https://mainnet.base.org"|' projects/hello-world/container/config.json >> "$LOG_FILE" 2>&1

    sed -i "s|\"registry_address\": \".*\"|\"registry_address\": \"$REGISTRY\"|" projects/hello-world/container/config.json >> "$LOG_FILE" 2>&1
    sed -i "s|\"private_key\": \".*\"|\"private_key\": \"$PRIVATE_KEY\"|" projects/hello-world/container/config.json >> "$LOG_FILE" 2>&1
    sed -i "s|\"sleep\": [0-9]*|\"sleep\": $SLEEP|" projects/hello-world/container/config.json >> "$LOG_FILE" 2>&1
    sed -i "s|\"starting_sub_id\": [0-9]*|\"starting_sub_id\": $START_SUB_ID|" projects/hello-world/container/config.json >> "$LOG_FILE" 2>&1
    sed -i "s|\"batch_size\": [0-9]*|\"batch_size\": $BATCH_SIZE|" projects/hello-world/container/config.json >> "$LOG_FILE" 2>&1
    sed -i "s|\"trail_head_blocks\": [0-9]*|\"trail_head_blocks\": $TRAIL_HEAD_BLOCKS|" projects/hello-world/container/config.json >> "$LOG_FILE" 2>&1

    sed -i "s|\(registry\s*=\s*\).*|\1$REGISTRY;|" projects/hello-world/contracts/script/Deploy.s.sol >> "$LOG_FILE" 2>&1
    sed -i "s|\(RPC_URL\s*=\s*\).*|\1\"$RPC_URL\";|" projects/hello-world/contracts/script/Deploy.s.sol >> "$LOG_FILE" 2>&1

    sed -i 's|ritualnetwork/infernet-node:[^"]*|ritualnetwork/infernet-node:latest|' deploy/docker-compose.yaml >> "$LOG_FILE" 2>&1

    MAKEFILE_PATH="projects/hello-world/contracts/Makefile"
    sed -i "s|^sender := .*|sender := $PRIVATE_KEY|" "$MAKEFILE_PATH" >> "$LOG_FILE" 2>&1
    sed -i "s|^RPC_URL := .*|RPC_URL := $RPC_URL|" "$MAKEFILE_PATH" >> "$LOG_FILE" 2>&1

    # 启动容器并将日志重定向
    cd ~/infernet-container-starter || exit 1
    echo "docker compose down & up..." | tee -a "$LOG_FILE"
    docker compose -f deploy/docker-compose.yaml down >> "$LOG_FILE" 2>&1
    docker compose -f deploy/docker-compose.yaml up -d >> "$LOG_FILE" 2>&1
    echo "[提示] 容器正在后台 (-d) 运行，日志将被重定向到 $DOCKER_LOG_FILE" | tee -a "$LOG_FILE"

    # 将 Docker 日志输出到文件，并监控大小
    echo "配置 Docker 日志输出到 $DOCKER_LOG_FILE，并监控大小（超过500MB自动清理）..." | tee -a "$LOG_FILE"
    (
        while true; do
            docker logs -f infernet-node >> "$DOCKER_LOG_FILE" 2>&1 &
            LOG_PID=$!
            while kill -0 $LOG_PID 2>/dev/null; do
                LOG_SIZE=$(stat -c%s "$DOCKER_LOG_FILE" 2>/dev/null || echo 0)
                if [ "$LOG_SIZE" -ge $((500 * 1024 * 1024)) ]; then  # 500MB = 500 * 1024 * 1024 bytes
                    echo "[$DOCKER_LOG_FILE] 日志大小达到 ${LOG_SIZE} 字节（超过500MB），正在清理..." | tee -a "$LOG_FILE"
                    kill $LOG_PID 2>/dev/null
                    echo "Docker 容器日志 - $(date)" > "$DOCKER_LOG_FILE"  # 清空并重新初始化
                    echo "[$DOCKER_LOG_FILE] 已清理完成，新日志将继续写入。" | tee -a "$LOG_FILE"
                    break
                fi
                sleep 60  # 每分钟检查一次
            done
            wait $LOG_PID 2>/dev/null
        done
    ) &

    # 安装 Forge 库
    echo "安装 Forge (项目依赖)" | tee -a "$LOG_FILE"
    cd projects/hello-world/contracts || exit 1
    rm -rf lib/forge-std
    rm -rf lib/infernet-sdk
    forge install --no-commit foundry-rs/forge-std >> "$LOG_FILE" 2>&1
    forge install --no-commit ritual-net/infernet-sdk >> "$LOG_FILE" 2>&1

    # 重启容器
    echo "重启 docker compose..." | tee -a "$LOG_FILE"
    cd ~/infernet-container-starter || exit 1
    docker compose -f deploy/docker-compose.yaml down >> "$LOG_FILE" 2>&1
    docker compose -f deploy/docker-compose.yaml up -d >> "$LOG_FILE" 2>&1
    echo "[提示] 查看 infernet-node 日志：tail -f $DOCKER_LOG_FILE" | tee -a "$LOG_FILE"

    # 部署项目合约
    echo "部署项目合约..." | tee -a "$LOG_FILE"
    DEPLOY_OUTPUT=$(project=hello-world make deploy-contracts 2>&1)
    echo "$DEPLOY_OUTPUT" | tee -a "$LOG_FILE"

    NEW_ADDR=$(echo "$DEPLOY_OUTPUT" | grep -oP 'Deployed SaysHello:\s+\K0x[0-9a-fA-F]{40}')
    if [ -z "$NEW_ADDR" ]; then
        echo "[警告] 未找到新合约地址。可能需要手动更新 CallContract.s.sol。" | tee -a "$LOG_FILE"
    else
        echo "[提示] 部署的 SaysHello 地址: $NEW_ADDR" | tee -a "$LOG_FILE"
        sed -i "s|SaysGM saysGm = SaysGM(0x[0-9a-fA-F]\+);|SaysGM saysGm = SaysGM($NEW_ADDR);|" \
            projects/hello-world/contracts/script/CallContract.s.sol >> "$LOG_FILE" 2>&1
        echo "使用新地址执行 call-contract..." | tee -a "$LOG_FILE"
        project=hello-world make call-contract >> "$LOG_FILE" 2>&1
    fi

    echo "===== Ritual Node 安装完成 =====" | tee -a "$LOG_FILE"
    read -n 1 -s -r -p "按任意键返回主菜单..."
    main_menu
}

# 查看 Ritual 节点日志
function view_logs() {
    echo "正在查看 Ritual 节点日志（实时输出到 $DOCKER_LOG_FILE）..." | tee -a "$LOG_FILE"
    tail -f "$DOCKER_LOG_FILE"
}

# 删除 Ritual 节点
function remove_ritual_node() {
    echo "正在删除 Ritual 节点 - $(date)" | tee -a "$LOG_FILE"

    # 停止并移除 Docker 容器
    echo "停止并移除 Docker 容器..." | tee -a "$LOG_FILE"
    cd /root/infernet-container-starter || echo "目录不存在，跳过 docker compose down" | tee -a "$LOG_FILE"
    if [ -d "/root/infernet-container-starter" ]; then
        docker compose down >> "$LOG_FILE" 2>&1
    fi

    # 逐个停止并删除容器
    containers=(
        "infernet-node"
        "infernet-fluentbit"
        "infernet-redis"
        "infernet-anvil"
        "hello-world"
    )
    
    for container in "${containers[@]}"; do
        if [ "$(docker ps -aq -f name=$container)" ]; then
            echo "Stopping and removing $container..." | tee -a "$LOG_FILE"
            docker stop "$container" >> "$LOG_FILE" 2>&1
            docker rm "$container" >> "$LOG_FILE" 2>&1
        fi
    done

    # 删除相关文件
    echo "删除相关文件..." | tee -a "$LOG_FILE"
    rm -rf ~/infernet-container-starter >> "$LOG_FILE" 2>&1

    # 删除 Docker 镜像
    echo "删除 Docker 镜像..." | tee -a "$LOG_FILE"
    docker rmi -f ritualnetwork/hello-world-infernet:latest >> "$LOG_FILE" 2>&1
    docker rmi -f ritualnetwork/infernet-node:latest >> "$LOG_FILE" 2>&1
    docker rmi -f fluent/fluent-bit:3.1.4 >> "$LOG_FILE" 2>&1
    docker rmi -f redis:7.4.0 >> "$LOG_FILE" 2>&1
    docker rmi -f ritualnetwork/infernet-anvil:1.0.0 >> "$LOG_FILE" 2>&1

    # 清理后台日志进程
    echo "清理后台日志进程..." | tee -a "$LOG_FILE"
    pkill -f "docker logs -f infernet-node" 2>/dev/null || echo "无后台日志进程需要清理" | tee -a "$LOG_FILE"

    echo "Ritual 节点已成功删除！" | tee -a "$LOG_FILE"
}

# 调用主菜单函数
main_menu
