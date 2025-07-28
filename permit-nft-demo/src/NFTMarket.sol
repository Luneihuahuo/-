// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MyNFT.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract NFTMarket is Ownable, ReentrancyGuard {
    using ECDSA for bytes32;
    
    MyNFT public nft;
    IERC20 public token;
    IERC20Permit public permitToken;
    
    // NFT上架信息
    struct Listing {
        uint256 tokenId;
        address seller;
        uint256 price;
        bool active;
    }
    
    mapping(uint256 => Listing) public listings;
    mapping(bytes32 => bool) public usedPermits;
    
    event NFTListed(uint256 indexed tokenId, address indexed seller, uint256 price);
    event NFTSold(uint256 indexed tokenId, address indexed buyer, address indexed seller, uint256 price);
    event NFTDelisted(uint256 indexed tokenId);
    
    constructor(address _nft, address _token) {
        nft = MyNFT(_nft);
        token = IERC20(_token);
        permitToken = IERC20Permit(_token);
    }
    
    // 上架NFT
    function listNFT(uint256 tokenId, uint256 price) external {
        require(nft.ownerOf(tokenId) == msg.sender, "Not the owner");
        require(nft.getApproved(tokenId) == address(this) || nft.isApprovedForAll(msg.sender, address(this)), "Not approved");
        require(price > 0, "Price must be greater than 0");
        
        listings[tokenId] = Listing({
            tokenId: tokenId,
            seller: msg.sender,
            price: price,
            active: true
        });
        
        emit NFTListed(tokenId, msg.sender, price);
    }
    
    // 下架NFT
    function delistNFT(uint256 tokenId) external {
        require(listings[tokenId].seller == msg.sender, "Not the seller");
        require(listings[tokenId].active, "Not listed");
        
        listings[tokenId].active = false;
        emit NFTDelisted(tokenId);
    }
    
    // 普通购买NFT
    function buyNFT(uint256 tokenId) external nonReentrant {
        Listing memory listing = listings[tokenId];
        require(listing.active, "NFT not listed");
        require(nft.ownerOf(tokenId) == listing.seller, "Seller no longer owns NFT");
        
        // 转账Token
        require(token.transferFrom(msg.sender, listing.seller, listing.price), "Token transfer failed");
        
        // 转移NFT
        nft.safeTransferFrom(listing.seller, msg.sender, tokenId);
        
        // 更新状态
        listings[tokenId].active = false;
        
        emit NFTSold(tokenId, msg.sender, listing.seller, listing.price);
    }
    
    // 生成白名单permit哈希
    function getPermitHash(address buyer, uint256 tokenId, uint256 nonce) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(buyer, tokenId, nonce));
    }
    
    // 使用permit白名单购买NFT
    function permitBuy(
        uint256 tokenId,
        uint256 nonce,
        bytes calldata signature,
        uint256 tokenAmount,
        uint256 deadline,
        uint8 v, bytes32 r, bytes32 s
    ) external nonReentrant {
        Listing memory listing = listings[tokenId];
        require(listing.active, "NFT not listed");
        require(nft.ownerOf(tokenId) == listing.seller, "Seller no longer owns NFT");
        
        // 验证白名单签名
        bytes32 permitHash = getPermitHash(msg.sender, tokenId, nonce);
        require(!usedPermits[permitHash], "Permit already used");
        
        bytes32 ethSignedHash = permitHash.toEthSignedMessageHash();
        address signer = ethSignedHash.recover(signature);
        require(signer == owner(), "Invalid whitelist signature");
        
        // 标记permit已使用
        usedPermits[permitHash] = true;
        
        // 使用permit授权Token
        permitToken.permit(msg.sender, address(this), tokenAmount, deadline, v, r, s);
        
        // 转账Token
        require(token.transferFrom(msg.sender, listing.seller, listing.price), "Token transfer failed");
        
        // 转移NFT
        nft.safeTransferFrom(listing.seller, msg.sender, tokenId);
        
        // 更新状态
        listings[tokenId].active = false;
        
        emit NFTSold(tokenId, msg.sender, listing.seller, listing.price);
    }
    
    // 获取NFT上架信息
    function getListing(uint256 tokenId) external view returns (Listing memory) {
        return listings[tokenId];
    }
}