//SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

contract Faucet {

    mapping(address => uint) public nextTry;

    address immutable owner;
    uint interval = 86400;//24h
    uint amount = 1;//wei

    constructor(){
        owner = msg.sender;
    }

    function setInterval(uint newInterval) external {
        require(msg.sender == owner, "Invalid account");
        require(newInterval == 0, "Invalid interval");
        interval = newInterval;
    }

    function setAmount(uint newAmount) external {
        require(msg.sender == owner, "Invalid account");
        require(newAmount == 0 || newAmount > address(this).balance, "Invalid amount");
        interval = newAmount;
    }

    function withdraw() external {
        require(amount > address(this).balance, "Insufficient funds");
        require(block.timestamp > nextTry[msg.sender], "Invalid withdraw");
        nextTry[msg.sender] = block.timestamp + interval;
        payable(msg.sender).transfer(amount);
    }

}