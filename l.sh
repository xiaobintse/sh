#!/bin/bash
# 遇到错误立即停止
set -e

# 1. 首先进入脚本自身所在的目录
cd "$(dirname "$0")"

# 2. 检查并安装 screen (兼容非 root 用户与 root 用户)
if ! command -v screen &> /dev/null; then
    echo "未检测到 screen，正在自动安装..."
    if command -v sudo &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y screen
    else
        apt-get update && apt-get install -y screen
    fi
fi

# 3. 检查 seine 是否存在，不存在则下载解压
# 请务必确认下载版本有效，若 v0.2.17 报错可降为发布版本
VERSION="v0.2.17"
DOWNLOAD_URL="https://github.com/zpalmtree/seine/releases/download/${VERSION}/seine-linux-x86_64.tar.gz"

if [ ! -f "./seine" ]; then
    echo "未检测到 seine 执行文件，开始下载 ${VERSION}..."
    wget "${DOWNLOAD_URL}" -O seine.tar.gz
    tar -zxvf seine.tar.gz
    rm -f seine.tar.gz
fi

chmod +x ./seine

# 4. 设定 Screen 会话名称
SESSION_NAME="seine_miner"

# 5. 检查是否已经有同名的 screen 会话在运行
if screen -list | grep -q "\.${SESSION_NAME}"; then
    echo "检测到名为 $SESSION_NAME 的进程已经在运行！"
    echo "如果需要重启，请先执行命令结束旧进程: screen -S $SESSION_NAME -X quit"
    exit 1
fi

echo "正在后台启动 seine..."

# 6. 使用 screen 在后台启动程序，并将日志重定向输出到 seine.log 便于排查
screen -dmS $SESSION_NAME bash -c "./seine \
  --mode pool \
  --address '4CJjvdUkuMkw7o9E2w2rWkLcNdBCAfnHBYPLUohjesjZEYh6j3eszoWzmWYCkfEiB14zqQ2ykCZWQdpLLS8xSbB9bPU8X' \
  --pool-url 'stratum+tcp://bntpool.com:3333' \
  --pool-worker \"$(hostname)\" \
  --backend cpu \
  --threads 14 2>&1 | tee seine.log"

sleep 1

# 检查是否成功驻留后台
if screen -list | grep -q "\.${SESSION_NAME}"; then
    echo "====================================================="
    echo "✅ 启动成功！程序已在后台 screen 会话 [$SESSION_NAME] 中运行。"
    echo ""
    echo "【常用管理命令】"
    echo "👉 查看实时控制台 : screen -r $SESSION_NAME"
    echo "👉 查看崩溃日志   : cat seine.log"
    echo "👉 退出并保持后台 : 先按 Ctrl + A，松开后按 D"
    echo "👉 彻底停止并关闭 : screen -S $SESSION_NAME -X quit"
    echo "====================================================="
else
    echo "❌ 启动失败：程序在后台启动后立即退出了！"
    echo "请执行 'cat seine.log' 查看具体报错日志。"
    exit 1
fi
