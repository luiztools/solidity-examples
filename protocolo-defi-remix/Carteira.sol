// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

contract Carteira {
    mapping(address => uint) public balances; //user => balance

    constructor() {}

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint amount) external {
        require(balances[msg.sender] >= amount, "Insufficient funds");
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
    }
}
