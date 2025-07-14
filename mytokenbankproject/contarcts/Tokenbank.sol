// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMyToken {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    }

contract TokenBank {
    IMyToken public token;
    mapping(address => uint256) public deposits;}
 token = IMyToken(tokenAddress);
    }

    function deposit(uint256 amount) public {
    require(amount > 0, "Amount must be greater than zero");
        bool success = token.transferFrom(msg.sender, address(this), amount);
        require(success, "Transfer failed");
        deposits[msg.sender] += amount;
    }

    function withdraw(uint256 amount) public {
    require(amount > 0, "Amount must be greater than zero");
        require(deposits[msg.sender] >= amount, "Insufficient balance in bank");

        deposits[msg.sender] -= amount;
        bool success = token.transfer(msg.sender, amount);
        require(success, "Transfer failed");
    }
}
