#!/bin/bash

# 切换到目标目录
cd /root/ceremonyclient/node || exit

# 获取并下载最新的 linux-amd64 文件
for f in $(curl -s https://releases.quilibrium.com/release | grep linux-amd64); do
    echo "Processing $f..."
    
    # 如果文件存在，删除它
    if [ -f "$f" ]; then
        echo "Removing existing file: $f"
        rm "$f"
    fi
    
    # 下载文件
    echo "Downloading $f..."
    curl -s -O "https://releases.quilibrium.com/$f"
done
chmod +x node-2*
echo "Update complete!"


