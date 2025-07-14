# MyTokenBank

一个简单的基于 Solidity 的智能合约项目，包含两个合约：

- `MyToken`：一个自定义的 ERC20 代币合约。
- `TokenBank`：一个代币存取合约，用户可以将自己的代币存入和提取。

## 📦 合约结构


## 🚀 部署流程（使用 Remix）

1. 打开 [Remix IDE](https://remix.ethereum.org)
2. 将 `MyToken.sol` 粘贴并编译，部署时传入初始发行量（如 `1000000`）
3. 将部署后的 `MyToken` 合约地址复制下来
4. 粘贴 `TokenBank.sol`，编译并部署时将刚才复制的地址作为构造函数参数
5. 在 `MyToken` 中调用 `approve(TokenBank地址, 数量)` 授权
6. 在 `TokenBank` 中调用 `deposit(数量)` 存入代币
7. 调用 `withdraw(数量)` 提取代币

## 🔐 安全说明

- `TokenBank` 使用 `mapping(address => uint256)` 来记录每个用户的存款数量。
- 所有转账操作都基于用户预先授权（ERC20 `approve` + `transferFrom`）机制。

## 🛠️ 环境建议

- Remix IDE
- Solidity ^0.8.0
- 支持测试网（如 Sepolia）或本地链（如 Hardhat）

## 📜 授权 License

本项目使用 MIT License 开源协议。  
你可以自由修改、发布、学习与使用。


