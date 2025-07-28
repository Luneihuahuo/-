// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/MyToken.sol";
import "../src/TokenBank.sol";
import "../src/MyNFT.sol";
import "../src/NFTMarket.sol";

contract DeployScript is Script {
    function run() external {
        // 获取部署者私钥
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        // 开始广播交易
        vm.startBroadcast(deployerPrivateKey);
        
        // 部署MyToken合约，初始供应量为1,000,000个token
        MyToken token = new MyToken(1_000_000 * 10**18);
        
        // 部署TokenBank合约
        TokenBank bank = new TokenBank(address(token));
        
        // 部署MyNFT合约
        MyNFT nft = new MyNFT();
        
        // 部署NFTMarket合约
        NFTMarket market = new NFTMarket(address(nft), address(token));
        
        // 铸造一些示例NFT
        nft.mint(msg.sender, "https://example.com/nft/1");
        nft.mint(msg.sender, "https://example.com/nft/2");
        nft.mint(msg.sender, "https://example.com/nft/3");
        
        // 结束广播
        vm.stopBroadcast();
        
        // 输出部署信息
        console.log("MyToken deployed at:", address(token));
        console.log("TokenBank deployed at:", address(bank));
        console.log("MyNFT deployed at:", address(nft));
        console.log("NFTMarket deployed at:", address(market));
        console.log("Minted 3 NFTs to deployer");
    }
}