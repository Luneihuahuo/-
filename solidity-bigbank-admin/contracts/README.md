# 💸 Solidity BigBank & Admin 合约系统

本项目基于 Solidity 编写，实现了一个具有权限控制和存取款功能的银行系统。通过合约间的协作，实现了 `BigBank` 的管理员权限转移，并允许 `Admin` 合约集中管理资金。

---

## 📁 合约结构说明

| 合约名称 | 功能描述 |
|----------|-----------|
| `IBank.sol` | 银行接口，定义标准的 `deposit()` 和 `withdraw()` 方法 |
| `Bank.sol` | 实现了 `IBank`，提供基础存取款功能 |
| `BigBank.sol` | 继承自 `Bank`，增加最低存款限制（0.001 ETH）与 `admin` 管理权限控制 |
| `Admin.sol` | 拥有 `owner` 地址，具备从实现 `IBank` 接口的合约中提取资金的能力 |

---

## 🔐 合约功能说明

### 🏦 BigBank 合约

- ✅ 用户可存款（需大于 0.001 ETH）
- ✅ 用户可调用 `withdraw()` 取款
- ✅ 管理员（`admin`）可通过 `changeAdmin(address)` 更改管理权限

### 🛡️ Admin 合约

- ✅ 只有 `owner` 地址可以调用 `adminWithdraw(IBank bank)` 从其他合约中提取资金
- ✅ 接收提取的 ETH 并集中管理

---

## 🚀 部署与使用指南（基于 Hardhat）

### 📦 安装依赖

```bash
npm install
