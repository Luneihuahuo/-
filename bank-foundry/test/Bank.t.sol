// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Bank.sol";

contract BankTest is Test {
    Bank bank;
    address user1 = address(0x1);
    address user2 = address(0x2);
    address user3 = address(0x3);
    address user4 = address(0x4);
    address payable owner;

    function setUp() public {
        owner = payable(address(this));
        bank = new Bank();
    }

    function testDepositUpdatesBalance() public {
        vm.deal(user1, 1 ether);
        vm.prank(user1);
        bank.deposit{value: 1 ether}();

        assertEq(bank.balances(user1), 1 ether);
    }

    function testTopDepositorsWith1User() public {
        vm.deal(user1, 1 ether);
        vm.prank(user1);
        bank.deposit{value: 1 ether}();

        address[3] memory top = bank.getTop3Depositors();
        assertEq(top[0], user1);
    }

    function testTopDepositorsWith4Users() public {
        vm.deal(user1, 1 ether);
        vm.deal(user2, 2 ether);
        vm.deal(user3, 3 ether);
        vm.deal(user4, 4 ether);

        vm.prank(user1); bank.deposit{value: 1 ether}();
        vm.prank(user2); bank.deposit{value: 2 ether}();
        vm.prank(user3); bank.deposit{value: 3 ether}();
        vm.prank(user4); bank.deposit{value: 4 ether}();

        address[3] memory top = bank.getTop3Depositors();
        assertEq(top[0], user4);
        assertEq(top[1], user3);
        assertEq(top[2], user2);
    }

    function testTopDepositorsWithRepeatedUser() public {
        vm.deal(user1, 5 ether);
        vm.prank(user1); bank.deposit{value: 2 ether}();
        vm.prank(user1); bank.deposit{value: 3 ether}();

        address[3] memory top = bank.getTop3Depositors();
        assertEq(top[0], user1);
    }

    function testOnlyOwnerCanWithdraw() public {
        vm.expectRevert("Only owner can withdraw");
        vm.prank(user1);
        bank.withdraw(payable(user1), 1 ether);
    }

    function testOwnerWithdraw() public {
        vm.deal(user1, 2 ether);
        vm.prank(user1); bank.deposit{value: 2 ether}();

        uint256 balanceBefore = address(this).balance;
        bank.withdraw(payable(owner), 1 ether);
        uint256 balanceAfter = address(this).balance;

        assertEq(balanceAfter - balanceBefore, 1 ether);
    }
}
