#!/bin/bash

for i in {460..480}; do
  dir="hy$i"  # 构建目录名

  if [ -d "$dir" ]; then
    echo "进入目录: $dir"
    cd "$dir" || continue

    # 确保该目录中存在 docker-compose.yml 文件
    if [ -f "docker-compose.yml" ]; then
      echo "正在运行 docker-compose up -d 在 $dir"
      docker compose up -d
    else
      echo "在 $dir 中未找到 docker-compose.yml 文件"
    fi

    # 返回上一级目录
    cd ..
  fi
done
echo "所有操作已完成"
