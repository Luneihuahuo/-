// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

/**
 * @title MemeToken
 * @dev ERC20 token implementation for Meme tokens with controlled minting
 */
contract MemeToken is ERC20, Ownable, Initializable {
    uint256 public totalSupplyLimit;
    uint256 public perMint;
    uint256 public price;
    address public creator;
    address public factory;
    
    uint256 public totalMinted;
    
    event TokenMinted(address indexed to, uint256 amount, uint256 cost);
    
    constructor() ERC20("", "") {
        // Disable initializers for the implementation contract
        _disableInitializers();
    }
    
    /**
     * @dev Initialize the token (called by factory)
     * @param _symbol Token symbol
     * @param _totalSupply Maximum total supply
     * @param _perMint Amount to mint per transaction
     * @param _price Price per token in wei
     * @param _creator Address of the token creator
     * @param _factory Address of the factory contract
     */
    function initialize(
        string memory _symbol,
        uint256 _totalSupply,
        uint256 _perMint,
        uint256 _price,
        address _creator,
        address _factory
    ) external initializer {
        require(_totalSupply > 0, "Total supply must be greater than 0");
        require(_perMint > 0, "Per mint must be greater than 0");
        require(_perMint <= _totalSupply, "Per mint cannot exceed total supply");
        require(_creator != address(0), "Creator cannot be zero address");
        require(_factory != address(0), "Factory cannot be zero address");
        
        // Initialize ERC20 with fixed name and provided symbol
        _transferOwnership(_factory);
        
        totalSupplyLimit = _totalSupply;
        perMint = _perMint;
        price = _price;
        creator = _creator;
        factory = _factory;
        totalMinted = 0;
    }
    
    /**
     * @dev Get token name (fixed for all meme tokens)
     */
    function name() public pure override returns (string memory) {
        return "Meme Token";
    }
    
    /**
     * @dev Mint tokens to specified address (only callable by factory)
     * @param to Address to mint tokens to
     * @return success Whether minting was successful
     */
    function mint(address to) external onlyOwner returns (bool success) {
        require(to != address(0), "Cannot mint to zero address");
        require(totalMinted + perMint <= totalSupplyLimit, "Exceeds total supply limit");
        
        _mint(to, perMint);
        totalMinted += perMint;
        
        emit TokenMinted(to, perMint, price);
        return true;
    }
    
    /**
     * @dev Get remaining mintable supply
     */
    function remainingSupply() external view returns (uint256) {
        return totalSupplyLimit - totalMinted;
    }
    
    /**
     * @dev Check if more tokens can be minted
     */
    function canMint() external view returns (bool) {
        return totalMinted + perMint <= totalSupplyLimit;
    }
    
    /**
     * @dev Get token information
     */
    function getTokenInfo() external view returns (
        string memory tokenSymbol,
        uint256 totalSupplyLimitValue,
        uint256 perMintValue,
        uint256 priceValue,
        address creatorAddress,
        uint256 totalMintedValue,
        uint256 remainingSupplyValue
    ) {
        return (
            symbol(),
            totalSupplyLimit,
            perMint,
            price,
            creator,
            totalMinted,
            totalSupplyLimit - totalMinted
        );
    }
}
