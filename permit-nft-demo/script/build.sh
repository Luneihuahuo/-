#!/bin/bash

# 设置Foundry路径
FORGE_PATH="/home/luneohuahuo/.foundry/bin/forge"

# 运行编译命令
echo "编译合约..."
$FORGE_PATH build $@

if [ $? -eq 0 ]; then
    echo "编译成功！"
else
    echo "编译失败！"
    exit 1
fi