#!/bin/bash

# 脚本保存路径
SCRIPT_PATH="$HOME/nimble.sh"

# 节点安装功能
function install_node() {
    apt update
    apt install -y git python3-venv bison screen binutils gcc make bsdmainutils python3-pip

	# 安装numpy
    pip install numpy==1.24.4

    # 安装GO
    rm -rf /usr/local/go
    wget https://go.dev/dl/go1.22.1.linux-amd64.tar.gz -P /tmp/
    tar -C /usr/local -xzf /tmp/go1.22.1.linux-amd64.tar.gz
    echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bashrc
    export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
    go version

    # 克隆仓库
    mkdir -p $HOME/nimble && cd $HOME/nimble
    git clone https://github.com/nimble-technology/wallet-public.git
    cd wallet-public
    make install

    # 创建钱包
    echo "至少创建两个钱包，一个作为主钱包，一个作为挖矿钱包。"
    read -p "请输入钱包数量:" wallet_count
    for i in $(seq 1 $wallet_count); do
        wallet_name="wallet$i"
        nimble-networkd keys add $wallet_name
        echo "钱包 $wallet_name 创建成功"
    done
	echo "完成部署"
}

# 开始挖矿
function start_mining(){
	
    # 启动挖矿
    read -p "挖矿钱包地址:" wallet_addr
    export wallet_addr
    cd $HOME/nimble
    git clone https://github.com/nimble-technology/nimble-miner-public.git
    cd nimble-miner-public
    make install
    source ./nimenv_localminers/bin/activate
    screen -dmS nimble bash -c "make run addr=$wallet_addr"
    
}

# 查看日志
function view_logs(){
	clear
	echo "即将进入screen，查看完请ctrl + a + d 退出"
	sleep 5
	screen -r nimble
}

# 主菜单
function main_menu() {
    clear
    echo "===================Nimble一键部署脚本==================="
	echo "BreadDog出品，电报：https://t.me/breaddog"
	echo "最低配置：8C16G256G+RTX2080，推荐配置：16C32G256G+RTX3090"
    echo "请选择要执行的操作:"
    echo "1. 部署节点"
    echo "2. 开始挖矿"
    echo "3. 查看日志"
    echo "0. 退出脚本exit"
    read -p "请输入选项: " OPTION

    case $OPTION in
    1) install_node ;;
    2) start_mining ;;
    3) view_logs ;;
    *) echo "无效选项，请重新输入。"; sleep 3 ;;
    esac
}

main_menu