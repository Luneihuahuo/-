// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/TokenBank.sol";
import "../src/MyToken.sol";

contract TokenBankTest is Test {
    MyToken public token;
    TokenBank public bank;
    address public owner;
    address public user;
    uint256 public userPrivateKey;

    function setUp() public {
        // 设置账户
        owner = address(this);
        userPrivateKey = 0xB0B;
        user = vm.addr(userPrivateKey);
        
        // 部署合约
        token = new MyToken(1000000 * 10**18); // 初始供应量1,000,000
        bank = new TokenBank(address(token));
        
        // 转账给用户
        token.transfer(user, 1000 * 10**18); // 转1000个token给用户
    }

    function testDeposit() public {
        // 模拟用户操作
        vm.startPrank(user);
        
        // 普通存款
        token.approve(address(bank), 100 * 10**18);
        bank.deposit(100 * 10**18);
        
        // 验证结果
        assertEq(bank.balances(user), 100 * 10**18);
        
        vm.stopPrank();
    }

    function testPermitDeposit() public {
        uint256 amount = 50 * 10**18;
        uint256 deadline = block.timestamp + 3600;
        
        // 准备permit签名数据
        bytes32 domainSeparator = token.DOMAIN_SEPARATOR();
        
        // 计算permit的消息哈希
        bytes32 permitHash = keccak256(
            abi.encodePacked(
                "\x19\x01",
                domainSeparator,
                keccak256(
                    abi.encode(
                        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"),
                        user,
                        address(bank),
                        amount,
                        token.nonces(user),
                        deadline
                    )
                )
            )
        );
        
        // 使用用户私钥签名
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, permitHash);
        
        // 模拟用户调用permitDeposit
        vm.prank(user);
        bank.permitDeposit(amount, deadline, v, r, s);
        
        // 验证结果
        assertEq(bank.balances(user), amount);
    }
}