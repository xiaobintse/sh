#!/bin/bash

LOG_FILE="$HOME/.shaicoin/shaicoin.log"  # 定义日志文件路径
INSTALL_DIR="$HOME/shaicoin"              # 定义安装目录
BACKUP_DIR="$HOME/shaicoin_backup"        # 定义备份目录

# 打印菜单选项
function show_menu() {
    echo "================================="
    echo " Shaicoin 一键安装和管理脚本"
    echo "================================="
    echo "请选择一个选项:"
    echo "1) 安装并启动节点"
    echo "2) 创建钱包"
    echo "3) 开始挖矿"
    echo "4) 查询钱包信息"
    echo "5) 查询收益"
    echo "6) 查看节点日志"
    echo "7) 备份重要文件"
    echo "8) 卸载节点（保留依赖）"
    echo "9) 退出"
    echo "================================="
}

# 等待用户按回车继续
function pause() {
    read -p "按回车键返回菜单..."
}

# 安装并启动节点
function install_and_start_node() {
    echo "开始安装依赖、编译源代码并启动节点..."

    # 1. 安装依赖
    echo "正在安装依赖..."
    sudo apt update
    sudo apt install -y build-essential libtool autotools-dev automake pkg-config bsdmainutils python3 libevent-dev libboost-dev libsqlite3-dev || { echo "依赖安装失败"; exit 1; }
    echo "依赖安装完成。"

    # 2. 拉取并编译 Shaicoin 源代码
    echo "正在拉取并编译 Shaicoin 源代码..."
    git clone https://github.com/shaicoin/shaicoin.git "$INSTALL_DIR"
    cd "$INSTALL_DIR" || { echo "无法进入安装目录"; exit 1; }
    ./autogen.sh
    ./configure
    make -j$(nproc) || { echo "代码编译失败"; exit 1; }
    echo "代码编译完成。"

    # 3. 确保日志目录存在
    echo "确保日志目录存在..."
    mkdir -p "$HOME/.shaicoin"

    # 4. 启动节点并手动添加引导节点
    echo "正在启动节点..."
    ./src/shaicoind -addnode=51.161.117.199:42069 -addnode=139.60.161.14:42069 -addnode=149.50.101.189:21026 -addnode=3.21.125.80:42069 > "$LOG_FILE" 2>&1 &
    echo "节点启动完成，日志已记录到 $LOG_FILE 。"

    pause
}

# 创建钱包
function create_wallet() {
    echo "请输入钱包名称: "
    read wallet_name
    ./src/shaicoin-cli createwallet "$wallet_name"
    ./src/shaicoin-cli loadwallet "$wallet_name"
    wallet_address=$(./src/shaicoin-cli getnewaddress)
    echo "新钱包地址为: $wallet_address"

    pause
}

# 开始挖矿
function start_mining() {
    echo "正在关闭之前的临时节点..."
    pkill -f shaicoind  # 停止当前的节点进程
    
    echo "请输入钱包地址以开始挖矿: "
    read wallet_address
    echo "正在启动挖矿..."
    ./src/shaicoind -moneyplz="$wallet_address" -addnode=51.161.117.199:42069 -addnode=139.60.161.14:42069 -addnode=149.50.101.189:21026 -addnode=3.21.125.80:42069 > "$LOG_FILE" 2>&1 &
    echo "挖矿已开始，日志已记录到 $LOG_FILE 。"

    pause
}

# 查询钱包信息
function check_wallet_info() {
    echo "正在查询钱包信息..."
    ./src/shaicoin-cli getwalletinfo

    pause
}

# 查询收益
function check_mining_rewards() {
    echo "正在查询挖矿收益..."
    ./src/shaicoin-cli getwalletinfo | grep "balance"
    pause
}

# 查看节点日志
function view_logs() {
    if [ -f "$LOG_FILE" ]; then
        echo "正在显示节点日志: "
        cat "$LOG_FILE"
    else
        echo "日志文件不存在或节点尚未启动。"
    fi

    pause
}

# 备份重要文件
function backup_important_files() {
    echo "正在备份重要文件..."
    
    # 创建备份目录（如果不存在）
    mkdir -p "$BACKUP_DIR"
    
    # 备份钱包数据
    cp -r "$HOME/.shaicoin" "$BACKUP_DIR"
    
    # 确认备份成功
    if [ $? -eq 0 ]; then
        echo "备份完成。备份文件位于 $BACKUP_DIR"
    else
        echo "备份失败。"
    fi

    pause
}

# 卸载节点
function uninstall_node() {
    echo "正在卸载节点..."
    
    # 停止节点进程
    pkill -f shaicoind
    echo "节点已停止。"

    # 删除编译目录
    if [ -d "$INSTALL_DIR" ]; then
        rm -rf "$INSTALL_DIR"
        echo "节点文件已删除。"
    else
        echo "未找到安装目录。"
    fi

    # 删除日志文件
    if [ -f "$LOG_FILE" ]; then
        rm "$LOG_FILE"
        echo "日志文件已删除。"
    else
        echo "未找到日志文件。"
    fi

    echo "节点卸载完成，依赖保留。"
    pause
}

# 主程序循环
while true; do
    show_menu
    read -p "请选择操作: " choice
    case $choice in
        1)
            install_and_start_node
            ;;
        2)
            create_wallet
            ;;
        3)
            start_mining
            ;;
        4)
            check_wallet_info
            ;;
        5)
            check_mining_rewards
            ;;
        6)
            view_logs
            ;;
        7)
            backup_important_files
            ;;
        8)
            uninstall_node
            ;;
        9)
            echo "退出脚本。"
            exit 0
            ;;
        *)
            echo "无效选项，请重新选择。"
            ;;
    esac
done
