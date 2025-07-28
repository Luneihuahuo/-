# EIP2612 Permit DeFi项目

## 项目概述

本项目基于EIP2612标准实现了一个完整的DeFi生态系统，包括：

1. **MyToken** - 支持EIP2612 Permit功能的ERC20代币
2. **TokenBank** - 支持离线签名授权存款的代币银行
3. **MyNFT** - LuneoNFT (LNFT) ERC721 NFT合约
4. **NFTMarket** - 支持Token支付和白名单permit购买的NFT市场

## 核心功能

### 1. EIP2612 Permit Token
- 基于OpenZeppelin的ERC20Permit实现
- 支持离线签名授权，无需预先approve
- 节省gas费用，提升用户体验

### 2. TokenBank 存款功能
- **普通存款**: `deposit(uint256 amount)`
- **Permit存款**: `permitDeposit(uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s)`
- 支持离线签名授权，一步完成授权和存款

### 3. NFT市场功能
- **NFT上架**: `listNFT(uint256 tokenId, uint256 price)`
- **普通购买**: `buyNFT(uint256 tokenId)`
- **白名单Permit购买**: `permitBuy(...)`
- 项目方签名白名单，只有授权用户可以购买
- 支持Token支付和离线签名授权

## 白名单机制

### 白名单签名生成
1. 项目方使用私钥对 `keccak256(abi.encodePacked(buyer, tokenId, nonce))` 进行签名
2. 生成的签名用于验证买家的白名单资格

### 白名单验证流程
1. 用户调用 `permitBuy()` 函数
2. 合约验证白名单签名的有效性
3. 验证Token的permit签名
4. 执行Token转账和NFT转移

## 测试用例

### TokenBank测试
- ✅ `testDeposit()` - 普通存款测试
- ✅ `testPermitDeposit()` - Permit存款测试

### NFTMarket测试
- ✅ `testTokenBankPermitDeposit()` - Token银行Permit存款
- ✅ `testNFTMarketPermitBuy()` - NFT市场Permit购买
- ✅ `testCompleteWorkflow()` - 完整工作流程测试
- ✅ `testRevertWhenPermitBuyWithoutWhitelist()` - 无效白名单测试

## 测试结果

```
Ran 2 test suites in 8.60ms (4.38ms CPU time): 6 tests passed, 0 failed, 0 skipped (6 total tests)
```

### 测试日志示例

**Token Bank Permit Deposit Test:**
- 成功使用离线签名进行Token存款
- 验证余额变化和授权流程

**NFT Market Permit Buy Test:**
- NFT所有权从seller转移到buyer
- Token支付成功完成
- 白名单验证通过

**Complete Workflow Test:**
- 完整演示从Token存款到NFT购买的全流程
- 展示离线签名授权的完整应用场景

## 技术特点

1. **Gas优化**: 使用EIP2612减少交易步骤
2. **安全性**: 多重签名验证，防止重放攻击
3. **用户体验**: 离线签名，减少用户交互
4. **可扩展性**: 模块化设计，易于扩展

## 部署说明

1. 部署MyToken合约
2. 部署TokenBank合约（传入Token地址）
3. 部署MyNFT合约
4. 部署NFTMarket合约（传入NFT和Token地址）
5. 铸造NFT并上架到市场

## 使用流程

### Token存款流程
1. 用户生成permit签名
2. 调用 `permitDeposit()` 一步完成授权和存款

### NFT购买流程
1. 项目方为买家生成白名单签名
2. 买家生成Token permit签名
3. 调用 `permitBuy()` 完成购买

## 安全考虑

- 使用nonce防止签名重放
- 白名单签名一次性使用
- 严格的权限控制
- 完整的事件日志记录

本项目展示了EIP2612标准在实际DeFi应用中的强大功能，为用户提供了更好的交互体验和更低的gas成本。