# ERC20 with Hook + TokenBankV2

这是一个示例项目，展示了如何扩展一个 ERC20 Token，使其支持合约回调（Hook）功能，并创建一个支持自动接收该 Token 的 TokenBankV2。

## 功能说明

### ✅ MyERC20WithHook
- 标准 ERC20 功能（transfer, approve, transferFrom）
- 新增 `transferWithCallback`，转账至合约地址时自动调用 `tokensReceived` 回调函数

### ✅ TokenBankV2
- 实现 `tokensReceived(address from, uint256 amount)`
- 自动记录用户存入的代币数量

## 使用说明

1. 部署 `MyERC20WithHook`，传入初始发行量
2. 部署 `TokenBankV2`
3. 用户调用 `transferWithCallback(TokenBankV2_address, amount)` 将代币存入银行
4. 可通过 `getDeposit(address)` 查看存款余额

## 示例

```solidity
token.transferWithCallback(bank.address, 1000 * 1e18);
