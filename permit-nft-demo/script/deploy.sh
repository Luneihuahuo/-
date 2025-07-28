#!/bin/bash

# 检查是否存在.env文件
if [ ! -f ".env" ]; then
    echo "错误: .env文件不存在"
    echo "请先复制.env.example为.env并填入你的私钥和RPC URL"
    echo "cp .env.example .env"
    exit 1
fi

# 加载环境变量
source .env

# 检查PRIVATE_KEY是否设置
if [ -z "$PRIVATE_KEY" ]; then
    echo "错误: PRIVATE_KEY环境变量未设置"
    echo "请在.env文件中设置你的私钥"
    exit 1
fi

# 检查是否提供了RPC URL
if [ -z "$1" ] && [ -z "$ETH_RPC_URL" ]; then
    echo "错误: 未提供RPC URL"
    echo "请在.env文件中设置ETH_RPC_URL或作为参数提供"
    echo "用法: ./script/deploy.sh [RPC_URL]"
    exit 1
fi

# 使用参数提供的RPC URL或环境变量中的RPC URL
RPC_URL=${1:-$ETH_RPC_URL}

# 设置Foundry路径
FORGE_PATH="/home/luneohuahuo/.foundry/bin/forge"

# 运行部署脚本
echo "使用RPC URL: $RPC_URL"
echo "开始部署合约..."
$FORGE_PATH script script/Deploy.s.sol --rpc-url "$RPC_URL" --broadcast

echo "部署完成！"