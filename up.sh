#!/bin/bash

# 检查 Docker 是否安装
if ! command -v docker &>/dev/null; then
  echo "Docker 未安装，请安装 Docker 后再运行此脚本。"
  exit 1
fi

for dir in hy*/; do
  if [ -d "$dir" ]; then
    echo "进入目录: $dir"
    pushd "$dir" || continue  # 使用 pushd 保存当前目录，之后用 popd 返回

    # 在进入目录后先执行清理命令
    echo "正在清理 Docker 系统..."
    docker system prune -a -f && docker volume prune -f && docker network prune -f
    if [ $? -ne 0 ]; then
      echo "Docker 清理命令执行失败，退出当前目录。"
      popd
      continue
    fi

    # 更新 DNS 配置
    echo "正在更新 DNS 配置..."
    echo -e "nameserver 8.8.8.8\nnameserver 8.8.4.4" > /etc/resolv.conf
    source ~/.bashrc  # 刷新当前 shell 环境

    # 确保该目录中存在 docker-compose.yml 文件
    if [ -f "docker-compose.yml" ]; then
      echo "正在更新正在运行 docker-compose up -d 配置 在 $dir"

      # 运行 docker-compose up -d
      echo "正在运行 docker-compose up -d 在 $dir"
      docker compose up -d
    else
      echo "在 $dir 中未找到 docker-compose.yml 文件"
    fi

    popd  # 返回上级目录
  fi
done
sudo reboot
echo "所有操作已完成"
