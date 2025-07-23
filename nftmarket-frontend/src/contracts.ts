// 这是一个占位符文件
// 请将你的 NFT 市场合约和 ERC721 合约的 ABI 和地址粘贴到这里

// 示例 NFT 市场合约地址（请替换）
export const marketplaceAddress = '0x...'; 

// 示例 NFT 市场合约 ABI（请替换）
export const marketplaceAbi = [
  // approve(address to, uint256 tokenId)
  {
    "inputs": [
      { "internalType": "address", "name": "to", "type": "address" },
      { "internalType": "uint256", "name": "tokenId", "type": "uint256" }
    ],
    "name": "approve",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  // list(address nftContract, uint256 tokenId, uint256 price)
  {
    "inputs": [
      { "internalType": "address", "name": "nftContract", "type": "address" },
      { "internalType": "uint256", "name": "tokenId", "type": "uint256" },
      { "internalType": "uint256", "name": "price", "type": "uint256" }
    ],
    "name": "list",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  // buy(address nftContract, uint256 tokenId)
  {
    "inputs": [
      { "internalType": "address", "name": "nftContract", "type": "address" },
      { "internalType": "uint256", "name": "tokenId", "type": "uint256" }
    ],
    "name": "buy",
    "outputs": [],
    "stateMutability": "payable",
    "type": "function"
  },
] as const;


// 示例 ERC20 Token 合约地址（用于支付，请替换）
export const tokenAddress = '0x...';

// 示例 ERC20 Token 合约 ABI（请替换）
export const tokenAbi = [
    // approve(address spender, uint256 amount)
    {
        "inputs": [
          { "internalType": "address", "name": "spender", "type": "address" },
          { "internalType": "uint256", "name": "amount", "type": "uint256" }
        ],
        "name": "approve",
        "outputs": [
          { "internalType": "bool", "name": "", "type": "bool" }
        ],
        "stateMutability": "nonpayable",
        "type": "function"
      }
] as const;

// 示例 NFT (ERC721) 合约 ABI（用于授权，请替换）
export const nftAbi = [
  // approve(address to, uint256 tokenId)
  {
    "inputs": [
      { "internalType": "address", "name": "to", "type": "address" },
      { "internalType": "uint256", "name": "tokenId", "type": "uint256" }
    ],
    "name": "approve",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  }
] as const; 