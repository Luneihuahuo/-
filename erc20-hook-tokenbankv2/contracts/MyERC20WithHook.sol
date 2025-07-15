// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title ERC20 with Hook + TokenBankV2
/// @dev 扩展 transferWithCallback 支持合约调用 tokensReceived

interface ITokenReceiver {
    function tokensReceived(address from, uint256 amount) external;
}
contract MyERC20WithHook {
    string public name = "HookedToken";
    string public symbol = "HTK";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
     
     event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
    balanceOf[msg.sender] = _initialSupply;
        totalSupply = _initialSupply;
        emit Transfer(address(0), msg.sender, _initialSupply);
    }
    function transfer(address to, uint256 amount) public returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }
    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        require(allowance[from][msg.sender] >= amount, "Allowance exceeded");
        allowance[from][msg.sender] -= amount;
        _transfer(from, to, amount);
        return true;
    }
    function transferWithCallback(address to, uint256 amount) public returns (bool) {
        _transfer(msg.sender, to, amount);

        // 如果目标地址是合约，尝试调用 tokensReceived
        if (isContract(to)) {
            try ITokenReceiver(to).tokensReceived(msg.sender, amount) {
                // 成功回调
            } catch {
                revert("tokensReceived callback failed");
            }
        }
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(balanceOf[from] >= amount, "Insufficient balance");
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
    }
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
}
contract TokenBankV2 is ITokenReceiver {
    mapping(address => uint256) public deposits;
    event Deposited(address indexed user, uint256 amount);

    function tokensReceived(address from, uint256 amount) external override {
        deposits[from] += amount;
        emit Deposited(from, amount);
    }
     function getDeposit(address user) external view returns (uint256) {
        return deposits[user];
    }
}
