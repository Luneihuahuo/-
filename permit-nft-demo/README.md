# TokenBank Foundry 版本

这是将原Hardhat项目转换为Foundry格式的版本，实现了ERC20 Permit功能的代币银行。

## 快速开始

我们提供了一个一键设置脚本，可以自动完成安装、编译和测试：

```bash
cd foundry-version
chmod +x script/setup_and_run.sh
./script/setup_and_run.sh
```

这个脚本会：
1. 检查Foundry是否已安装，如果没有则安装
2. 初始化git仓库（如果尚未初始化）
3. 安装项目依赖
4. 编译合约
5. 运行测试

完成后，你只需要设置环境变量并运行部署脚本即可部署合约。

## 项目结构

```
├── foundry.toml        # Foundry配置文件
├── .env.example        # 环境变量示例文件
├── lib/                # 依赖库
├── script/             # 脚本文件
│   ├── Deploy.s.sol    # 部署合约的脚本
│   ├── build.sh        # 编译脚本
│   ├── test.sh         # 测试脚本
│   ├── deploy.sh       # 部署辅助脚本
│   ├── install_deps.sh # 安装依赖的脚本
│   ├── install_foundry.sh # Foundry安装脚本
│   └── setup_and_run.sh # 一键设置脚本
├── src/                # 合约源码
│   ├── MyToken.sol     # ERC20 Permit代币合约
│   └── TokenBank.sol   # 代币银行合约
└── test/               # 测试文件
    └── TokenBank.t.sol # 代币银行测试
```

## 安装Foundry

首先，需要安装Foundry工具链。我们提供了一个使用官方方法安装Foundry的脚本：

```bash
cd foundry-version
chmod +x script/install_foundry.sh
./script/install_foundry.sh
```

安装脚本运行后，请按照提示执行以下命令：

```bash
# 加载环境变量
source ~/.bashrc

# 安装Foundry组件
foundryup
```

安装完成后，请使用以下命令验证安装是否成功：

```bash
/home/luneohuahuo/.foundry/bin/forge --version
```

**注意**：系统中可能存在多个名为`forge`的命令。如果运行`forge --version`时出现错误或显示非Foundry的信息，请使用完整路径`/home/luneohuahuo/.foundry/bin/forge`来运行Foundry的forge命令。

如果安装脚本不起作用，你也可以参考[Foundry官方文档](https://book.getfoundry.sh/getting-started/installation)手动安装，或者直接在终端中执行以下命令：

```bash
curl -L https://foundry.paradigm.xyz | bash
source ~/.bashrc
foundryup
```

## 安装依赖

在安装Foundry后，你需要初始化git仓库并安装项目依赖：

```bash
cd foundry-version

# 初始化git仓库（必须步骤，forge install需要在git仓库中运行）
git init

# 安装依赖
chmod +x script/install_deps.sh
./script/install_deps.sh
```

## 编译合约

我们提供了一个编译脚本来简化编译过程：

```bash
# 确保脚本可执行
chmod +x script/build.sh

# 编译所有合约
./script/build.sh

# 使用额外参数（例如详细输出）
./script/build.sh --verbose
```

如果你想手动运行编译命令：

```bash
forge build
```

## 运行测试

我们提供了一个测试脚本来简化测试过程：

```bash
# 确保脚本可执行
chmod +x script/test.sh

# 运行所有测试
./script/test.sh

# 运行特定测试（例如只运行testDeposit函数）
./script/test.sh testDeposit
```

如果你想手动运行测试命令：

```bash
forge test -vv
```

## 部署合约

部署脚本使用环境变量来获取私钥。首先，创建一个`.env`文件：

```bash
# 复制示例环境变量文件
cp .env.example .env

# 编辑.env文件，填入你的私钥和RPC URL
nano .env  # 或使用其他编辑器
```

然后使用我们提供的部署脚本：

```bash
# 确保脚本可执行
chmod +x script/deploy.sh

# 本地部署（使用本地节点）
./script/deploy.sh http://localhost:8545

# 测试网部署（使用.env中的ETH_RPC_URL）
./script/deploy.sh
```

如果你想手动运行部署命令：

```bash
# 加载环境变量
source .env

# 使用完整路径运行forge命令
/home/luneohuahuo/.foundry/bin/forge script script/Deploy.s.sol --rpc-url http://localhost:8545 --broadcast
```

**注意**：
- 环境变量`PRIVATE_KEY`必须设置为你的部署私钥（不带`0x`前缀）
- 如果遇到forge命令问题，请使用完整路径：`/home/luneohuahuo/.foundry/bin/forge`
- 请确保`.env`文件已添加到`.gitignore`中，不要将私钥提交到版本控制系统中
- 你也可以直接在命令行中指定私钥：`--private-key YOUR_PRIVATE_KEY`，但这种方式不安全，不推荐使用

## 功能说明

### MyToken

- 实现了ERC20 Permit标准的代币
- 允许用户通过签名授权转账，无需事先调用approve

### TokenBank

- `deposit`: 普通存款方法，需要先approve
- `permitDeposit`: 使用permit签名进行存款，无需事先approve

## 与Hardhat版本的区别

1. 测试框架从JavaScript转换为Solidity
2. 使用Foundry的forge-std库进行测试和部署
3. 使用Foundry的cheatcodes进行测试，如vm.prank和vm.sign