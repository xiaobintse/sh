#!/bin/bash

for dir in hy*/; do
  # 检查是否为目录
  if [ -d "$dir" ]; then
    echo "进入目录: $dir"
    cd "$dir" || { echo "无法进入目录 $dir"; continue; }

    echo "正在清理 Docker 系统..."
    if ! (docker system prune -a -f && docker volume prune -f && docker network prune -f); then
      echo "Docker 清理失败，退出 $dir"
      cd ..
      continue
    fi

 echo "正在更新 DNS 配置..."
    sudo bash -c 'echo -e "nameserver 8.8.8.8\nnameserver 8.8.4.4" > /etc/resolv.conf'

    # 确保存在 docker-compose.yml 文件
    if [ -f "docker-compose.yml" ]; then
      echo "正在启动 Docker Compose 服务..."
      if ! docker compose up -d; then
        echo "Docker Compose 启动失败，退出 $dir"
      fi
    else
      echo "未找到 docker-compose.yml 文件，跳过 $dir"
    fi

    cd ..
  fi
done

echo "所有操作已完成"
sudo reboot