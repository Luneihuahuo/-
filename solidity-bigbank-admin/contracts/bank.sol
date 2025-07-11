// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "solidity-bigbank-admin/Ibank.sol";

contract Bank is IBank {
  address public owner;
    mapping(address => uint256) public balances;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }
 owner = msg.sender;
    }

    function deposit() public payable override virtual {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) public override {
        require(balances[msg.sender] >= amount, "Insufficient");
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
    }
}
