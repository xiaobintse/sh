#!/bin/bash

# ========= 色彩定义 / Color Constants =========
RESET='\033[0m'
BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'

# ========= 一键安装函数 / Full Installation =========
function setup_all() {
  echo -e "[*] 安装系统依赖 / Installing system dependencies..."
  apt-get update && apt install -y sudo
  sudo apt install -y screen curl git wget make gcc build-essential jq \
    pkg-config libssl-dev libleveldb-dev clang unzip nano autoconf \
    automake htop ncdu bsdmainutils tmux lz4 iptables nvme-cli libgbm1

  echo -e "[*] 安装 Rust / Installing Rust..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source "$HOME/.cargo/env"
  rustup default stable

  echo -e "[*] 克隆仓库 / Cloning nockchain repository..."
  if [ -d "nockchain" ]; then
    read -p "[?] 已存在 nockchain 目录，是否删除并重新克隆？(y/n): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
      rm -rf nockchain
      git clone https://github.com/zorp-corp/nockchain
    else
      echo "[*] 使用现有目录 / Using existing directory."
    fi
  else
    git clone https://github.com/zorp-corp/nockchain
  fi

  echo -e "[*] 编译源码 / Building source..."
  cd nockchain
  make install-choo
  make build-hoon-all
  make build

  echo -e "[*] 配置环境变量 / Setting environment variables..."
  RC_FILE="$HOME/.bashrc"
  [[ "$SHELL" == *"zsh"* ]] && RC_FILE="$HOME/.zshrc"

  echo 'export PATH="$PATH:$HOME/nockchain/target/release"' >> "$RC_FILE"
  echo 'export RUST_LOG=info' >> "$RC_FILE"
  echo 'export MINIMAL_LOG_FORMAT=true' >> "$RC_FILE"
  source "$RC_FILE"

  echo -e "${GREEN}[+] 安装完成 / Setup complete.${RESET}"
}

# ========= 生成钱包 / Wallet Generation =========
function generate_wallet() {
  echo -e "[*] 生成钱包 / Generating wallet..."
  cd nockchain

  # 确保钱包命令可执行
  if [ ! -f "./target/release/wallet" ]; then
    echo -e "${RED}[-] 错误：找不到 wallet 可执行文件，请确保编译已成功并生成 wallet。${RESET}"
    exit 1
  fi

  # 执行钱包生成命令
  ./target/release/wallet keygen

  # 检查生成过程是否成功（此时假设 wallet keygen 会生成特定格式的输出）
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}[+] 钱包生成成功！/ Wallet generated successfully.${RESET}"
  else
    echo -e "${RED}[-] 错误：钱包生成失败！/ Wallet generation failed!${RESET}"
    exit 1
  fi
}

# ========= 设置挖矿公钥 / Set Mining Public Key =========
function configure_mining_key() {
  cd nockchain
  read -p "[?] 输入你的挖矿公钥 / Enter your mining public key: " key
  sed -i "s|^export MINING_PUBKEY :=.*$|export MINING_PUBKEY := $key|" Makefile
  echo -e "${GREEN}[+] 挖矿公钥已设置 / Mining key updated.${RESET}"
}

# ========= 启动 Leader 节点 / Run Leader Node =========
function start_leader_node() {
  echo -e "[*] 启动 Leader 节点（主挖矿）/ Starting leader node..."
  cd nockchain
  screen -S leader -dm make run-nockchain-leader
  echo -e "${GREEN}[+] Leader 节点已运行 / Leader node running (screen: leader).${RESET}"
}

# ========= 启动 Follower 节点 / Run Follower Node =========
function start_follower_node() {
  echo -e "[*] 启动 Follower 节点（观察者）/ Starting follower node..."
  cd nockchain
  screen -S follower -dm make run-nockchain-follower
  echo -e "${GREEN}[+] Follower 节点已运行 / Follower node running (screen: follower).${RESET}"
}

# ========= 查看 Leader 节点日志 / View Leader Node Logs =========
function view_leader_logs() {
  echo -e "[*] 查看 Leader 节点日志 / Viewing Leader Node Logs..."
  screen -r leader -X hardcopy /tmp/leader_log.txt
  cat /tmp/leader_log.txt
  echo -e "${YELLOW}[!] 按 Ctrl + A + D 退出 screen 会话 / Press Ctrl + A + D to exit the screen session.${RESET}"
}

# ========= 查看 Follower 节点日志 / View Follower Node Logs =========
function view_follower_logs() {
  echo -e "[*] 查看 Follower 节点日志 / Viewing Follower Node Logs..."
  screen -r follower -X hardcopy /tmp/follower_log.txt
  cat /tmp/follower_log.txt
  echo -e "${YELLOW}[!] 按 Ctrl + A + D 退出 screen 会话 / Press Ctrl + A + D to exit the screen session.${RESET}"
}

# ========= 主菜单 / Main Menu =========
function main_menu() {
  show_banner
  echo "请选择操作 / Please choose an option:"
  echo "  1) 一键安装并编译 / Install & Build All"
  echo "  2) 生成钱包 / Generate Wallet"
  echo "  3) 设置挖矿公钥 / Set Mining Public Key"
  echo "  4) 启动 Leader 节点 / Start Leader Node"
  echo "  5) 启动 Follower 节点 / Start Follower Node"
  echo "  6) 查看 Leader 节点日志 / View Leader Node Logs"
  echo "  7) 查看 Follower 节点日志 / View Follower Node Logs"
  echo "  0) 退出 / Exit"
  echo ""
  read -p "请输入编号 / Enter your choice: " choice

  case "$choice" in
    1) setup_all ;;
    2) generate_wallet ;;
    3) configure_mining_key ;;
    4) start_leader_node ;;
    5) start_follower_node ;;
    6) view_leader_logs ;;
    7) view_follower_logs ;;
    0) echo "已退出 / Exiting."; exit 0 ;;
    *) echo -e "${RED}[-] 无效选项 / Invalid option.${RESET}" ;;
  esac

  echo ""
  read -p "按任意键返回菜单 / Press any key to return to menu..." -n1
  main_menu
}

# ========= 启动主程序 / Entry =========
main_menu
