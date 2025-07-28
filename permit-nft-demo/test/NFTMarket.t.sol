// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/MyToken.sol";
import "../src/MyNFT.sol";
import "../src/NFTMarket.sol";
import "../src/TokenBank.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract NFTMarketTest is Test {
    using ECDSA for bytes32;
    
    MyToken public token;
    MyNFT public nft;
    NFTMarket public market;
    TokenBank public bank;
    
    address public owner;
    address public seller;
    address public buyer;
    uint256 public sellerPrivateKey;
    uint256 public buyerPrivateKey;
    uint256 public ownerPrivateKey;
    
    uint256 public constant TOKEN_PRICE = 100 * 10**18; // 100 tokens
    uint256 public constant INITIAL_SUPPLY = 1000000 * 10**18;
    
    function setUp() public {
        // 设置私钥和地址
        ownerPrivateKey = 0xA11CE;
        sellerPrivateKey = 0xB0B;
        buyerPrivateKey = 0xC0FFEE;
        
        owner = vm.addr(ownerPrivateKey);
        seller = vm.addr(sellerPrivateKey);
        buyer = vm.addr(buyerPrivateKey);
        
        // 设置owner为部署者
        vm.startPrank(owner);
        
        // 部署合约
        token = new MyToken(INITIAL_SUPPLY);
        nft = new MyNFT();
        market = new NFTMarket(address(nft), address(token));
        bank = new TokenBank(address(token));
        
        // 给seller和buyer分配tokens
        token.transfer(seller, 10000 * 10**18);
        token.transfer(buyer, 10000 * 10**18);
        
        // 铸造NFT给seller
        uint256 tokenId = nft.mint(seller, "https://example.com/nft/1");
        
        vm.stopPrank();
        
        // seller授权market合约
        vm.prank(seller);
        nft.approve(address(market), tokenId);
    }
    
    function testTokenBankPermitDeposit() public {
        console.log("\n=== Token Bank Permit Deposit Test ===");
        
        uint256 depositAmount = 150 * 10**18;
        uint256 deadline = block.timestamp + 3600;
        
        // 记录存款前的余额
        uint256 buyerBalanceBefore = token.balanceOf(buyer);
        uint256 bankBalanceBefore = bank.balances(buyer);
        
        console.log("Buyer token balance before deposit:", buyerBalanceBefore / 10**18, "tokens");
        console.log("Bank balance before deposit:", bankBalanceBefore / 10**18, "tokens");
        console.log("Deposit amount:", depositAmount / 10**18, "tokens");
        
        bytes32 domainSeparator = token.DOMAIN_SEPARATOR();
        bytes32 permitHash = keccak256(
            abi.encodePacked(
                "\x19\x01",
                domainSeparator,
                keccak256(
                    abi.encode(
                        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"),
                        buyer,
                        address(bank),
                        depositAmount,
                        token.nonces(buyer),
                        deadline
                    )
                )
            )
        );
        
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(buyerPrivateKey, permitHash);
        
        vm.prank(buyer);
        bank.permitDeposit(depositAmount, deadline, v, r, s);
        
        console.log("[SUCCESS] Permit deposit successful!");
        console.log("Buyer token balance after deposit:", token.balanceOf(buyer) / 10**18, "tokens");
        console.log("Bank balance after deposit:", bank.balances(buyer) / 10**18, "tokens");
        console.log("Token transfer:", depositAmount / 10**18, "tokens (buyer -> bank)");
        
        assertEq(bank.balances(buyer), depositAmount);
        assertEq(token.balanceOf(buyer), buyerBalanceBefore - depositAmount);
        assertEq(token.balanceOf(address(bank)), depositAmount);
    }
    
    function testNFTMarketPermitBuy() public {
        uint256 tokenId = 1;
        uint256 nonce = 1;
        
        // seller上架NFT
        vm.prank(seller);
        market.listNFT(tokenId, TOKEN_PRICE);
        
        // owner生成白名单签名
        bytes32 permitHash = market.getPermitHash(buyer, tokenId, nonce);
        bytes32 ethSignedHash = permitHash.toEthSignedMessageHash();
        (uint8 whitelistV, bytes32 whitelistR, bytes32 whitelistS) = vm.sign(ownerPrivateKey, ethSignedHash);
        bytes memory whitelistSignature = abi.encodePacked(whitelistR, whitelistS, whitelistV);
        
        // 准备token permit签名
        uint256 deadline = block.timestamp + 3600;
        bytes32 domainSeparator = token.DOMAIN_SEPARATOR();
        
        bytes32 tokenPermitHash = keccak256(
            abi.encodePacked(
                "\x19\x01",
                domainSeparator,
                keccak256(
                    abi.encode(
                        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"),
                        buyer,
                        address(market),
                        TOKEN_PRICE,
                        token.nonces(buyer),
                        deadline
                    )
                )
            )
        );
        
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(buyerPrivateKey, tokenPermitHash);
        
        // 记录购买前状态
        uint256 buyerTokensBefore = token.balanceOf(buyer);
        uint256 sellerTokensBefore = token.balanceOf(seller);
        address nftOwnerBefore = nft.ownerOf(tokenId);
        
        // 执行permit购买
        vm.prank(buyer);
        market.permitBuy(tokenId, nonce, whitelistSignature, TOKEN_PRICE, deadline, v, r, s);
        
        // 验证结果
        assertEq(nft.ownerOf(tokenId), buyer);
        assertEq(token.balanceOf(buyer), buyerTokensBefore - TOKEN_PRICE);
        assertEq(token.balanceOf(seller), sellerTokensBefore + TOKEN_PRICE);
        assertFalse(market.getListing(tokenId).active);
        
        console.log("\n=== NFT Market Permit Buy Test ===");
        console.log("NFT owner before:", nftOwnerBefore);
        console.log("NFT owner after:", nft.ownerOf(tokenId));
        console.log("Buyer tokens before:", buyerTokensBefore / 10**18, "tokens");
        console.log("Buyer tokens after:", token.balanceOf(buyer) / 10**18, "tokens");
        console.log("Seller tokens before:", sellerTokensBefore / 10**18, "tokens");
        console.log("Seller tokens after:", token.balanceOf(seller) / 10**18, "tokens");
        console.log("NFT price:", TOKEN_PRICE / 10**18, "tokens");
    }
    
    function testCompleteWorkflow() public {
        console.log("\n=== Complete Workflow Test ===");
        
        // 1. Token存款测试
        uint256 depositAmount = 200 * 10**18;
        uint256 deadline = block.timestamp + 3600;
        
        // 记录存款前的余额
        uint256 buyerBalanceBefore = token.balanceOf(buyer);
        uint256 bankBalanceBefore = bank.balances(buyer);
        
        console.log("=== STEP 1: TOKEN DEPOSIT ===");
        console.log("Buyer token balance before deposit:", buyerBalanceBefore / 10**18, "tokens");
        console.log("Bank balance before deposit:", bankBalanceBefore / 10**18, "tokens");
        
        bytes32 domainSeparator = token.DOMAIN_SEPARATOR();
        bytes32 permitHash = keccak256(
            abi.encodePacked(
                "\x19\x01",
                domainSeparator,
                keccak256(
                    abi.encode(
                        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"),
                        buyer,
                        address(bank),
                        depositAmount,
                        token.nonces(buyer),
                        deadline
                    )
                )
            )
        );
        
        (uint8 v1, bytes32 r1, bytes32 s1) = vm.sign(buyerPrivateKey, permitHash);
        
        vm.prank(buyer);
        bank.permitDeposit(depositAmount, deadline, v1, r1, s1);
        
        console.log("[SUCCESS] Deposited", depositAmount / 10**18, "tokens to bank via permit");
        console.log("Buyer token balance after deposit:", token.balanceOf(buyer) / 10**18, "tokens");
        console.log("Bank balance after deposit:", bank.balances(buyer) / 10**18, "tokens");
        
        // 2. NFT购买测试
        uint256 tokenId = 1;
        uint256 nonce = 2;
        
        console.log("\n=== STEP 2: NFT PURCHASE ===");
        
        // 记录购买前的状态
        uint256 buyerTokensBefore = token.balanceOf(buyer);
        uint256 sellerTokensBefore = token.balanceOf(seller);
        address nftOwnerBefore = nft.ownerOf(tokenId);
        
        console.log("Buyer token balance before purchase:", buyerTokensBefore / 10**18, "tokens");
        console.log("Seller token balance before purchase:", sellerTokensBefore / 10**18, "tokens");
        console.log("NFT #", tokenId, "owner before purchase:", nftOwnerBefore);
        console.log("NFT price:", TOKEN_PRICE / 10**18, "tokens");
        
        vm.prank(seller);
        market.listNFT(tokenId, TOKEN_PRICE);
        
        // 生成白名单签名
        bytes32 whitelistHash = market.getPermitHash(buyer, tokenId, nonce);
        bytes32 ethSignedHash = whitelistHash.toEthSignedMessageHash();
        (uint8 whitelistV, bytes32 whitelistR, bytes32 whitelistS) = vm.sign(ownerPrivateKey, ethSignedHash);
        bytes memory whitelistSignature = abi.encodePacked(whitelistR, whitelistS, whitelistV);
        
        // Token permit签名
        deadline = block.timestamp + 3600;
        bytes32 tokenPermitHash = keccak256(
            abi.encodePacked(
                "\x19\x01",
                domainSeparator,
                keccak256(
                    abi.encode(
                        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"),
                        buyer,
                        address(market),
                        TOKEN_PRICE,
                        token.nonces(buyer),
                        deadline
                    )
                )
            )
        );
        
        (uint8 v2, bytes32 r2, bytes32 s2) = vm.sign(buyerPrivateKey, tokenPermitHash);
        
        vm.prank(buyer);
        market.permitBuy(tokenId, nonce, whitelistSignature, TOKEN_PRICE, deadline, v2, r2, s2);
        
        console.log("[SUCCESS] Successfully bought NFT #", tokenId, "via permit");
        console.log("Buyer token balance after purchase:", token.balanceOf(buyer) / 10**18, "tokens");
        console.log("Seller token balance after purchase:", token.balanceOf(seller) / 10**18, "tokens");
        console.log("NFT #", tokenId, "now owned by:", nft.ownerOf(tokenId));
        console.log("Token transfer amount:", TOKEN_PRICE / 10**18, "tokens (buyer -> seller)");
    }
    
    function testRevertWhenPermitBuyWithoutWhitelist() public {
        uint256 tokenId = 1;
        uint256 nonce = 3;
        
        vm.prank(seller);
        market.listNFT(tokenId, TOKEN_PRICE);
        
        // 使用错误的私钥生成签名（不是owner）
        bytes32 permitHash = market.getPermitHash(buyer, tokenId, nonce);
        bytes32 ethSignedHash = permitHash.toEthSignedMessageHash();
        (uint8 whitelistV, bytes32 whitelistR, bytes32 whitelistS) = vm.sign(buyerPrivateKey, ethSignedHash); // 错误的私钥
        bytes memory whitelistSignature = abi.encodePacked(whitelistR, whitelistS, whitelistV);
        
        uint256 deadline = block.timestamp + 3600;
        bytes32 domainSeparator = token.DOMAIN_SEPARATOR();
        bytes32 tokenPermitHash = keccak256(
            abi.encodePacked(
                "\x19\x01",
                domainSeparator,
                keccak256(
                    abi.encode(
                        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"),
                        buyer,
                        address(market),
                        TOKEN_PRICE,
                        token.nonces(buyer),
                        deadline
                    )
                )
            )
        );
        
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(buyerPrivateKey, tokenPermitHash);
        
        // 这应该失败
        vm.expectRevert("Invalid whitelist signature");
        vm.prank(buyer);
        market.permitBuy(tokenId, nonce, whitelistSignature, TOKEN_PRICE, deadline, v, r, s);
    }
}