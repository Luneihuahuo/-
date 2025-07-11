// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "solidity-bigbank-admin/Bank.sol";

contract BigBank is Bank {
    address public admin;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin");
        _;
    }

    modifier depositLimit() {
        require(msg.value > 0.001 ether, "Minimum 0.001 ETH");
        _;
        }
         admin = msg.sender;
    }

    function deposit() public payable override depositLimit() {
        super.deposit();
    }

    function changeAdmin(address newAdmin) public onlyAdmin() {
        require(newAdmin != address(0), "Invalid address");
        admin = newAdmin;
    }
}
