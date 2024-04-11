#!/bin/bash

# 检查是否以root用户运行脚本
if [ "$(id -u)" != "0" ]; then
    echo "此脚本需要以root用户权限运行。"
    echo "请尝试使用 'sudo -i' 命令切换到root用户，然后再次运行此脚本。"
    exit 1
fi

# 节点安装功能
function install_node() {

apt update
apt install screen -y

# 下载AIOZ dCDN CLI节点的压缩包
echo "正在下载AIOZ dCDN CLI节点..."
curl -LO https://github.com/AIOZNetwork/aioz-dcdn-cli-node/files/13561211/aioznode-linux-amd64-1.1.0.tar.gz

# 解压缩下载的文件
echo "正在解压文件..."
tar xzf aioznode-linux-amd64-1.1.0.tar.gz

# 将解压后的目录移动到新的位置
mv aioznode-linux-amd64-1.1.0 aioznode

# 通过检查其版本来验证节点是否可运行
echo "正在验证AIOZ dCDN CLI节点版本..."
./aioznode version

# 生成新的助记词和私钥，并将私钥保存到文件中
echo "正在生成新的助记词和私钥..."
./aioznode keytool new --save-priv-key privkey.json

echo "=============================备份好钱包和助记词，下方需要使用==================================="


# 确认备份
read -p "是否已经备份好钱包和助记词? (y/n) " backup_confirmed
if [ "$backup_confirmed" != "y" ]; then
        echo "请先备份好助记词,然后再继续执行脚本"
        exit 1
fi

# 使用指定的家目录和私钥文件运行节点
echo "正在启动AIOZ dCDN CLI节点..."
screen -dmS aioznode ./aioznode start --home nodedata --priv-key-file privkey.json


# 提醒用户关于自动更新和权限设置的注意事项
echo "后续使用screen -r aioznode查看运行情况。"

}


function check_status() {
./aioznode stats

}

function reward_balance() {
    ./aioznode reward balance
}

function withdraw_balance() {
read -p "请输入钱包地址: " wallet_address
read -p "请输入提取数量: " math
./aioznode reward withdraw --address $wallet_address --amount ${math}aioz --priv-key-file privkey.json

}
# 主菜单
function main_menu() {
    while true; do
        clear
        echo "风男提示你脚本免费开源，请勿相信任何其他人收费，微信4561310"
        echo "================================================================"
        echo "退出脚本，请按键盘ctrl c退出即可"
        echo "请选择要执行的操作:"
        echo "1. 安装节点"
        echo "2. 查看节点状态"
        echo "3. 查看收益"
        echo "4. 领取收益"
        read -p "请输入选项（1-4）: " OPTION

        case $OPTION in
        1) install_node ;;
        2) check_status ;;
        3) reward_balance ;;
        4) withdraw_balance ;;
        *) echo "无效选项。" ;;
        esac
        echo "按任意键返回主菜单..."
        read -n 1
    done
    
}

# 显示主菜单
main_menu
