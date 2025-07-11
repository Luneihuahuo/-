// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "solidity-bigbank-admin/Ibank.sol";

contract Admin {
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }
 // 将 bank 的 owner 或 admin 设置为 Admin 合约地址后，此函数可把资金提走
    function adminWithdraw(IBank bank) public onlyOwner {
      uint256 balance = address(bank).balance;
        bank.withdraw(balance); // 调用 IBank 接口函数，资金进入 Admin 合约
    }

    // 接收函数
    receive() external payable {}
}
