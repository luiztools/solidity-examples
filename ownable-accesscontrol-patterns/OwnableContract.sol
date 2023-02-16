// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

abstract contract Ownable {
    address private _owner;

    constructor() {
        _owner = msg.sender;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _owner = newOwner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "You do not have permission");
        _;
    }
}

contract OwnableContract is Ownable {
    string internal message = "Hello World!";

    function getMessage() public view returns (string memory) {
        return message;
    }

    function setMessage(string calldata newMessage) external onlyOwner {
        message = newMessage;
    }
}
