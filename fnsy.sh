#!/bin/bash

# 输出文件路径
output_file="/root/fn.txt"

# 菜单1功能：自定义循环遍历 hy 开头编号到 hy 结束编号目录并提取私钥
function extract_private_keys() {
    # 清空或创建输出文件
    > "$output_file"

    # 自定义起始和结束编号
    read -p "请输入起始编号 (如 1): " start
    read -p "请输入结束编号 (如 30): " end

    for i in $(seq "$start" "$end"); do
        dir="hy$i"
        file="$dir/docker-compose.yml"

        # 检查文件是否存在
        if [ -f "$file" ]; then
            # 提取 PRIVATE_KEY 的值并去掉单引号
            private_key=$(grep -Po "(?<=PRIVATE_KEY:\s)'.*'" "$file" | tr -d "'")
            
            # 如果提取到了 PRIVATE_KEY，则写入文件
            if [ -n "$private_key" ]; then
                echo "hy$i: $private_key" >> "$output_file"
            else
                echo "hy$i: PRIVATE_KEY not found" >> "$output_file"
            fi
        else
            echo "hy$i: docker-compose.yml not found" >> "$output_file"
        fi
    done

    echo "Done! Results saved to $output_file."
}

# 菜单2功能：去掉 fn.txt 文件中 hy 开头的行前缀
function remove_hy_prefix() {
    input_file="fn.txt"
    output_file="fn1.txt"

    # 检查输入文件是否存在
    if [ -f "$input_file" ]; then
        sed 's/^hy[1-9][0-9]*: //' "$input_file" > "$output_file"
        echo "处理完成，结果已保存到 $output_file"
    else
        echo "错误: 文件 $input_file 不存在"
    fi
}

# 菜单界面
function menu() {
    echo "请选择操作:"
    echo "1. 提取 hy 目录的 PRIVATE_KEY 并保存到文件"
    echo "2. 去掉 fn.txt 文件中 hy 开头的前缀"
    echo "3. 退出"
    read -p "请输入选项 (1-3): " choice

    case $choice in
        1)
            extract_private_keys
            ;;
        2)
            remove_hy_prefix
            ;;
        3)
            echo "退出程序"
            exit 0
            ;;
        *)
            echo "无效选项，请重新选择"
            menu
            ;;
    esac
}

# 执行菜单
menu
