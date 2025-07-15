// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20Receiver {
    function tokensReceived(address from, uint256 amount, bytes calldata data) external;
}

contract MyToken { 
    string public name = "MyToken";
    string public symbol = "MTK";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event TransferWithCallback(address indexed from, address indexed to, uint256 value, bytes data);
    balances[msg.sender] = _supply;
        totalSupply = _supply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }
    function transfer(address to, uint256 value) public returns (bool) {
        require(balances[msg.sender] >= value, "Insufficient");
        balances[msg.sender] -= value;
        balances[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }
    function transferWithCallback(address to, uint256 value, bytes calldata data) public returns (bool) {
        require(balances[msg.sender] >= value, "Insufficient");
        balances[msg.sender] -= value;
        balances[to] += value;
        emit TransferWithCallback(msg.sender, to, value, data);

        if (isContract(to)) {
            IERC20Receiver(to).tokensReceived(msg.sender, value, data);
        }
        return true;
    }
    function approve(address spender, uint256 value) public returns (bool) {
        allowances[msg.sender][spender] = value;
        return true;
    }
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(balances[from] >= value, "Insufficient");
        require(allowances[from][msg.sender] >= value, "Not approved");
        balances[from] -= value;
        balances[to] += value;
        allowances[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }

    function isContract(address addr) internal view returns (bool) {
        return addr.code.length > 0;
    }
}
