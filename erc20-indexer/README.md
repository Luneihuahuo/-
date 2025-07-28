# 🔗 ERC20 转账索引器

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Node.js Version](https://img.shields.io/badge/node-%3E%3D16.0.0-brightgreen)](https://nodejs.org/)
[![Hardhat](https://img.shields.io/badge/Hardhat-2.22.1-orange)](https://hardhat.org/)

一个完整的ERC20代币转账记录索引和查询系统，包含智能合约部署、后端索引服务和前端展示界面。

## 🌟 项目特色

- 🔗 **实时索引**: 自动监听和索引ERC20转账事件
- 💾 **数据持久化**: 使用SQLite数据库存储转账记录
- 🌐 **RESTful API**: 提供完整的转账记录查询接口
- 🎨 **现代化UI**: 响应式设计，支持桌面和移动设备
- ⚡ **实时更新**: 前端界面实时显示最新转账记录
- 🛡️ **类型安全**: 完整的错误处理和数据验证

## 功能特性

- 🔗 **智能合约部署**: 部署ERC20代币合约并执行测试转账
- 📊 **转账索引**: 实时监听和索引ERC20转账事件
- 💾 **数据存储**: 使用SQLite数据库存储转账记录
- 🌐 **RESTful API**: 提供查询转账记录的API接口
- 🎨 **前端界面**: 美观的Web界面展示转账记录
- 🔍 **地址查询**: 支持按地址查询特定用户的转账记录

## 项目结构

```
erc20-indexer/
├── contracts/          # 智能合约
│   └── MyToken.sol    # ERC20代币合约
├── scripts/           # 部署脚本
│   └── deploy.js      # 合约部署和测试数据生成
├── backend/           # 后端服务
│   ├── server.js      # Express服务器
│   ├── indexer.js     # 区块链事件索引器
│   └── database.js    # 数据库操作
├── frontend/          # 前端界面
│   └── index.html     # Web界面
├── hardhat.config.js  # Hardhat配置
├── package.json       # 项目依赖
└── README.md         # 项目说明
```

## 📸 功能展示

- 🔍 **智能查询**：输入钱包地址查看个人转账记录
- 📊 **数据展示**：清晰展示发送和接收的转账记录
- 🌐 **全局视图**：查看系统中所有转账活动
- ⚡ **实时更新**：自动监听新的转账事件

## 🚀 快速开始

### 环境要求

- Node.js >= 16.0.0
- npm >= 7.0.0
- Git

### 1. 克隆项目

```bash
git clone https://github.com/your-username/erc20-indexer.git
cd erc20-indexer
```

### 2. 安装依赖

```bash
npm install
```

### 3. 配置环境变量

```bash
cp .env.example .env
```

### 4. 启动本地区块链网络

```bash
npm run node
```

保持此终端运行，它会启动一个本地的Hardhat网络。

### 5. 部署合约并生成测试数据

在新的终端中运行：

```bash
npm run deploy
```

这将会：
- 部署MyToken (MTK) ERC20合约
- 创建5笔测试转账记录
- 自动更新.env配置文件
- 显示测试地址和余额信息

### 6. 启动后端服务

```bash
npm start
```

后端服务将：
- 启动Express服务器 (http://localhost:3001)
- 初始化SQLite数据库
- 索引历史转账记录
- 开始监听新的转账事件

### 7. 访问应用

打开浏览器访问: **http://localhost:3001**

🎉 现在您可以开始使用ERC20转账索引器了！

## API 接口

### 获取指定地址的转账记录

```
GET /api/transfers/:address
```

**响应示例:**
```json
{
  "success": true,
  "address": "0x...",
  "transfers": [
    {
      "id": 1,
      "transactionHash": "0x...",
      "blockNumber": 123,
      "from": "0x...",
      "to": "0x...",
      "value": "10000000000000000000",
      "tokenAddress": "0x...",
      "timestamp": 1234567890,
      "type": "sent"
    }
  ],
  "count": 1
}
```

### 获取所有转账记录

```
GET /api/transfers
```

### 健康检查

```
GET /api/health
```

## 测试数据

部署脚本会自动创建以下测试转账：

1. **部署者 → 地址1**: 10 MTK
2. **部署者 → 地址2**: 20 MTK  
3. **部署者 → 地址3**: 15 MTK
4. **地址1 → 地址2**: 5 MTK
5. **地址2 → 地址3**: 8 MTK

## 使用说明

### 前端界面使用

1. **用户登录**: 输入钱包地址进行"登录"
2. **查看个人记录**: 登录后自动显示该地址的转账记录
3. **查看所有记录**: 点击"查看所有转账"按钮
4. **记录详情**: 每条记录显示发送方、接收方、金额、交易哈希和时间

### 转账记录类型

- **发送**: 用户作为发送方的转账
- **接收**: 用户作为接收方的转账

## 技术栈

- **智能合约**: Solidity, OpenZeppelin
- **开发框架**: Hardhat
- **后端**: Node.js, Express.js
- **数据库**: SQLite3
- **区块链交互**: Ethers.js
- **前端**: HTML5, CSS3, JavaScript (原生)

## 开发命令

```bash
# 启动本地区块链
npm run node

# 部署合约
npm run deploy

# 启动后端服务
npm start

# 开发模式 (自动重启)
npm run dev
```

## 注意事项

1. 确保本地区块链网络正在运行
2. 部署合约后会自动生成.env文件
3. 后端服务会自动索引历史转账记录
4. 前端界面支持响应式设计，适配移动设备
5. 所有转账金额以MTK代币单位显示

## 故障排除

### 常见问题

1. **"索引器未初始化"**: 确保已运行部署脚本并生成了.env文件
2. **"网络请求失败"**: 检查后端服务是否正常运行
3. **"无法连接到服务器"**: 确保端口3001未被占用

### 重新开始

如需重新开始，请：
1. 停止所有服务
2. 删除.env文件和backend/transfers.db文件
3. 重新运行部署脚本
4. 重新启动后端服务

## 🤝 贡献

欢迎提交 Issues 和 Pull Requests！

## 🙏 致谢

基于 Hardhat、Express.js、SQLite 等优秀开源项目构建。

## 📄 许可证

本项目基于 MIT 许可证开源 - 查看 [LICENSE](LICENSE) 文件了解详情。

---

**注意**: 这是一个演示项目，使用本地测试网络。所有地址和私钥都是公开的测试数据，请勿在主网使用。