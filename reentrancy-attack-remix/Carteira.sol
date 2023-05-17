// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Carteira {
    mapping(address => uint) public balances; //user => balance

    constructor() {}

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint amount) external {
        require(balances[msg.sender] >= amount, "Insufficient funds");
        payable(msg.sender).transfer(amount);
        balances[msg.sender] -= amount;
    }

    function withdraw2(uint amount) external {
        require(balances[msg.sender] >= amount, "Insufficient funds");
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
    }

    boole private isProcessing = false;

    function withdraw3(uint amount) external {
        require(!isProcessing, "Reentry blocked");
        isProcessing = true;

        require(balances[msg.sender] >= amount, "Insufficient funds");
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);

        isProcessing = false;
    }

    function withdraw4(uint amount) external nonReentrant {
        require(balances[msg.sender] >= amount, "Insufficient funds");
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
    }
}
