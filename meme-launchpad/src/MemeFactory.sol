// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./MemeToken.sol";

/**
 * @title MemeFactory
 * @dev Factory contract for deploying Meme tokens using minimal proxy pattern
 */
contract MemeFactory is Ownable, ReentrancyGuard {
    using Clones for address;
    
    address public immutable implementation;
    uint256 public constant PLATFORM_FEE_PERCENTAGE = 1; // 1% platform fee
    uint256 public constant FEE_DENOMINATOR = 100;
    
    // Mapping from token address to creator
    mapping(address => address) public tokenCreators;
    
    // Array of all deployed tokens
    address[] public deployedTokens;
    
    // Platform earnings
    uint256 public platformEarnings;
    
    event MemeDeployed(
        address indexed tokenAddress,
        address indexed creator,
        string symbol,
        uint256 totalSupply,
        uint256 perMint,
        uint256 price
    );
    
    event MemeMinted(
        address indexed tokenAddress,
        address indexed minter,
        uint256 amount,
        uint256 totalCost,
        uint256 platformFee,
        uint256 creatorFee
    );
    
    event PlatformFeesWithdrawn(address indexed owner, uint256 amount);
    
    constructor() {
        // Deploy the implementation contract
        implementation = address(new MemeToken());
    }
    
    /**
     * @dev Deploy a new Meme token using minimal proxy
     * @param symbol Token symbol
     * @param totalSupply Maximum total supply
     * @param perMint Amount to mint per transaction
     * @param price Price per token in wei
     * @return tokenAddress Address of the deployed token
     */
    function deployMeme(
        string memory symbol,
        uint256 totalSupply,
        uint256 perMint,
        uint256 price
    ) external returns (address tokenAddress) {
        require(bytes(symbol).length > 0, "Symbol cannot be empty");
        require(totalSupply > 0, "Total supply must be greater than 0");
        require(perMint > 0, "Per mint must be greater than 0");
        require(perMint <= totalSupply, "Per mint cannot exceed total supply");
        
        // Clone the implementation contract
        tokenAddress = implementation.clone();
        
        // Initialize the cloned contract
        MemeToken(tokenAddress).initialize(
            symbol,
            totalSupply,
            perMint,
            price,
            msg.sender,
            address(this)
        );
        
        // Store creator mapping
        tokenCreators[tokenAddress] = msg.sender;
        
        // Add to deployed tokens array
        deployedTokens.push(tokenAddress);
        
        emit MemeDeployed(
            tokenAddress,
            msg.sender,
            symbol,
            totalSupply,
            perMint,
            price
        );
        
        return tokenAddress;
    }
    
    /**
     * @dev Mint Meme tokens by paying the required fee
     * @param tokenAddr Address of the Meme token to mint
     */
    function mintMeme(address tokenAddr) external payable nonReentrant {
        require(tokenAddr != address(0), "Invalid token address");
        require(tokenCreators[tokenAddr] != address(0), "Token not deployed by this factory");
        
        MemeToken token = MemeToken(tokenAddr);
        require(token.canMint(), "Cannot mint more tokens");
        
        uint256 tokenPrice = token.price();
        uint256 perMintAmount = token.perMint();
        uint256 totalCost = tokenPrice * perMintAmount;
        
        require(msg.value >= totalCost, "Insufficient payment");
        
        // Calculate fees
        uint256 platformFee = (totalCost * PLATFORM_FEE_PERCENTAGE) / FEE_DENOMINATOR;
        uint256 creatorFee = totalCost - platformFee;
        
        // Update platform earnings
        platformEarnings += platformFee;
        
        // Transfer creator fee
        address creator = tokenCreators[tokenAddr];
        if (creatorFee > 0) {
            (bool success, ) = payable(creator).call{value: creatorFee}("");
            require(success, "Creator fee transfer failed");
        }
        
        // Mint tokens to the buyer
        bool mintSuccess = token.mint(msg.sender);
        require(mintSuccess, "Minting failed");
        
        // Refund excess payment
        if (msg.value > totalCost) {
            (bool refundSuccess, ) = payable(msg.sender).call{value: msg.value - totalCost}("");
            require(refundSuccess, "Refund failed");
        }
        
        emit MemeMinted(
            tokenAddr,
            msg.sender,
            perMintAmount,
            totalCost,
            platformFee,
            creatorFee
        );
    }
    
    /**
     * @dev Withdraw platform fees (only owner)
     */
    function withdrawPlatformFees() external onlyOwner {
        require(platformEarnings > 0, "No fees to withdraw");
        
        uint256 amount = platformEarnings;
        platformEarnings = 0;
        
        (bool success, ) = payable(owner()).call{value: amount}("");
        require(success, "Withdrawal failed");
        
        emit PlatformFeesWithdrawn(owner(), amount);
    }
    
    /**
     * @dev Get the number of deployed tokens
     */
    function getDeployedTokensCount() external view returns (uint256) {
        return deployedTokens.length;
    }
    
    /**
     * @dev Get deployed token address by index
     */
    function getDeployedToken(uint256 index) external view returns (address) {
        require(index < deployedTokens.length, "Index out of bounds");
        return deployedTokens[index];
    }
    
    /**
     * @dev Get all deployed tokens
     */
    function getAllDeployedTokens() external view returns (address[] memory) {
        return deployedTokens;
    }
    
    /**
     * @dev Get token creator
     */
    function getTokenCreator(address tokenAddr) external view returns (address) {
        return tokenCreators[tokenAddr];
    }
    
    /**
     * @dev Calculate minting cost for a token
     */
    function calculateMintingCost(address tokenAddr) external view returns (
        uint256 totalCost,
        uint256 platformFee,
        uint256 creatorFee
    ) {
        require(tokenCreators[tokenAddr] != address(0), "Token not deployed by this factory");
        
        MemeToken token = MemeToken(tokenAddr);
        uint256 tokenPrice = token.price();
        uint256 perMintAmount = token.perMint();
        
        totalCost = tokenPrice * perMintAmount;
        platformFee = (totalCost * PLATFORM_FEE_PERCENTAGE) / FEE_DENOMINATOR;
        creatorFee = totalCost - platformFee;
    }
    
    /**
     * @dev Get factory statistics
     */
    function getFactoryStats() external view returns (
        uint256 totalTokensDeployed,
        uint256 totalPlatformEarnings,
        address implementationAddress
    ) {
        return (
            deployedTokens.length,
            platformEarnings,
            implementation
        );
    }
}
