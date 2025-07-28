// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenBank {
    IERC20 public token;
    IERC20Permit public permitToken;
    mapping(address => uint256) public balances;

    constructor(address _token) {
        token = IERC20(_token);
        permitToken = IERC20Permit(_token);
    }

    function deposit(uint256 amount) external {
        require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        balances[msg.sender] += amount;
    }

    function permitDeposit(
        uint256 amount,
        uint256 deadline,
        uint8 v, bytes32 r, bytes32 s
    ) external {
        permitToken.permit(msg.sender, address(this), amount, deadline, v, r, s);
        require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        balances[msg.sender] += amount;
    }
}