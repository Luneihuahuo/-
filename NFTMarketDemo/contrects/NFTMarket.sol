// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
}

interface IMyToken {
    function transfer(address to, uint256 value) external returns (bool);
}

contract NFTMarket {
    struct Listing {
        address seller;
        address nftContract;
        uint256 tokenId;
        uint256 price;
    }
address public tokenAddress;
    mapping(bytes32 => Listing) public listings;

    constructor(address _tokenAddress) {
        tokenAddress = _tokenAddress;
    }

    function list(address nftContract, uint256 tokenId, uint256 price) public {
        IERC721 nft = IERC721(nftContract);
        require(nft.ownerOf(tokenId) == msg.sender, "Not owner");
        require(nft.getApproved(tokenId) == address(this), "NFT not approved");

        bytes32 key = keccak256(abi.encodePacked(nftContract, tokenId));
        listings[key] = Listing(msg.sender, nftContract, tokenId, price);
    }

    function buyNFT(address nftContract, uint256 tokenId) public {
        bytes32 key = keccak256(abi.encodePacked(nftContract, tokenId));
        Listing memory l = listings[key];
        require(l.price > 0, "Not listed");

        IMyToken(tokenAddress).transfer(l.seller, l.price);
        IERC721(nftContract).safeTransferFrom(l.seller, msg.sender, tokenId);
        delete listings[key];
    }
function tokensReceived(address from, uint256 amount, bytes calldata data) external {
        require(msg.sender == tokenAddress, "Only token");

        (address nftContract, uint256 tokenId) = abi.decode(data, (address, uint256));
        bytes32 key = keccak256(abi.encodePacked(nftContract, tokenId));
        Listing memory l = listings[key];

        require(amount >= l.price, "Underpaid");

        IERC721(nftContract).safeTransferFrom(l.seller, from, tokenId);
        IMyToken(tokenAddress).transfer(l.seller, l.price);

        delete listings[key];
    }
}
