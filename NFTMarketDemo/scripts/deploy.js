async function main() {
  const [deployer] = await ethers.getSigners();

  const MyToken = await ethers.getContractFactory("MyToken");
  const token = await MyToken.deploy(ethers.utils.parseEther("1000000"));

  const MyNFT = await ethers.getContractFactory("MyNFT");
  const nft = await MyNFT.deploy();

  const Market = await ethers.getContractFactory("NFTMarket");
  const market = await Market.deploy(token.address);

  console.log("Token:", token.address);
  console.log("NFT:", nft.address);
  console.log("Market:", market.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
