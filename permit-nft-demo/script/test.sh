#!/bin/bash

# 设置Foundry路径
FORGE_PATH="/home/luneohuahuo/.foundry/bin/forge"

# 检查是否提供了测试文件路径
if [ -z "$1" ]; then
    # 运行所有测试
    echo "运行所有测试..."
    $FORGE_PATH test -vv
else
    # 运行指定的测试文件或测试函数
    echo "运行指定测试: $1"
    $FORGE_PATH test -vv --match "$1"
fi