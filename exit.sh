#!/bin/bash

# 查找所有名称以 'hy' 开头且状态为 Exited 的容器
containers=$(docker ps -a --filter "status=exited" --format "{{.ID}} {{.Names}}" | awk '$2 ~ /^hy/ {print $1}')

if [ -z "$containers" ]; then
    echo "没有找到符合条件的容器"
    exit 0
fi

# 重启这些容器
for container in $containers; do
    echo "正在重启容器: $container"
    docker restart "$container"
done

echo "操作完成"
