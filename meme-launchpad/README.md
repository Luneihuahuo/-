# Meme Launchpad

一个基于EVM链的Meme代币发射平台，使用最小代理模式降低Gas成本。

## 项目概述

本项目实现了一个Meme代币发射平台，允许用户以低成本创建和发行ERC20代币。主要特性包括：

- **最小代理模式**: 使用OpenZeppelin的Clones库，大幅降低部署成本
- **费用分配**: 每次铸造收取1%平台费用，99%归代币创建者
- **供应量控制**: 支持分批铸造，防止一次性铸造完所有代币
- **安全保障**: 包含重入攻击保护和完整的输入验证

## 合约架构

### MemeToken.sol
- ERC20代币模板合约
- 支持初始化模式，配合最小代理使用
- 包含供应量限制和铸造控制

### MemeFactory.sol
- 工厂合约，负责部署和管理Meme代币
- 实现费用收取和分配逻辑
- 提供代币铸造接口

## 主要功能

### 1. 部署Meme代币
```solidity
function deployMeme(
    string memory symbol,
    uint256 totalSupply,
    uint256 perMint,
    uint256 price
) external returns (address)
```

参数说明：
- `symbol`: 代币符号
- `totalSupply`: 总发行量
- `perMint`: 每次铸造数量
- `price`: 每个代币价格（wei计价）

### 2. 铸造Meme代币
```solidity
function mintMeme(address tokenAddr) external payable
```

- 用户支付相应费用即可铸造指定数量的代币
- 自动分配费用：1%给平台，99%给代币创建者
- 支持超额支付自动退款

## 费用机制

每次铸造时的费用分配：
- **平台费用**: 1% 归平台所有者
- **创建者费用**: 99% 归代币创建者
- **自动退款**: 超额支付部分自动退还给用户

## 安全特性

- **重入攻击保护**: 使用OpenZeppelin的ReentrancyGuard
- **权限控制**: 基于Ownable的权限管理
- **输入验证**: 完整的参数验证和边界检查
- **供应量控制**: 严格的代币供应量限制

## 测试用例

项目包含全面的测试用例，覆盖以下场景：

1. **基本功能测试**
   - 代币部署
   - 代币铸造
   - 多次铸造

2. **费用分配测试**
   - 1%平台费用验证
   - 99%创建者费用验证
   - 费用提取功能

3. **边界条件测试**
   - 供应量限制
   - 无效参数处理
   - 支付金额验证
   - 超额支付退款

4. **统计功能测试**
   - 工厂统计信息
   - 部署代币计数

## 快速开始

### 环境要求
- Foundry
- Solidity ^0.8.19

### 安装依赖
```bash
# 安装Foundry (如果未安装)
curl -L https://foundry.paradigm.xyz | bash
foundryup

# 安装OpenZeppelin合约
forge install OpenZeppelin/openzeppelin-contracts
```

### 编译合约
```bash
forge build
```

### 运行测试
```bash
# 运行所有测试
forge test

# 运行测试并显示详细日志
forge test -vvv

# 运行特定测试
forge test --match-test testDeployMeme -vvv
```

### 部署合约
```bash
# 设置环境变量
export PRIVATE_KEY=your_private_key
export RPC_URL=your_rpc_url

# 部署到测试网
forge script script/Deploy.s.sol:DeployScript --rpc-url $RPC_URL --broadcast
```

## 使用示例

### 1. 部署新的Meme代币
```solidity
// 部署一个名为"DOGE"的代币
// 总供应量: 1,000,000 tokens
// 每次铸造: 1,000 tokens  
// 价格: 0.001 ETH per token
address tokenAddr = factory.deployMeme(
    "DOGE",
    1000000 * 1e18,
    1000 * 1e18,
    0.001 ether
);
```

### 2. 铸造代币
```solidity
// 计算所需费用
uint256 totalCost = price * perMint;

// 铸造代币
factory.mintMeme{value: totalCost}(tokenAddr);
```

## Gas优化

通过使用最小代理模式，每次部署新代币的Gas成本大幅降低：
- **传统部署**: ~2,000,000 gas
- **最小代理**: ~200,000 gas
- **节省**: ~90% Gas成本

## 许可证

MIT License
