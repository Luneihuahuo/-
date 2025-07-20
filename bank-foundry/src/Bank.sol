// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Bank {
    address public owner;
    mapping(address => uint256) public balances;
    address[] public users;

    constructor() {
        owner = msg.sender;
    }

    function deposit() public payable {
        if (balances[msg.sender] == 0) {
            users.push(msg.sender);
        }
        balances[msg.sender] += msg.value;
    }

    function getTop3Depositors() public view returns (address[3] memory) {
        address[3] memory topUsers;
        uint256[3] memory topAmounts;

        for (uint256 i = 0; i < users.length; i++) {
            address user = users[i];
            uint256 amount = balances[user];

            for (uint256 j = 0; j < 3; j++) {
                if (amount > topAmounts[j]) {
                    for (uint256 k = 2; k > j; k--) {
                        topAmounts[k] = topAmounts[k - 1];
                        topUsers[k] = topUsers[k - 1];
                    }
                    topAmounts[j] = amount;
                    topUsers[j] = user;
                    break;
                }
            }
        }

        return topUsers;
    }

    function withdraw(address payable to, uint256 amount) public {
        require(msg.sender == owner, "Only owner can withdraw");
        require(address(this).balance >= amount, "Insufficient balance");
        to.transfer(amount);
    }
}
