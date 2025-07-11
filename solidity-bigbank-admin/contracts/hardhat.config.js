require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

module.exports = {
  solidity: "0.8.20", // Solidity 版本，根据你的合约代码调整

  networks: {
    // 本地测试链：Hardhat 自带的内存链
    hardhat: {},

    // 如果你使用 localhost（如通过 hardhat node 启动的链）
    localhost: {
      url: "http://127.0.0.1:8545",
    },

    // Sepolia 测试网（需要配置环境变量）
    sepolia: {
      url: process.env.SEPOLIA_RPC_URL || "",
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
      chainId: 11155111,
    }
  },

  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY || "",
  }
};
