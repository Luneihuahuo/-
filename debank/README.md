

# Bank 智能合约

## 简介

这是一个使用 Solidity 编写的以太坊智能合约，模拟了一个简单的银行系统，支持用户存款、记录余额，并动态维护当前存款排名前 3 的用户列表。合约还允许管理员（部署者）提取合约中的所有资金。

---

## 功能特性

* 💰 **存款功能**：用户可以通过直接转账或调用 `deposit()` 存入 ETH。
* 👑 **排行榜机制**：自动维护余额前 3 的用户地址及其金额。
* 🔐 **管理员提现**：仅合约拥有者可以提取所有资金。
* 📊 **排行榜查询**：提供 `getTopUsers()` 接口，供外部查看前 3 名用户及其余额。

---

## 部署版本

* **Solidity 版本要求**：`^0.8.0`
* **许可证**：MIT

---

## 合约接口说明

### `constructor()`

初始化合约，设置 `owner` 为部署者地址。

---

### `receive() external payable`

允许用户通过直接向合约地址转账 ETH 自动调用 `deposit()`。

---

### `deposit() public payable`

主动存款函数：

* 要求转账金额大于 0；
* 将余额记录至 `balances[msg.sender]`；
* 调用 `_updateTopUsers()` 检查并更新排行榜。

---

### `withdraw() external onlyOwner`

管理员提取合约中所有资金。仅限合约拥有者调用。

---

### `getTopUsers() external view returns (address[3], uint256[3])`

查询当前存款金额最多的前 3 位用户和对应金额。

---

## 内部函数说明

### `_updateTopUsers(address user)`

更新排行榜逻辑：

1. 若用户已在前 3 中，更新其余额并排序；
2. 若用户未入榜但余额足够进入前 3，则插入并更新。

---

### `_sortTopUsers()`

对排行榜进行冒泡排序，按余额从高到低排列。

---

## 示例场景

1. 用户 Alice 向合约发送 5 ETH；
2. 用户 Bob 发送 3 ETH；
3. 用户 Charlie 发送 7 ETH；
4. 系统自动更新排行榜为 Charlie > Alice > Bob；
5. 用户 David 发送 8 ETH，则榜单更新为 David > Charlie > Alice。

---

## 安全注意事项

* 所有存款必须为正值；
* `withdraw()` 只能由 `owner` 调用；
* 所有资金安全由以太坊本身保障，但请确保部署环境安全、部署者私钥妥善保管。

---

## 编译与部署（使用 Remix）

1. 打开 [Remix IDE](https://remix.ethereum.org)
2. 新建 `.sol` 文件并粘贴上述代码；
3. 在编译器面板选择 `Solidity ^0.8.0` 版本；
4. 点击 “Deploy” 按钮部署；
5. 使用 Injected Provider（如 MetaMask）进行操作与测试。

---

## 许可证

MIT License


