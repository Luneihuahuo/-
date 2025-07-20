
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import "forge-std/Test.sol";
import "../src/NFTMarket.sol";
import "../src/MyNFT.sol";
import "../src/MyToken.sol";

contract NFTMarketTest is Test {
    NFTMarket public market;
    MyNFT public nft;
    MyToken public token;
    address user = address(0x1);
    address buyer = address(0x2);

    function setUp() public {
        market = new NFTMarket();
        nft = new MyNFT();
        token = new MyToken();
        nft.transferOwnership(user);
        vm.startPrank(user);
        nft.mint(user, "ipfs://example");
        vm.stopPrank();
        token.transfer(buyer, 1e20);
    }

    function testListAndBuy() public {
        vm.startPrank(user);
        nft.approve(address(market), 0);
        market.list(address(nft), 0, address(token), 1e18);
        vm.stopPrank();

        vm.startPrank(buyer);
        token.approve(address(market), 1e18);
        market.buy(address(nft), 0);
        vm.stopPrank();

        assertEq(nft.ownerOf(0), buyer);
    }

    function testCannotBuyOwnNFT() public {
        vm.startPrank(user);
        nft.approve(address(market), 0);
        market.list(address(nft), 0, address(token), 1e18);
        token.approve(address(market), 1e18);
        vm.expectRevert("Cannot buy your own NFT");
        market.buy(address(nft), 0);
        vm.stopPrank();
    }

    function testCannotBuyUnlistedNFT() public {
        vm.startPrank(buyer);
        vm.expectRevert("Not listed");
        market.buy(address(nft), 99);
        vm.stopPrank();
    }
}
