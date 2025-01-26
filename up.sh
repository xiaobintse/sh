#!/bin/bash

# 检查 Docker 是否安装
if ! command -v docker &>/dev/null; then
  echo "Docker 未安装，请安装 Docker 后再运行此脚本。"
  exit 1
fi

# 获取当前所有容器的名称列表（包括停止的容器）
running_containers=$(sudo docker ps -a --format "{{.Names}}")
echo "当前所有容器：$running_containers"  # 调试输出容器列表

# 标记是否有容器未运行
any_container_started=false

# 检查 hy1 到 hy700 的容器
for i in $(seq 1 500); do
  container_name="hy$i"

  # 如果容器没有运行，则启动该容器
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
        sudo docker compose up -d
        any_container_started=true
      else
        echo "$dir 中未找到 docker-compose.yml 文件，跳过该目录"
      fi

      popd  # 返回上级目录
    else
      echo "目录 $dir 不存在，跳过"
    fi
  fi
done

if $any_container_started; then
  echo "所有未运行的容器已启动。"
else
  echo "没有需要启动的容器。"
fi
