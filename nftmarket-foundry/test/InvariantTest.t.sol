
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import "forge-std/Test.sol";
import "../src/NFTMarket.sol";
import "../src/MyNFT.sol";
import "../src/MyToken.sol";

contract NFTMarketInvariantTest is Test {
    NFTMarket public market;
    MyToken public token;

    function setUp() public {
        market = new NFTMarket();
        token = new MyToken();
    }

    function invariantMarketShouldNotHoldToken() public {
        uint256 balance = token.balanceOf(address(market));
        assertEq(balance, 0, "Market should not hold token");
    }
}
