// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title Nongming Coin ($NM) - 无权限ERC20代币
/// @notice 一次性分发，完全去中心化，不可增发，不可销毁

contract NMToken {
    // 基本信息
    string public name = "Nongming Coin";
    string public symbol = "NM";
    uint8 public decimals = 18;
    uint256 public totalSupply = 9000000 * 10 ** 18;

    // 余额和授权记录
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // 事件标准
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // 构造函数：部署时将所有代币一次性分配给指定地址
    constructor() {
        address initialReceiver = 0x6B46E77eC6d70712d1E0C8e180a1f44775AF4b52;
        balanceOf[initialReceiver] = totalSupply;
        emit Transfer(address(0), initialReceiver, totalSupply);
    }

    // 用户转账
    function transfer(address to, uint256 value) public returns (bool) {
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    // 授权他人支配额度
    function approve(address spender, uint256 value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    // 他人根据授权转账
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(balanceOf[from] >= value, "Insufficient balance");
        require(allowance[from][msg.sender] >= value, "Not approved");
        balanceOf[from] -= value;
        balanceOf[to] += value;
        allowance[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }
}
