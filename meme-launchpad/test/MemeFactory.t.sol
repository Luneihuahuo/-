// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/MemeFactory.sol";
import "../src/MemeToken.sol";

contract MemeFactoryTest is Test {
    MemeFactory public factory;
    address public owner;
    address public creator;
    address public buyer1;
    address public buyer2;
    
    // Test token parameters
    string constant SYMBOL = "MEME";
    uint256 constant TOTAL_SUPPLY = 1000000 * 1e18; // 1M tokens
    uint256 constant PER_MINT = 1000 * 1e18; // 1K tokens per mint
    uint256 constant PRICE = 0.001 ether; // 0.001 ETH per token
    
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
    
    function setUp() public {
        owner = address(this);
        creator = makeAddr("creator");
        buyer1 = makeAddr("buyer1");
        buyer2 = makeAddr("buyer2");
        
        // Deploy factory
        factory = new MemeFactory();
        
        // Give test accounts some ETH
        vm.deal(creator, 10 ether);
        vm.deal(buyer1, 10 ether);
        vm.deal(buyer2, 10 ether);
        
        console.log("=== Setup Complete ===");
        console.log("Factory deployed at:", address(factory));
        console.log("Owner:", owner);
        console.log("Creator:", creator);
        console.log("Buyer1:", buyer1);
        console.log("Buyer2:", buyer2);
    }
    
    function testDeployMeme() public {
        console.log("\n=== Test: Deploy Meme ===");
        
        vm.startPrank(creator);
        
        // Expect the MemeDeployed event
        vm.expectEmit(true, true, false, true);
        emit MemeDeployed(address(0), creator, SYMBOL, TOTAL_SUPPLY, PER_MINT, PRICE);
        
        address tokenAddr = factory.deployMeme(SYMBOL, TOTAL_SUPPLY, PER_MINT, PRICE);
        
        vm.stopPrank();
        
        // Verify deployment
        assertTrue(tokenAddr != address(0), "Token address should not be zero");
        assertEq(factory.getTokenCreator(tokenAddr), creator, "Creator should be set correctly");
        assertEq(factory.getDeployedTokensCount(), 1, "Should have 1 deployed token");
        assertEq(factory.getDeployedToken(0), tokenAddr, "First token should match");
        
        // Verify token properties
        MemeToken token = MemeToken(tokenAddr);
        assertEq(token.symbol(), SYMBOL, "Symbol should match");
        assertEq(token.name(), "Meme Token", "Name should be fixed");
        assertEq(token.totalSupplyLimit(), TOTAL_SUPPLY, "Total supply should match");
        assertEq(token.perMint(), PER_MINT, "Per mint should match");
        assertEq(token.price(), PRICE, "Price should match");
        assertEq(token.creator(), creator, "Creator should match");
        assertEq(token.factory(), address(factory), "Factory should match");
        assertEq(token.totalMinted(), 0, "Total minted should be 0 initially");
        
        console.log("Token deployed successfully at:", tokenAddr);
        console.log("Token symbol:", token.symbol());
        console.log("Token name:", token.name());
        console.log("Total supply limit:", token.totalSupplyLimit());
        console.log("Per mint amount:", token.perMint());
        console.log("Token price:", token.price());
    }
    
    function testMintMeme() public {
        console.log("\n=== Test: Mint Meme ===");
        
        // Deploy token first
        vm.prank(creator);
        address tokenAddr = factory.deployMeme(SYMBOL, TOTAL_SUPPLY, PER_MINT, PRICE);
        
        MemeToken token = MemeToken(tokenAddr);
        uint256 totalCost = PRICE * PER_MINT;
        uint256 platformFee = (totalCost * 1) / 100; // 1%
        uint256 creatorFee = totalCost - platformFee;
        
        console.log("Total cost for minting:", totalCost);
        console.log("Platform fee (1%):", platformFee);
        console.log("Creator fee (99%):", creatorFee);
        
        // Record initial balances
        uint256 initialCreatorBalance = creator.balance;
        uint256 initialPlatformEarnings = factory.platformEarnings();
        
        console.log("Initial creator balance:", initialCreatorBalance);
        console.log("Initial platform earnings:", initialPlatformEarnings);
        
        // Mint tokens
        vm.startPrank(buyer1);
        
        // Expect the MemeMinted event
        vm.expectEmit(true, true, false, true);
        emit MemeMinted(tokenAddr, buyer1, PER_MINT, totalCost, platformFee, creatorFee);
        
        factory.mintMeme{value: totalCost}(tokenAddr);
        
        vm.stopPrank();
        
        // Verify minting results
        assertEq(token.balanceOf(buyer1), PER_MINT, "Buyer should receive correct amount");
        assertEq(token.totalMinted(), PER_MINT, "Total minted should increase");
        assertEq(token.remainingSupply(), TOTAL_SUPPLY - PER_MINT, "Remaining supply should decrease");
        
        // Verify fee distribution
        assertEq(creator.balance, initialCreatorBalance + creatorFee, "Creator should receive creator fee");
        assertEq(factory.platformEarnings(), initialPlatformEarnings + platformFee, "Platform should receive platform fee");
        
        console.log("Minting successful!");
        console.log("Buyer1 token balance:", token.balanceOf(buyer1));
        console.log("Total minted:", token.totalMinted());
        console.log("Remaining supply:", token.remainingSupply());
        console.log("Creator balance after:", creator.balance);
        console.log("Platform earnings after:", factory.platformEarnings());
    }
    
    function testMultipleMints() public {
        console.log("\n=== Test: Multiple Mints ===");
        
        // Deploy token
        vm.prank(creator);
        address tokenAddr = factory.deployMeme(SYMBOL, TOTAL_SUPPLY, PER_MINT, PRICE);
        
        MemeToken token = MemeToken(tokenAddr);
        uint256 totalCost = PRICE * PER_MINT;
        
        // First mint by buyer1
        vm.prank(buyer1);
        factory.mintMeme{value: totalCost}(tokenAddr);
        
        // Second mint by buyer2
        vm.prank(buyer2);
        factory.mintMeme{value: totalCost}(tokenAddr);
        
        // Verify results
        assertEq(token.balanceOf(buyer1), PER_MINT, "Buyer1 should have correct balance");
        assertEq(token.balanceOf(buyer2), PER_MINT, "Buyer2 should have correct balance");
        assertEq(token.totalMinted(), PER_MINT * 2, "Total minted should be 2x per mint");
        
        console.log("Multiple mints successful!");
        console.log("Buyer1 balance:", token.balanceOf(buyer1));
        console.log("Buyer2 balance:", token.balanceOf(buyer2));
        console.log("Total minted:", token.totalMinted());
    }
    
    function testFeeDistribution() public {
        console.log("\n=== Test: Fee Distribution ===");
        
        // Deploy token
        vm.prank(creator);
        address tokenAddr = factory.deployMeme(SYMBOL, TOTAL_SUPPLY, PER_MINT, PRICE);
        
        uint256 totalCost = PRICE * PER_MINT;
        uint256 expectedPlatformFee = (totalCost * 1) / 100; // 1%
        uint256 expectedCreatorFee = totalCost - expectedPlatformFee; // 99%
        
        console.log("Expected total cost:", totalCost);
        console.log("Expected platform fee:", expectedPlatformFee);
        console.log("Expected creator fee:", expectedCreatorFee);
        
        // Record initial balances
        uint256 initialCreatorBalance = creator.balance;
        uint256 initialPlatformEarnings = factory.platformEarnings();
        
        // Mint tokens
        vm.prank(buyer1);
        factory.mintMeme{value: totalCost}(tokenAddr);
        
        // Check fee distribution
        uint256 actualCreatorIncrease = creator.balance - initialCreatorBalance;
        uint256 actualPlatformIncrease = factory.platformEarnings() - initialPlatformEarnings;
        
        assertEq(actualCreatorIncrease, expectedCreatorFee, "Creator fee should be 99%");
        assertEq(actualPlatformIncrease, expectedPlatformFee, "Platform fee should be 1%");
        assertEq(actualCreatorIncrease + actualPlatformIncrease, totalCost, "Total fees should equal total cost");
        
        console.log("Fee distribution verified!");
        console.log("Creator fee received:", actualCreatorIncrease);
        console.log("Platform fee received:", actualPlatformIncrease);
        console.log("Total fees:", actualCreatorIncrease + actualPlatformIncrease);
        
        // Test percentage calculation
        uint256 creatorPercentage = (actualCreatorIncrease * 100) / totalCost;
        uint256 platformPercentage = (actualPlatformIncrease * 100) / totalCost;
        
        console.log("Creator percentage:", creatorPercentage, "%");
        console.log("Platform percentage:", platformPercentage, "%");
        
        assertEq(platformPercentage, 1, "Platform should get exactly 1%");
        assertEq(creatorPercentage, 99, "Creator should get exactly 99%");
    }
    
    function testSupplyLimit() public {
        console.log("\n=== Test: Supply Limit ===");
        
        // Deploy token with small supply for testing
        uint256 smallSupply = PER_MINT * 2; // Only allow 2 mints
        
        vm.prank(creator);
        address tokenAddr = factory.deployMeme(SYMBOL, smallSupply, PER_MINT, PRICE);
        
        MemeToken token = MemeToken(tokenAddr);
        uint256 totalCost = PRICE * PER_MINT;
        
        console.log("Small supply limit:", smallSupply);
        console.log("Per mint amount:", PER_MINT);
        console.log("Max possible mints:", smallSupply / PER_MINT);
        
        // First mint - should succeed
        vm.prank(buyer1);
        factory.mintMeme{value: totalCost}(tokenAddr);
        
        console.log("First mint successful");
        console.log("Remaining supply:", token.remainingSupply());
        console.log("Can mint more:", token.canMint());
        
        // Second mint - should succeed
        vm.prank(buyer2);
        factory.mintMeme{value: totalCost}(tokenAddr);
        
        console.log("Second mint successful");
        console.log("Remaining supply:", token.remainingSupply());
        console.log("Can mint more:", token.canMint());
        
        // Third mint - should fail
        vm.prank(buyer1);
        vm.expectRevert("Cannot mint more tokens");
        factory.mintMeme{value: totalCost}(tokenAddr);
        
        console.log("Third mint correctly failed - supply limit enforced!");
        
        // Verify final state
        assertEq(token.totalMinted(), smallSupply, "All tokens should be minted");
        assertEq(token.remainingSupply(), 0, "No tokens should remain");
        assertFalse(token.canMint(), "Should not be able to mint more");
    }
    
    function testWithdrawPlatformFees() public {
        console.log("\n=== Test: Withdraw Platform Fees ===");
        
        // Deploy token and mint to generate fees
        vm.prank(creator);
        address tokenAddr = factory.deployMeme(SYMBOL, TOTAL_SUPPLY, PER_MINT, PRICE);
        
        uint256 totalCost = PRICE * PER_MINT;
        uint256 expectedPlatformFee = (totalCost * 1) / 100;
        
        // Mint tokens to generate platform fees
        vm.prank(buyer1);
        factory.mintMeme{value: totalCost}(tokenAddr);
        
        assertEq(factory.platformEarnings(), expectedPlatformFee, "Platform earnings should be set");
        
        // Record owner balance before withdrawal
        uint256 initialOwnerBalance = owner.balance;
        
        console.log("Platform earnings before withdrawal:", factory.platformEarnings());
        console.log("Owner balance before withdrawal:", initialOwnerBalance);
        
        // Withdraw platform fees
        factory.withdrawPlatformFees();
        
        // Verify withdrawal
        assertEq(factory.platformEarnings(), 0, "Platform earnings should be reset to 0");
        assertEq(owner.balance, initialOwnerBalance + expectedPlatformFee, "Owner should receive platform fees");
        
        console.log("Platform earnings after withdrawal:", factory.platformEarnings());
        console.log("Owner balance after withdrawal:", owner.balance);
        console.log("Withdrawal successful!");
    }
    
    function testInvalidDeployment() public {
        console.log("\n=== Test: Invalid Deployment Parameters ===");
        
        vm.startPrank(creator);
        
        // Test empty symbol
        vm.expectRevert("Symbol cannot be empty");
        factory.deployMeme("", TOTAL_SUPPLY, PER_MINT, PRICE);
        
        // Test zero total supply
        vm.expectRevert("Total supply must be greater than 0");
        factory.deployMeme(SYMBOL, 0, PER_MINT, PRICE);
        
        // Test zero per mint
        vm.expectRevert("Per mint must be greater than 0");
        factory.deployMeme(SYMBOL, TOTAL_SUPPLY, 0, PRICE);
        
        // Test per mint exceeds total supply
        vm.expectRevert("Per mint cannot exceed total supply");
        factory.deployMeme(SYMBOL, 100, 200, PRICE);
        
        vm.stopPrank();
        
        console.log("All invalid deployment tests passed!");
    }
    
    function testInsufficientPayment() public {
        console.log("\n=== Test: Insufficient Payment ===");
        
        // Deploy token
        vm.prank(creator);
        address tokenAddr = factory.deployMeme(SYMBOL, TOTAL_SUPPLY, PER_MINT, PRICE);
        
        uint256 totalCost = PRICE * PER_MINT;
        uint256 insufficientPayment = totalCost - 1;
        
        console.log("Required payment:", totalCost);
        console.log("Insufficient payment:", insufficientPayment);
        
        // Try to mint with insufficient payment
        vm.prank(buyer1);
        vm.expectRevert("Insufficient payment");
        factory.mintMeme{value: insufficientPayment}(tokenAddr);
        
        console.log("Insufficient payment correctly rejected!");
    }
    
    function testExcessPaymentRefund() public {
        console.log("\n=== Test: Excess Payment Refund ===");
        
        // Deploy token
        vm.prank(creator);
        address tokenAddr = factory.deployMeme(SYMBOL, TOTAL_SUPPLY, PER_MINT, PRICE);
        
        uint256 totalCost = PRICE * PER_MINT;
        uint256 excessPayment = totalCost + 1 ether; // Pay 1 ETH extra
        
        console.log("Required payment:", totalCost);
        console.log("Excess payment:", excessPayment);
        console.log("Expected refund:", excessPayment - totalCost);
        
        // Record buyer balance before
        uint256 initialBuyerBalance = buyer1.balance;
        
        // Mint with excess payment
        vm.prank(buyer1);
        factory.mintMeme{value: excessPayment}(tokenAddr);
        
        // Verify refund
        uint256 finalBuyerBalance = buyer1.balance;
        uint256 actualCost = initialBuyerBalance - finalBuyerBalance;
        
        assertEq(actualCost, totalCost, "Buyer should only pay the required amount");
        
        console.log("Initial buyer balance:", initialBuyerBalance);
        console.log("Final buyer balance:", finalBuyerBalance);
        console.log("Actual cost:", actualCost);
        console.log("Excess payment refund successful!");
    }
    
    function testFactoryStatistics() public {
        console.log("\n=== Test: Factory Statistics ===");
        
        // Initial state
        (uint256 totalTokens, uint256 totalEarnings, address impl) = factory.getFactoryStats();
        assertEq(totalTokens, 0, "Should start with 0 tokens");
        assertEq(totalEarnings, 0, "Should start with 0 earnings");
        assertTrue(impl != address(0), "Implementation should be set");
        
        console.log("Initial stats - Tokens:", totalTokens, "Earnings:", totalEarnings);
        
        // Deploy multiple tokens
        vm.startPrank(creator);
        address token1 = factory.deployMeme("MEME1", TOTAL_SUPPLY, PER_MINT, PRICE);
        address token2 = factory.deployMeme("MEME2", TOTAL_SUPPLY, PER_MINT, PRICE);
        vm.stopPrank();
        
        // Mint from both tokens
        uint256 totalCost = PRICE * PER_MINT;
        vm.prank(buyer1);
        factory.mintMeme{value: totalCost}(token1);
        
        vm.prank(buyer2);
        factory.mintMeme{value: totalCost}(token2);
        
        // Check updated stats
        (totalTokens, totalEarnings, impl) = factory.getFactoryStats();
        uint256 expectedEarnings = (totalCost * 1 / 100) * 2; // 1% of 2 mints
        
        assertEq(totalTokens, 2, "Should have 2 tokens");
        assertEq(totalEarnings, expectedEarnings, "Should have earnings from 2 mints");
        
        console.log("Final stats - Tokens:", totalTokens, "Earnings:", totalEarnings);
        console.log("Factory statistics test passed!");
    }
}
