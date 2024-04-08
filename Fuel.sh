#!/bin/bash

# 检查是否以root用户运行脚本
if [ "$(id -u)" != "0" ]; then
    echo "此脚本需要以root用户权限运行。"
    echo "请尝试使用 'sudo -i' 命令切换到root用户，然后再次运行此脚本。"
    exit 1
fi

# 脚本保存路径
SCRIPT_PATH="$HOME/Fuel.sh"

# 自动设置快捷键的功能
function check_and_set_alias() {
    local alias_name="fuel"
    local profile_file="$HOME/.profile"

    # 检查快捷键是否已经设置
    if ! grep -q "$alias_name" "$profile_file"; then
        echo "设置快捷键 '$alias_name' 到 $profile_file"
        echo "alias $alias_name='bash $SCRIPT_PATH'" >> "$profile_file"
        # 添加提醒用户激活快捷键的信息
        echo "快捷键 '$alias_name' 已设置。请运行 'source $profile_file' 来激活快捷键，或重新登录。"
    else
        # 如果快捷键已经设置，提供一个提示信息
        echo "快捷键 '$alias_name' 已经设置在 $profile_file。"
        echo "如果快捷键不起作用，请尝试运行 'source $profile_file' 或重新登录。"
    fi
}

function install_node() {

# 安装基本组件
sudo apt update
sudo apt install screen git -y

# 安装Rust
echo "正在安装Rust..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env

# 安装Fuel服务
echo "正在安装Fuel服务..."
curl https://install.fuel.network | sh
sleep 5
source /root/.bashrc


# 配置chainConfig文件
cat > chainConfig.json << EOF
{
  "chain_name": "Testnet Beta 5",
  "block_gas_limit": 30000000,
  "initial_state": {
    "coins": [
      {
        "owner": "0xa1184d77d0d08a064e03b2bd9f50863e88faddea4693a05ca1ee9b1732ea99b7",
        "amount": "0x1000000000000000",
        "asset_id": "0x0000000000000000000000000000000000000000000000000000000000000000"
      },
      {
        "owner": "0xb5566df884bee4e458151c2fe4082c8af38095cc442c61e0dc83a371d70d88fd",
        "amount": "0x1000000000000000",
        "asset_id": "0x0000000000000000000000000000000000000000000000000000000000000000"
      },
      {
        "owner": "0x9da7247e1d63d30d69f136f0f8654ee8340362c785b50f0a60513c7edbf5bb7c",
        "amount": "0x1000000000000000",
        "asset_id": "0x0000000000000000000000000000000000000000000000000000000000000000"
      },
      {
        "owner": "0x4b2ca966aad1a9d66994731db5138933cf61679107c3cde2a10d9594e47c084e",
        "amount": "0x1000000000000000",
        "asset_id": "0x0000000000000000000000000000000000000000000000000000000000000000"
      },
      {
        "owner": "0x26183fbe7375045250865947695dfc12500dcc43efb9102b4e8c4d3c20009dcb",
        "amount": "0x1000000000000000",
        "asset_id": "0x0000000000000000000000000000000000000000000000000000000000000000"
      },
      {
        "owner": "0x81f3a10b61828580d06cc4c7b0ed8f59b9fb618be856c55d33decd95489a1e23",
        "amount": "0x1000000000000000",
        "asset_id": "0x0000000000000000000000000000000000000000000000000000000000000000"
      },
      {
        "owner": "0x587aa0482482efea0234752d1ad9a9c438d1f34d2859b8bef2d56a432cb68e33",
        "amount": "0x1000000000000000",
        "asset_id": "0x0000000000000000000000000000000000000000000000000000000000000000"
      }
    ],
    "contracts": [
      {
        "contract_id": "0x7777777777777777777777777777777777777777777777777777777777777777",
        "code": "0x9000000994318e6e453f30e85bf6088f7161d44e57b86a6af0c955d22b353f91b2465f5e6140000a504d00205d4d30001a4860004945048076440001240400005050c0043d51345024040000",
        "salt": "0x1bfd51cb31b8d0bc7d93d38f97ab771267d8786ab87073e0c2b8f9ddc44b274e"
      }
    ]
  },
  "consensus_parameters": {
    "tx_params": {
      "max_inputs": 255,
      "max_outputs": 255,
      "max_witnesses": 255,
      "max_gas_per_tx": 30000000,
      "max_size": 17825792
    },
    "predicate_params": {
      "max_predicate_length": 1048576,
      "max_predicate_data_length": 1048576,
      "max_message_data_length": 1048576,
      "max_gas_per_predicate": 30000000
    },
    "script_params": {
      "max_script_length": 1048576,
      "max_script_data_length": 1048576
    },
    "contract_params": {
      "contract_max_size": 16777216,
      "max_storage_slots": 65536
    },
    "fee_params": {
      "gas_price_factor": 92,
      "gas_per_byte": 63
    },
    "chain_id": 0,
    "gas_costs": {
      "add": 2,
      "addi": 2,
      "aloc": 1,
      "and": 2,
      "andi": 2,
      "bal": 366,
      "bhei": 2,
      "bhsh": 2,
      "burn": 33949,
      "cb": 2,
      "cfei": 2,
      "cfsi": 2,
      "croo": 40,
      "div": 2,
      "divi": 2,
      "eck1": 3347,
      "ecr1": 46165,
      "ed19": 4210,
      "eq": 2,
      "exp": 2,
      "expi": 2,
      "flag": 1,
      "gm": 2,
      "gt": 2,
      "gtf": 16,
      "ji": 2,
      "jmp": 2,
      "jne": 2,
      "jnei": 2,
      "jnzi": 2,
      "jmpf": 2,
      "jmpb": 2,
      "jnzf": 2,
      "jnzb": 2,
      "jnef": 2,
      "jneb": 2,
      "lb": 2,
      "log": 754,
      "lt": 2,
      "lw": 2,
      "mint": 35718,
      "mlog": 2,
      "mod": 2,
      "modi": 2,
      "move": 2,
      "movi": 2,
      "mroo": 5,
      "mul": 2,
      "muli": 2,
      "mldv": 4,
      "noop": 1,
      "not": 2,
      "or": 2,
      "ori": 2,
      "poph": 3,
      "popl": 3,
      "pshh": 4,
      "pshl": 4,
      "ret_contract": 733,
      "rvrt_contract": 722,
      "sb": 2,
      "sll": 2,
      "slli": 2,
      "srl": 2,
      "srli": 2,
      "srw": 253,
      "sub": 2,
      "subi": 2,
      "sw": 2,
      "sww": 29053,
      "time": 79,
      "tr": 46242,
      "tro": 33251,
      "wdcm": 3,
      "wqcm": 3,
      "wdop": 3,
      "wqop": 3,
      "wdml": 3,
      "wqml": 4,
      "wddv": 5,
      "wqdv": 7,
      "wdmd": 11,
      "wqmd": 18,
      "wdam": 9,
      "wqam": 12,
      "wdmm": 11,
      "wqmm": 11,
      "xor": 2,
      "xori": 2,
      "call": {
        "LightOperation": {
          "base": 21687,
          "units_per_gas": 4
        }
      },
      "ccp": {
        "LightOperation": {
          "base": 59,
          "units_per_gas": 20
        }
      },
      "csiz": {
        "LightOperation": {
          "base": 59,
          "units_per_gas": 195
        }
      },
      "k256": {
        "LightOperation": {
          "base": 282,
          "units_per_gas": 3
        }
      },
      "ldc": {
        "LightOperation": {
          "base": 45,
          "units_per_gas": 65
        }
      },
      "logd": {
        "LightOperation": {
          "base": 1134,
          "units_per_gas": 2
        }
      },
      "mcl": {
        "LightOperation": {
          "base": 3,
          "units_per_gas": 523
        }
      },
      "mcli": {
        "LightOperation": {
          "base": 3,
          "units_per_gas": 526
        }
      },
      "mcp": {
        "LightOperation": {
          "base": 3,
          "units_per_gas": 448
        }
      },
      "mcpi": {
        "LightOperation": {
          "base": 7,
          "units_per_gas": 585
        }
      },
      "meq": {
        "LightOperation": {
          "base": 11,
          "units_per_gas": 1097
        }
      },
      "retd_contract": {
        "LightOperation": {
          "base": 1086,
          "units_per_gas": 2
        }
      },
      "s256": {
        "LightOperation": {
          "base": 45,
          "units_per_gas": 3
        }
      },
      "scwq": {
        "HeavyOperation": {
          "base": 30375,
          "gas_per_unit": 28628
        }
      },
      "smo": {
        "LightOperation": {
          "base": 64196,
          "units_per_gas": 1
        }
      },
      "srwq": {
        "HeavyOperation": {
          "base": 262,
          "gas_per_unit": 249
        }
      },
      "swwq": {
        "HeavyOperation": {
          "base": 28484,
          "gas_per_unit": 26613
        }
      },
      "contract_root": {
        "LightOperation": {
          "base": 45,
          "units_per_gas": 1
        }
      },
      "state_root": {
        "HeavyOperation": {
          "base": 350,
          "gas_per_unit": 176
        }
      },
      "new_storage_per_byte": 63,
      "vm_initialization": {
        "LightOperation": {
          "base": 1645,
          "units_per_gas": 14
        }
      }
    },
    "base_asset_id": "0000000000000000000000000000000000000000000000000000000000000000"
  },
  "consensus": {
    "PoA": {
      "signing_key": "f65d6448a273b531ee942c133bb91a6f904c7d7f3104cdaf6b9f7f50d3518871"
    }
  }
}
EOF

# 生成P2P密钥
source /root/.bashrc
export PATH=$HOME/.fuelup/bin:$PATH
echo "正在生成P2P密钥..."
KEY_OUTPUT=$(fuel-core-keygen new --key-type peering)
echo "${KEY_OUTPUT}"
read -p "请从上方输出中复制'secret'值，并在此粘贴: " SECRET

# 用户输入节点名称和RPC地址
read -p "请输入您想设置的节点名称: " NODE_NAME
read -p "请输入您的ETH Sepolia RPC地址: " RPC

# 开始配置并运行节点
echo "开始配置并启动您的fuel节点..."

screen -dmS Fuel bash -c "source /root/.bashrc; fuel-core run \
--service-name '${NODE_NAME}' \
--keypair '${SECRET}' \
--relayer '${RPC}' \
--ip 0.0.0.0 --port 4000 --peering-port 30333 \
--db-path ~/.fuel_beta5 \
--chain ./chainConfig.json \
--utxo-validation --poa-instant false --enable-p2p \
--min-gas-price 1 --max-block-size 18874368  --max-transmit-size 18874368 \
--reserved-nodes /dns4/p2p-beta-5.fuel.network/tcp/30333/p2p/16Uiu2HAmSMqLSibvGCvg8EFLrpnmrXw1GZ2ADX3U2c9ttQSvFtZX,/dns4/p2p-beta-5.fuel.network/tcp/30334/p2p/16Uiu2HAmVUHZ3Yimoh4fBbFqAb3AC4QR1cyo8bUF4qyi8eiUjpVP \
--sync-header-batch-size 100 \
--enable-relayer \
--relayer-v2-listening-contracts 0x557c5cE22F877d975C2cB13D0a961a182d740fD5 \
--relayer-da-deploy-height 4867877 \
--relayer-log-page-size 2000
"

echo "节点配置完成并尝试启动。请使用screen -r Fuel 以确认节点状态。"

}

function check_service_status() {
    screen -r Fuel

}


# 主菜单
function main_menu() {
    clear
    echo "风男提示你脚本免费开源，请勿相信任何其他人收费，微信4561310"
    echo "================================================================"
    echo "请选择要执行的操作:"
    echo "1. 安装常规节点"
    echo "2. 查看节点日志"
    echo "3. 设置快捷键"
    
    read -p "请输入选项（1-3）: " OPTION

    case $OPTION in
    1) install_node ;;
    2) check_service_status ;;  
    3)check_and_set_alias ;;
    *) echo "无效选项。" ;;
    esac
}

# 显示主菜单
main_menu
