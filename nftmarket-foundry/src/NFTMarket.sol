
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract NFTMarket {
    struct Listing {
        address seller;
        address token;
        uint256 price;
    }

    mapping(address => mapping(uint256 => Listing)) public listings;

    event Listed(address indexed nft, uint256 indexed tokenId, address seller, address token, uint256 price);
    event Purchased(address indexed nft, uint256 indexed tokenId, address buyer, address token, uint256 price);

    function list(address nft, uint256 tokenId, address erc20, uint256 price) external {
        require(IERC721(nft).ownerOf(tokenId) == msg.sender, "Not owner");
        IERC721(nft).transferFrom(msg.sender, address(this), tokenId);
        listings[nft][tokenId] = Listing(msg.sender, erc20, price);
        emit Listed(nft, tokenId, msg.sender, erc20, price);
    }

    function buy(address nft, uint256 tokenId) external {
        Listing memory item = listings[nft][tokenId];
        require(item.seller != address(0), "Not listed");
        require(item.seller != msg.sender, "Cannot buy your own NFT");
        IERC20(item.token).transferFrom(msg.sender, item.seller, item.price);
        IERC721(nft).transferFrom(address(this), msg.sender, tokenId);
        delete listings[nft][tokenId];
        emit Purchased(nft, tokenId, msg.sender, item.token, item.price);
    }
}
