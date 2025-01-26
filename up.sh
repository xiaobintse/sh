#!/bin/bash

# 检查 Docker 是否安装
if ! command -v docker &>/dev/null; then
  echo "Docker 未安装，请安装 Docker 后再运行此脚本。"
  exit 1
fi

# 获取当前正在运行的容器列表
running_containers=$(docker ps --format "{{.Names}}")

# 检查 hy1 到 hy700 的容器是否都在运行
for i in $(seq 1 700); do
  container_name="hy$i"

  if [[ ! " ${running_containers[@]} " =~ " ${container_name} " ]]; then
    echo "容器 $container_name 未运行，准备启动..."

    # 查找对应目录并进入
    dir="hy$i/"
    if [ -d "$dir" ]; then
      echo "进入目录: $dir"
      pushd "$dir" || continue  # 进入目录

      # 确保该目录中存在 docker-compose.yml 文件
      if [ -f "docker-compose.yml" ]; then
        echo "正在启动容器 $container_name 在 $dir"
        docker compose up -d
      else
        echo "$dir 中未找到 docker-compose.yml 文件，跳过该目录"
      fi

      popd  # 返回上级目录
    else
      echo "目录 $dir 不存在，跳过"
    fi
  fi
done
sudo reboot

