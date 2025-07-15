# NFTMarketDemo

- 使用扩展 ERC20 Token (`MyToken.sol`) 进行 NFT 买卖
- 市场合约 (`NFTMarket.sol`) 支持 list()、buyNFT() 和 tokensReceived()

## 功能测试建议

1. 部署 `MyToken`，初始分配一些 token 给买家
2. 部署 `MyNFT`，mint 一个 NFT
3. 部署 `NFTMarket(tokenAddress)`
4. 执行 NFT 授权和上架
5. 使用 `buyNFT()` 或 `transferWithCallback()` 完成购买
