const hre = require("hardhat");
const { ethers } = hre;
const fs = require('fs');
const path = require('path');

async function main() {
  const [deployer, addr1, addr2, addr3] = await hre.ethers.getSigners();
  
  console.log("部署账户:", deployer.address);
  console.log("账户余额:", (await deployer.getBalance()).toString());
  
  // 部署代币合约
  const Token = await hre.ethers.getContractFactory("MyToken");
  const token = await Token.deploy();
  await token.deployed();

  console.log("MyToken deployed to:", token.address);
  console.log("部署者地址:", deployer.address);
  console.log("测试地址1:", addr1.address);
  console.log("测试地址2:", addr2.address);
  console.log("测试地址3:", addr3.address);
  
  // 创建.env文件
  const envContent = `TOKEN_ADDRESS=${token.address}\nPROVIDER_URL=http://127.0.0.1:8545\nPORT=3001`;
  fs.writeFileSync(path.join(__dirname, '../.env'), envContent);
  console.log(".env文件已创建");
  
  // 等待几个区块确认
  console.log("等待合约确认...");
  await new Promise(resolve => setTimeout(resolve, 2000));
  
  // 执行多笔转账以创建测试数据
  console.log("开始执行测试转账...");
  
  // 转账1: deployer -> addr1 (10 MTK)
  const tx1 = await token.transfer(addr1.address, ethers.utils.parseEther("10"));
  await tx1.wait();
  console.log(`转账1完成: ${deployer.address} -> ${addr1.address}, 10 MTK`);
  
  // 转账2: deployer -> addr2 (20 MTK)
  const tx2 = await token.transfer(addr2.address, ethers.utils.parseEther("20"));
  await tx2.wait();
  console.log(`转账2完成: ${deployer.address} -> ${addr2.address}, 20 MTK`);
  
  // 转账3: deployer -> addr3 (15 MTK)
  const tx3 = await token.transfer(addr3.address, ethers.utils.parseEther("15"));
  await tx3.wait();
  console.log(`转账3完成: ${deployer.address} -> ${addr3.address}, 15 MTK`);
  
  // 转账4: addr1 -> addr2 (5 MTK)
  const tokenAsAddr1 = token.connect(addr1);
  const tx4 = await tokenAsAddr1.transfer(addr2.address, ethers.utils.parseEther("5"));
  await tx4.wait();
  console.log(`转账4完成: ${addr1.address} -> ${addr2.address}, 5 MTK`);
  
  // 转账5: addr2 -> addr3 (8 MTK)
  const tokenAsAddr2 = token.connect(addr2);
  const tx5 = await tokenAsAddr2.transfer(addr3.address, ethers.utils.parseEther("8"));
  await tx5.wait();
  console.log(`转账5完成: ${addr2.address} -> ${addr3.address}, 8 MTK`);
  
  console.log("\n=== 部署和测试完成 ===");
  console.log(`代币合约地址: ${token.address}`);
  console.log(`总共执行了 5 笔转账`);
  console.log(`\n测试地址及其余额:`);
  
  // 查询余额
  const deployerBalance = await token.balanceOf(deployer.address);
  const addr1Balance = await token.balanceOf(addr1.address);
  const addr2Balance = await token.balanceOf(addr2.address);
  const addr3Balance = await token.balanceOf(addr3.address);
  
  console.log(`部署者 (${deployer.address}): ${ethers.utils.formatEther(deployerBalance)} MTK`);
  console.log(`地址1 (${addr1.address}): ${ethers.utils.formatEther(addr1Balance)} MTK`);
  console.log(`地址2 (${addr2.address}): ${ethers.utils.formatEther(addr2Balance)} MTK`);
  console.log(`地址3 (${addr3.address}): ${ethers.utils.formatEther(addr3Balance)} MTK`);
  
  console.log("\n请运行以下命令启动后端服务:");
  console.log("npm install");
  console.log("npm start");
  console.log("\n然后访问 http://localhost:3001 查看前端界面");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
