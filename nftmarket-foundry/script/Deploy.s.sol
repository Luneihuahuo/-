// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import "../src/NFTMarket.sol";
import "../src/MyNFT.sol";
import "../src/MyToken.sol";

contract DeployScript {
NFTMarket public market;
    MyNFT public nft;
    MyToken public token;
    market = new NFTMarket();
        nft = new MyNFT();
        token = new MyToken();
         }
}
