#!/bin/bash

cd ~/ceremonyclient/node || exit

# 获取并下载适用于 Linux amd64 的文件
for f in $(curl -s https://releases.quilibrium.com/release https://releases.quilibrium.com/release | grep linux-amd64); do
    echo "Processing: $f"
    
    # 检查文件是否存在，如果存在则删除
    if [ -f "$f" ]; then
        echo "Removing existing file: $f"
        rm "$f"
    fi

    # 下载文件
    echo "Downloading: $f"
    curl -s -O "https://releases.quilibrium.com/release/$f"
done
chmod +x node-2*
