#!/bin/bash

# 设置 RPCS 字符串的基本结构
RPCS='{"1":{"rpc":"https://optimism.drpc.org","fallbackRPCs":["https://optimism.drpc.org"],"chainId":1,"network":"ETH","chunkSize":100}}'

# 自动进入每个以 hy 开头的目录并更新 docker-compose.yml 中的 RPCS 配置
for dir in hy*/; do
  if [ -d "$dir" ]; then
    echo "进入目录: $dir"
    cd "$dir" || continue

    # 确保该目录中存在 docker-compose.yml 文件
    if [ -f "docker-compose.yml" ]; then
      echo "正在更新 docker-compose.yml 中的 RPCS 配置 在 $dir"
      
      # 使用 sed 命令更新 RPCS 配置
      sed -i "s|RPCS:.*|RPCS: '$RPCS'|" docker-compose.yml

      # 运行 docker-compose up -d
      echo "正在运行 docker-compose up -d 在 $dir"
      docker-compose up -d
    else
      echo "在 $dir 中未找到 docker-compose.yml 文件"
    fi

    # 返回上级目录
    cd ..
  fi
done

echo "所有操作已完成"
